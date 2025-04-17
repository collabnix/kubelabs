# Lab

You will need a Kubernetes cluster. A single node [Minikube cluster](https://minikube.sigs.k8s.io/docs/start/) will do just fine. Once the cluster is setup, you will have to install the metrics server, since the autoscalers use this to read the resource usage metrics. To do this, run:

```
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

We will start with a base application that will have the scaling performed in it. In this case, we will use a sample nginx deployment. Create a file `nginx-deployment.yaml` and paste the below contents to it:



```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx-container
        image: nginx:1.21.5
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

This will start an nginx container that has at least 100m CPU & 128Mb memory, but not more than 200m CPU and 256Mb memory. It will also start the service that points to this deployment on port 80. Deploy this application onto your Kubernetes cluster:

```
kubectl apply -f nginx-deployment.yaml
```

Now, when the application reaches the CPU or memory limit, it will affect application performance since it is not allowed to go beyond that. So let's introduce the autoscaler. We will start with the vertical pod autoscaler. Create a new file called "nginx-vpa.yaml" and paste the contents of the below script there.

```
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: nginx-vpa
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind: Deployment
    name: nginx-deployment
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
    - containerName: "*"  # Apply policies to all containers in the pod
      minAllowed:
        cpu: 50m
        memory: 64Mi
      maxAllowed:
        cpu: 500m
        memory: 512Mi
```

The resource itself is fairly self-explanatory. The spec section contains the specifications for the VPA. The targetRef section specifies the workload that the VPA is targeting for autoscaling. In this example, it's targeting a Deployment named "nginx-deployment." The updatePolicy section configures the update mode. In "Auto" mode, VPA automatically applies the recommended changes to the pod resources without manual intervention. The resourcePolicy section specifies the resource policies for individual containers within the pod. Within it, you have the containerPolicies section which defines policies for containers. In this case, it uses a wildcard ("*") to apply policies to all containers in the pod. It also has the minAllowed section which specifies the minimum allowed resources. VPA won't recommend going below these values. For example, the minimum allowed CPU is 50 milliCPU (50m), and the minimum allowed memory is 64 megabytes (64Mi). The maxAllowed section specifies the maximum allowed resources. VPA won't recommend going above these values. For example, the maximum allowed CPU is 500 milliCPU (500m), and the maximum allowed memory is 512 megabytes (512Mi).

Now deploy this into the Kubernetes cluster:

```
kubectl apply -f nginx-vpa.yaml
```

Once the deployment is complete, we need to load-test the deployment to see the VPA in action. An important thing to note here is that if you placed the VPA memory/CPU limit too low, this will result in the pod starting up replicas immediately upon pod creation since the limit will be reached as soon as the pod comes up. This is why it is important to be aware of your average and peak loads before you begin implementing the VPA.

To load test the deployment, we will be using Apache Benchmark. Install it with `apt` or `yum`. You can do the installation on the Kubernetes node that has started. Next, note down the URL you want to load-test. To get this, use:

```
kubectl get svc
```

This will list all the services. Pick the nginx service from this list, copy its IP, and use Benchmark as below:

```
ab -n 1000 -c 50 http://<nginx-service-ip>/
```

This command will send 1000 requests with a concurrency of 50 to the NGINX service. You can adjust the -n (total requests) and -c (concurrency) parameters based on your specific load testing requirements. You can then analyze the results. Apache Benchmark will provide detailed output, including request per second (RPS), connection times, and more. For example:

```
Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    1   2.8      0      10
Processing:   104  271 144.3    217    1184
Waiting:      104  270 144.2    217    1184
Total:        104  272 144.5    217    1185
```

Now it's time to check if autoscaling has started:

```
kubectl get po -n default
```

Watch the pods, and you will see that the resource limits are reached, after which a new pod with more resources is created. Keep an eye on the resource usage and you will notice that the new resources have higher limits. Once the requests have been handled, the pod will immediately reduce the resource consumption. However, a new pod with lower resource requirements will not show up to replace the old pod. In fact, if you were to push a new version of the deployment into the cluster, it would still have space for a large amount of requests. However, this will reduce eventually if the amount of resources consumed continues to be low.

Now that we have gotten a complete look at the vertical pod autoscaler, let's take a look at the HPA. Create a file nginx-hpa.yml and paste the below contents into it.

```
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx-deployment
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 80
```

The above HPA definition has a lot of similarities to the VPA definition. The differences lie in the minReplicas and maxReplicas sections which define the minimum and maximum number of pod replicas that the HPA should maintain. In this case, it's set to have a minimum of 2 replicas and a maximum of 5 replicas. The VPA didn't have a metrics section that the HPA has, but its resourcePolicy section is pretty similar to this, where the metrics configure the metric used for autoscaling. In this example, it's using the CPU utilization metric.`type: Resource:` Specifies that the metric is a resource metric (in this case, CPU). The `resource` section specifies the resource metric details. `name: cpu` Indicates that the metric is CPU utilization. The target section specifies the target value for the metric and `type: Utilization` indicates that the target is based on resource utilization. `averageUtilization` sets the target average CPU utilization to 80%.

Before you deploy this file into your cluster, make sure to remove the VPA since having two types of autoscalers running for the same pod can cause some obvious problems. So first run:

```
kubectl delete -f nginx-vpa.yaml
```

Then deploy the HPA:

```
kubectl apply -f nginx-hpa.yaml
```

You can see the status of the HPA as it starts up using `describe`:

```
kubectl describe hpa nginx-hpa
```

You might see some errors about the HPA being unable to retrieve metrics, however, these can be ignored since this is an issue that occurs only when the HPA starts up for the first time. Now, let's go back to the apache benchmark and add load to the nginx service so that we can see the HPA in action. Let's start it up in the same manner as before:

```
ab -n 1000 -c 50 http://<nginx-service-ip>/
```

A thousand requests should start being sent to the service. Start watching the nginx pod to see if replicas are being created:

```
kubectl get po -n default --watch
```

You should be able to see the memory limit getting reached, after which the number of pods will increase. This will keep happening until the number of pods reaches the maximum specified value (5) or the memory requests are satisfied.


## Conclusion

That sums up the lab on autoscalers. In here, we discussed the two most commonly used in-built autoscalers: HPA and VPA. We also took a hands-on look at how the autoscalers worked. This is just the tip of the iceberg when it comes to scaling, however, and the subject of custom scalers that can scale based on metrics other than memory and CPU is vast. If you are interested in looking at more complicated scaling techniques, you could take a look at the [KEDA section](../Keda101/what-is-keda.md) to get some idea of the keda autoscaler.