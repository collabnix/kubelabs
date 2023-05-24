# Using Kubernetes via AI

## Getting Started 

- Docker Desktop
- Install Kubectl-ai

```
brew tap sozercan/kubectl-ai https://github.com/sozercan/kubectl-ai
brew install kubectl-ai
```

- Get OpenAI Keys via https://platform.openai.com/account/api-keys

kubectl-ai requires an OpenAI API key or an Azure OpenAI Service API key and endpoint, and a valid Kubernetes configuration.

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

Let's break down the different sections of this manifest:

- apiVersion: Specifies the version of the Kubernetes API to use.
- kind: Specifies the type of resource, which in this case is a Deployment.
- metadata: Contains metadata for the deployment, including the name.
- containers: Defines the containers running in the pod.
- name: Specifies the name of the container.
- image: Specifies the Docker image to use.
- ports: Specifies the port configuration for the container.

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


Let's break down the different sections of this manifest:

- apiVersion: Specifies the version of the Kubernetes API to use.
- kind: Specifies the type of resource, which in this case is a Deployment.
- metadata: Contains metadata for the deployment, including the name.
- spec: Specifies the desired state of the deployment.
- replicas: Defines the number of replicas (pods) you want to create.
- selector: Specifies the labels used to select the pods controlled by this deployment.
- template: Defines the pod template used to create the pods.
- metadata: Contains labels for the pod.
- spec: Specifies the pod's specifications.
- containers: Defines the containers running in the pod.
- name: Specifies the name of the container.
- image: Specifies the Docker image to use.
- ports: Specifies the port configuration for the container.

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


## Deploying Pod using namespace

```
kubectl ai "Create a namespace called ns1 and deploy a Nginx Pod"        
✨ Attempting to apply the following manifest:

---
apiVersion: v1
kind: Namespace
metadata:
  name: ns1
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: ns1
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 1
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
Use the arrow keys to navigate: ↓ ↑ → ← 
? Would you like to apply this? [Reprompt/Apply/Don't Apply]: 
+   Reprompt
  ▸ Apply
    Don't Apply
```

<img width="1013" alt="image" src="https://github.com/collabnix/kubelabs/assets/313480/e4f6cb3f-cef0-4351-9903-f083454c22be">


## Difference between "Create" and "Deploy" [Be Careful]

```
kubectl ai "Create a namespace called ns1 and create a Nginx Pod"
✨ Attempting to apply the following manifest:

apiVersion: v1
kind: Namespace
metadata:
  name: ns1
---
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  namespace: ns1
spec:
  containers:
  - name: nginx
    image: nginx:1.7.9
    ports:
    - containerPort: 80
✔ Apply
```

<img width="978" alt="image" src="https://github.com/collabnix/kubelabs/assets/313480/ff55b205-997c-4a49-a3dc-b91c8f14214d">


## Accessing the Nginx Pod via Web Browser

```
kubectl port-forward nginx 8000:80 -n ns1
Forwarding from 127.0.0.1:8000 -> 80
Forwarding from [::1]:8000 -> 80
Handling connection for 8000
Handling connection for 8000
```

<img width="999" alt="image" src="https://github.com/collabnix/kubelabs/assets/313480/69f1c71c-0239-44d8-a94c-50cee8e0c384">


## If I can access Pod directly via a web browser, why do I need deployment?


While it is possible to access a pod directly via a web browser, using a deployment provides several benefits and is generally recommended in a production environment. Deployments help manage the lifecycle of your application and provide features such as scalability, rolling updates, and fault tolerance. Here are a few reasons why using a deployment is beneficial:

- Replication and Scalability: Deployments allow you to specify the desired number of replicas for your application. This means that multiple identical pods will be created, providing scalability and load balancing. If one pod fails or becomes unavailable, the deployment will automatically create a new replica to ensure that the desired number of pods is maintained.

- Rolling Updates: Deployments support rolling updates, which allow you to update your application without incurring downtime. You can update the pod template in the deployment specification, and the deployment controller will manage the update process by gradually replacing old pods with new ones. This ensures a smooth transition and minimizes any impact on your application's availability.

- Versioning and Rollbacks: Deployments enable you to manage different versions of your application. If an update introduces issues or unexpected behavior, you can easily roll back to a previous version by specifying the desired revision. This helps maintain application stability and allows for quick recovery in case of problems.

- Health Checks and Self-Healing: Deployments include health checks that monitor the status of pods. If a pod fails the health check, it will be automatically restarted or replaced by a new pod. This self-healing mechanism ensures the availability and reliability of your application.

- Declarative Configuration: Deployments use a declarative approach, where you define the desired state of your application, and the deployment controller ensures that the current state matches the desired state. This simplifies management and allows for easier collaboration and reproducibility.

- Integration with Other Kubernetes Resources: Deployments integrate well with other Kubernetes resources, such as services, ingress, and horizontal pod autoscalers. This enables you to expose your application externally, manage traffic routing, and automatically scale your application based on resource utilization or custom metrics.

While it's possible to directly access a pod via a web browser, using a deployment provides a more robust and scalable solution for managing your application in a production environment. It offers benefits such as replication, scalability, rolling updates, versioning, self-healing, and integration with other Kubernetes resources. By leveraging deployments, you can ensure the stability, availability, and efficient management of your application throughout its lifecycle.

## Deployment

This is an example for deploying 3 replicas in the specific namespace

```
kubectl ai "create an nginx deployment with 3 replicas under namespace ns1"
✨ Attempting to apply the following manifest:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: ns1
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
      - name: webpage
        image: ajeetraina/webpage
        ports:
        - containerPort: 80
✔ Apply
```

<img width="753" alt="image" src="https://github.com/collabnix/kubelabs/assets/313480/ae18c810-d3b5-457b-b4a9-2eef35b0b4e8">


## Services


```
kubectl ai "create an nginx deployment with 3 replicas under namespace ns1 and this time create service type as NodePort"
✨ Attempting to apply the following manifest:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: ns1
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
      - name: webpage
        image: ajeetraina/webpage
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  namespace: ns1
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 30080
Use the arrow keys to navigate: ↓ ↑ → ← 
? Would you like to apply this? [Reprompt/Apply/Don't Apply]: 
+   Reprompt
  ▸ Apply
    Don't Apply
```

## Listing the Kubernetes Resources

```
kubectl get po,deploy,svc -n ns1
NAME                                    READY   STATUS    RESTARTS   AGE
pod/nginx-deployment-58945458f5-5pk6b   1/1     Running   0          28s
pod/nginx-deployment-58945458f5-7htd7   1/1     Running   0          28s
pod/nginx-deployment-58945458f5-s6cxm   1/1     Running   0          28s

NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-deployment   3/3     3            3           28s

NAME                    TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
service/nginx-service   NodePort   10.100.230.251   <none>        80:30080/TCP   28s
```


<img width="807" alt="image" src="https://github.com/collabnix/kubelabs/assets/313480/e088ae03-ede5-45a3-b008-2423227ef73d">

