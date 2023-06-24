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

```
export OPENAI_API_KEY=<your OpenAI key>
```



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

## Quick Question: Why it says <none> for the nginx service?


The reason the External-IP is not displaying for your service is because you are using a NodePort type service.

When you create a NodePort service in Kubernetes, it exposes your service on a specific port on each node in the cluster. However, by default, the External-IP field remains <none> because the service is not being exposed externally through a load balancer or an Ingress resource.

In the case of a local development environment like Docker Desktop with Kubernetes enabled, the External-IP field will typically show <none> because it doesn't provide a load balancer or an external IP address.

To access your service in such cases, you can use the cluster's IP address or the NodePort. In your example, the service nginx-service is accessible on port 30080 of any node in your cluster's IP address. You can use the cluster's IP along with the NodePort to access your Nginx service in a web browser.

If you need an external IP for your service, you have a few options:

- Use a LoadBalancer service type: If your Kubernetes cluster is running in a cloud provider that supports LoadBalancer services (such as AWS, GCP, or Azure), you can use the LoadBalancer service type. This will provision an external load balancer and assign an external IP to your service.

- Use an Ingress resource: If you want to expose your service using a domain name or path-based routing, you can use an Ingress resource. Ingress allows you to define rules for routing external traffic to your service. However, note that you need an Ingress controller set up in your cluster to handle the Ingress resource.

Use a port-forwarding technique: In a local development environment, you can use port-forwarding to access your service directly from your local machine without an external IP. This allows you to forward traffic from a specific port on your local machine to the service running in the cluster. You can use the kubectl port-forward command to achieve this.

Remember that the availability of these options may depend on your Kubernetes environment and the infrastructure you are using.

