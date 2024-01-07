# Lab

You will need a Kubernetes cluster. A single node [Minikube cluster](https://minikube.sigs.k8s.io/docs/start/) will do just fine. Once the cluster is setup, we can go ahead and jump right into the lab since all other requirements to get an autoscaler up and running is already present within Kubernetes itself.

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
          limits:
            cpu: 200m
            memory: 256Mi
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
  name: example-vpa
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind: Deployment
    name: example-deployment
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

The resource itself is fairly self-explanatory. A vpa with name "example-vpa" will get created.


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
          limits:
            cpu: 200m
            memory: 256Mi
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
---
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx-deployment
  minReplicas: 2
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 80
```