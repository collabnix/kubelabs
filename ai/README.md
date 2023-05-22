# Using Kubernetes via AI

## Getting Started 

- Docker Desktop
- Install Kubectl-ai

```
brew tap sozercan/kubectl-ai https://github.com/sozercan/kubectl-ai
brew install kubectl-ai
```

## Creating your first Nginx Pod

```
kubectl ai "create an nginx pod"
✨ Attempting to apply the following manifest:

apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
Use the arrow keys to navigate: ↓ ↑ → ← 
? Would you like to apply this? [Reprompt/Apply/Don't Apply]: 
+   Reprompt
  ▸ Apply
    Don't Apply
```

<img width="861" alt="image" src="https://github.com/collabnix/kubelabs/assets/313480/c32fc25c-23cd-4af6-bcca-c6d627695082">



## Deployment

Select "Reprompt" and type "make this into deployment"

```
Reprompt: make this into deployment
✨ Attempting to apply the following manifest:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
 ```

## ReplicaSet

```
Reprompt: Scale to 3 replicas
```

```
Reprompt: Scale to 3 replicas
✨ Attempting to apply the following manifest:

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
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
  ```
  
 <img width="939" alt="image" src="https://github.com/collabnix/kubelabs/assets/313480/0e0602be-feed-42bb-93cd-bd11fd301b3c">


```
kubectl ai "Create Nginx Pod running on port 82 with 3 replicasets labeled web"
```

## Services 


```
kubectl ai "create a service for the nginx deployment with load balancer that uses nginx selector"
✨ Attempting to apply the following manifest:

apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
✔ Apply

```

<img width="607" alt="image" src="https://github.com/collabnix/kubelabs/assets/313480/c58ef3f0-07a9-4294-83fa-24f2eeee38f5">

Here's the final view of the Kubeview:

<img width="1223" alt="image" src="https://github.com/collabnix/kubelabs/assets/313480/1ced621d-24d2-4ae1-83d8-98b0a75c3233">


