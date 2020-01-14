# What are Kubernetes Services?

Kubernetes Pods are mortal. They are born and when they die, they are not resurrected. If you use a Deployment to run your app, it can create and destroy Pods dynamically. Each Pod gets its own IP address, however in a Deployment, the set of Pods running in one moment in time could be different from the set of Pods running that application a moment later.

This leads to a problem: if some set of Pods (call them “backends”) provides functionality to other Pods (call them “frontends”) inside your cluster, how do the frontends find out and keep track of which IP address to connect to, so that the frontend can use the backend part of the workload?

Enter Services

Service is an abstraction which defines a logical set of Pods and a policy by which to access them (sometimes this pattern is called a micro-service). Service acts as a layer above the pods. It is always aware of the pods that it manages: their count, their internal IP addresses, the ports they expose and so on. Service can be defined using a YAML or JSON file that contains the necessary definitions.

## Deploying  a Kubernetes Service

Like all other Kubernetes objects, a Service can be defined using a YAML or JSON file that contains the necessary definitions (they can also be created using just the command line, but this is not the recommended practice). Let’s create a NodeJS service definition. It may look like the following:

```
apiVersion: v1
kind: Service
metadata:
  name: external-backend
spec:
  ports:
  - protocol: TCP
    port: 3000
    targetPort: 3000
  clusterIP: 10.96.0.1
  ```
  
 -  The file starts with defining the API version on which it will contact the Kubernetes API server.
 - Then, it defines the kind of object that it intends to manage: a Service.
 - The metadata contains the name that this service. Later on, applications will use this name to communicate with the service.
 - The spec part defines a selector. This is where we inform the service which pods will come under its control. Any pod that has a label “app=nodejs” will be handled by our service.
 - The spec also defines how our service will handle the network in the ports array. Each port will have a protocol (TCP in our example, but services support UDP and other protocols), a port number that will be exposed, and a targetPort on which the service will contact the target pod(s). In our example, the pod will be available on port 80, but it will reach its pods on port 3000 (handled by NodeJS).



## Service Exposing More Than One Port



## Kubernetes Service Without Pods?



## Service Discovery


## Connectivity Methods



## Headless Service In Kubernetes?


