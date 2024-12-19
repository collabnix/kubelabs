# Rollouts lab

As always, you need to have a Kubernetes cluster ready for use. Any cluster is fine since we are only interested in deployments today. Additionally, you will also need to install the below resources:

- ArgoCD: [Installation guide](../GitOps101/argocd.md#deploying-argocd)
- Linkerd: [Installation guide](../ServiceMesh101/what-is-linkerd.md#setting-up-linkerd)

We will be using ArgoCD for header-based traffic routing and LinkerD for both header-based and traffic split-based routing. So, once the above two items are in place, let's get started.

## Header based splitting

For both cases, we will use an application designed for canary deployments. Run the below commands:

```
kubectl create ns test --dry-run=client -o yaml \
 | linkerd inject - \
 | kubectl apply -f -

helm repo add podinfo https://stefanprodan.github.io/podinfo
helm install backend-a -n test \
 --set ui.message='A backend' podinfo/podinfo
helm install backend-b -n test \
 --set ui.message='B backend' podinfo/podinfo

helm install frontend -n test \
 --set backend=http://backend-a-podinfo:9898/env podinfo/podinfo

kubectl -n test port-forward svc/frontend-podinfo 9898 &
```

This injects linkerd to a new namespace "test" which will be used for both types of routing, then installs an application on it. This application will be a simple application with 2 backends. We will be splitting the traffic to either of the backends depending on our configuration. For now, test the application with curl:

```
$ curl -sX POST localhost:9898/echo \
 | grep -o 'PODINFO_UI_MESSAGE=. backend'

PODINFO_UI_MESSAGE=A backend
```

Since we haven't introduced any traffic splitting the message will always show the response as "A backend" since the backend will always be pointed at backend A. In this case, assume that backend A is the "blue" deployment (the stable version that is currently running) while backend B is the "green" deployment (the new version). Now, let's look at linkerd's HTTP route which will be used to set up the traffic splitting.

```yaml
apiVersion: policy.linkerd.io/v1beta2
kind: HTTPRoute
metadata:
  name: backend-router
  namespace: test
spec:
  parentRefs:
    - name: backend-a-podinfo
      kind: Service
      group: core
      port: 9898
  rules:
    - matches:
      - headers:
        - name: "client-id"
          value: "abc123"
      backendRefs:
        - name: "backend-b-podinfo"
          port: 9898
    - backendRefs:
      - name: "backend-a-podinfo"
        port: 9898
```

Let's dig deeper into this file. We can see that it is of `kind: HTTPRoute`. However the `apiVersion` specifies `policy.linkerd.io` which means this is Linkerd's modified HTTPRoute object and not the default HTTPRoute object from the gateway API. For the parentref, we place backend A (blue backend) so that all requests go to it by default. Next, we specify the rules that need to match based on headers:

```yaml
- matches:
 - headers:
 - name: "client-id"
        value: "abc123"
    backendRefs:
 - name: "backend-b-podinfo"
        port: 9898
 - backendRefs:
 - name: "backend-a-podinfo"
      port: 9898
```

We say that if `headers` match the key `client-id` and value `abc123`, then redirect the request to backend B. If not, go to backend A. So if this was a specific client, all that client's requests would go to backend B while all the other clients would still have their requests routed to the stable backend. Since it is normal practice to maintain several test clients for an application, you could add your test client ID for the green deployment and perform testing on it without affecting your actual clients.

However, you might notice that this directly manipulates the `backend-a-podinfo` service. Any request that comes into the `backend-a-podinfo` will go through this traffic-splitting process as intended. However, if your pods were to be called in some other way, this splitting process would be overlooked and the request would go only to pod A. This would be the case if you are using, for example, AWS ALB. To understand why this happens, let's take a look at how ALBs connected to ingresses work.

Before using an ALB, you need to install the ALB controller manager in your cluster. This controller manager keeps track of what pods are running, their health status, and IPs. When a pod gets rescheduled or the IP changes for any reason, the ALB controller notices this and swaps out the IP in the target group. To avoid the latency of going through the ALB to the service, and then the service to the pod, the pod IP is placed directly. This causes the splitting process to be ignored. In this case, you must add the route splitting on the ALB itself. Adding route splitting on the ALB is simple but since we are controlling the ALB through an ingress yaml, the configuration might look more complicated so let's break it down.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-main
  labels:
#    app: usermgmt-restapp
  annotations:
    # Ingress Core Settings
    kubernetes.io/ingress.class: "alb"
    alb.ingress.kubernetes.io/scheme: internal
    alb.ingress.kubernetes.io/subnets: subnet-123
    alb.ingress.kubernetes.io/target-type: ip 
    alb.ingress.kubernetes.io/forwarded-for-header: "X-Forwarded-Host"
    alb.ingress.kubernetes.io/healthcheck-interval-seconds: '15'
    alb.ingress.kubernetes.io/healthcheck-timeout-seconds: '5'
    alb.ingress.kubernetes.io/success-codes: '200'
    alb.ingress.kubernetes.io/healthy-threshold-count: '2'
    alb.ingress.kubernetes.io/unhealthy-threshold-count: '2'
    alb.ingress.kubernetes.io/actions.backend-b: >
      {"type":"forward","forwardConfig":{"targetGroups":[{"serviceName":"backend-b","servicePort":"9095"}]}}
    alb.ingress.kubernetes.io/conditions.backend-b: >
      [{"field":"http-header","httpHeaderConfig":{"httpHeaderName": "example-header-2", "values":["value"]}}]
spec:
  rules:
  - http:
      paths:
      - path: /backend/
        pathType: Prefix
        backend:
          service:
            name: backend-b
            port:
              name: use-annotation
      - path: /backend/
        pathType: Prefix
        backend:
          service:
            name: backend-a
            port:
              number: 9095
```

Most of the ingress file is similar to what any normal ingress file would look like. The difference is in these annotations:

```
alb.ingress.kubernetes.io/actions.backend-b: >
  {"type":"forward","forwardConfig":{"targetGroups":[{"serviceName":"backend-b","servicePort":"9095"}]}}
alb.ingress.kubernetes.io/conditions.backend-b: >
  [{"field":"http-header","httpHeaderConfig":{"httpHeaderName": "example-header-2", "values":["value"]}}]
```

These annotations are used to specify header-based splitting on an ALB level. To break down the JSON, backend B (the green backend) has its service name and port specified. Then, under conditions, the header to split based on is provided (example-header-2 in this case). The key could have multiple values.

After we have defined this as part of the annotation, we use rule priority to split the traffic under `paths`. In this case, the path is `backend` in both cases. What differs is the service name. The path on top gets higher priority so it is reached first when deciding where to route the traffic. It defers to the provided annotation and checks if the httpHeaderName condition is matched. If yes, the request is forwarded to backend-b. If not, the request then goes to the next priority path, matches with it, and gets redirected to backend-a. This will ensure that any requests from external load balancers will always be routed to the correct service depending on the blue-green configuration. However once the request comes inside the cluster, if it is again forwarded to a different application internally, that request will not be forwarded using the header-based paths which is where you need to use HTTPRoutes as described above.

So by combining both HTTPRoutes and ingresses, you should be able to fully cover any request, wherever it comes from, and reroute it to the correct service. Since we have covered header based splitting, let's look at traffic percentage splits.

## Traffic percentage splitting

We will use a slightly different setup for traffic percentage splitting with the addition of Argo rollouts. Run the below commands to install rollouts:

```bash
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
kubectl apply -k https://github.com/argoproj/argo-rollouts/manifests/crds\?ref\=stable
```

Since the sample we used for  header based splitting used the same image, it would not be a good example here. So instead let's use a sample provided by Argo:

```bash
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-rollouts/master/docs/getting-started/basic/rollout.yaml
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-rollouts/master/docs/getting-started/basic/service.yaml
```

The first file is the rollout file that specifies the rollout resource. Let's take a look at it in more detail:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: rollouts-demo
spec:
  replicas: 5
  strategy:
    canary:
      steps:
      - setWeight: 20
      - pause: {}
      - setWeight: 40
      - pause: {duration: 10}
      - setWeight: 60
      - pause: {duration: 10}
      - setWeight: 80
      - pause: {duration: 10}
  revisionHistoryLimit: 2
  selector:
    matchLabels:
      app: rollouts-demo
  template:
    metadata:
      labels:
        app: rollouts-demo
    spec:
      containers:
      - name: rollouts-demo
        image: argoproj/rollouts-demo:blue
        ports:
        - name: http
          containerPort: 8080
          protocol: TCP
        resources:
          requests:
            memory: 32Mi
            cpu: 5m
```

You can see that the object is of kind "Rollout." The important part is the strategy, which is set to "canary," and the steps. These steps have a weight to each of them, and in this case, the weight represents the traffic percentage. Here, we go in 5 steps: start with 20%, then increase 20% until we reach 100%. The rest of the deployment yaml is a regular deployment manifest.

You will note that after the first step, you have `pause: {}`. This means that the deployment won't go beyond this point until it is manually promoted. From this point on, however, it will wait the mentioned number of seconds and automatically switch traffic over after the period mentioned inside the brackets. If you want to promote each step manually, you have to keep the brackets empty.

Use this command on a terminal window so we can keep watch of the promotions happening:

```
kubectl argo rollouts get rollout rollouts-demo --watch
```

You will now notice that only the blue image is specified here. Since we are promoting a yellow image, let's define it using the kubectl CLI:

```
kubectl argo rollouts set image rollouts-demo \
 rollouts-demo=argoproj/rollouts-demo:yellow
```

Since you have the watch command open, you should see the rollout beginning to progress. It will start by automatically opening 20% of traffic. To move it further, you can use the command line:

```
kubectl argo rollouts promote rollouts-demo
```

This is a good time to introduce the Argo Rollouts UI. The UI is installed automatically so you can start it up with:

```
kubectl argo rollouts dashboard
```

This allows you to perform the deployment promotions using the UI instead of the CLI. It also allows you to visualize this promotion. You can also promote deployment from this UI instead of using the `kubectl` command. As you might have noticed, this UI is pretty basic and does not have the same level of detail and features as the ArgoCD dashboards. But this is still useful since you can expose this dashboard and allow developers to promote their deployments without giving them access to `kubectl`.

Aborting the rollout can be done like so:

```
kubectl argo rollouts abort rollouts-demo
```

This can also be done via the UI.

This covers splitting traffic based on traffic percentage. There are a lot of extension to this topic, and a full list of possibilities can be found in the [official docs](https://argoproj.github.io/argo-rollouts/getting-started/#summary).

Next, let's look at a combination of both: header and traffic percentage splitting.

## Combine splitting

To allow a certain percentage of select clients to get your new application version, you must mix header-based and traffic-based routing. Since both methods use linkerd, that is the base requirement for this split. However, this is also the most complicated way to split traffic.

Regarding the order, header-based splitting will come into effect before traffic-based splitting. This is because header-based splitting starts in the load balancer, which means splitting happens before the request reaches the cluster, whereas traffic splitting occurs after the request reaches the cluster. Therefore, it is impossible to split based on traffic first. So we will be following the header based splitting as usual where the load balancer will be splitting the traffic. After that split is complete we will be getting traffic as usual to the blue version while the green version will be only getting the traffic of a specific client. From this point, we need to get a certain percentage of traffic to continue to the green version while the rest gets re-routed to the blue version. So in this case, we will have 3 deployments instead of 2. 2 deployments will be the blue deployment, one for the HTTP-based routing and another for traffic-based. The other deployment will be the green deployment. To summarize, this is what the flow will look like:

- Request comes from the load balancer
- Load balancer splits traffic based on header
- Split green traffic goes to the Rollout object
- Rollout object redirects traffic to the TrafficSplit object
- TrafficSplit object directs a percentage of traffic to green deployment
- TrafficSplit object directs another percentage back to the blue deployment
- If the request is redirected again from the application to another application with b/g configurations, it will follow the same traffic splitting as defined in the HTTPRoute configuration & Argo rollouts configurations.

For this, we will go back to the example we used for header based routing. We will have the ALB + HTTPRoute configured so that the requests come to the correct pod. We will set up Argo Rollouts next using Rollout object:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: backend-rollout
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
  strategy:
    canary:
      steps:
      - setWeight: 50 # Sends 50% traffic to the canary (backend-a)
      - pause:
          duration: 60s
      stableService: backend-a
      canaryService: backend-b
```

You will note that the `template` option has not been used here. In the previous example, we defined the deployment alongside the rollout. We will not be doing that here as the deployment is already created so we only need to use a `selector` to match the deployment.

The next major difference is this part:

```yaml
strategy:
  canary:
    linkerd:
      stableService: backend-a
      canaryService: backend-b
```

We didn't have something like this before since, with the example provided by Argo, we used the **same service** with different images. In this case, we are using different images (since that is the whole point of canary deployments), but we are also using different services. In short, it's like we have 2 completely different applications. Therefore, we need to explicitly define which is the stable service and which is the canary one.

Note that currently, 100% of the traffic that comes into the Rollout object is aimed at the new green deployment. The Rollout object's job is to divert a percentage of this traffic away from the green service back to the blue one.