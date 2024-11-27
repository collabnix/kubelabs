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

We say that if `headers` match the key `client-id` and value `abc123`, then redirect the request to backend B. If not, go to backend A. So if this was a specific client, then all that client's requests would go to backend B while all the other clients would still have their requests route to the stable backend. Since it is normal practice to maintain several test clients for an application, you could add your test client ID for the green deployment and perform testing on it without affecting your actual clients.