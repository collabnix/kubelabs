# What are Kubernetes Services?

Say, you have pods running nginx in a flat, cluster wide, address space. In theory, you could talk to these pods directly, but what happens when a node dies? The pods die with it, and the Deployment will create new ones, with different IPs. This is the problem a Service solves.


Kubernetes Pods are mortal. They are born and when they die, they are not resurrected. If you use a Deployment to run your app, it can create and destroy Pods dynamically. Each Pod gets its own IP address, however in a Deployment, the set of Pods running in one moment in time could be different from the set of Pods running that application a moment later.

This leads to a problem: if some set of Pods (call them “backends”) provides functionality to other Pods (call them “frontends”) inside your cluster, how do the frontends find out and keep track of which IP address to connect to, so that the frontend can use the backend part of the workload?

Enter Services


A Kubernetes Service is an abstraction which defines a logical set of Pods running somewhere in your cluster, that all provide the same functionality. When created, each Service is assigned a unique IP address (also called clusterIP). This address is tied to the lifespan of the Service, and will not change while the Service is alive. Pods can be configured to talk to the Service, and know that communication to the Service will be automatically load-balanced out to some pod that is a member of the Service.

## Deploying  a Kubernetes Service

Like all other Kubernetes objects, a Service can be defined using a YAML or JSON file that contains the necessary definitions (they can also be created using just the command line, but this is not the recommended practice). Let’s create a NodeJS service definition. It may look like the following:

```
git clone https://github.com/collabnix/kubelabs
cd kubelabs/Services101/
kubectl apply -f nginx-svc.yaml
```

This specification will create a Service which targets TCP port 80 on any Pod with the run: my-nginx label, and expose it on an abstracted Service port (targetPort: is the port the container accepts traffic on, port: is the abstracted Service port, which can be any port other pods use to access the Service). View Service API object to see the list of supported fields in service definition. Check your Service

```
kubectl get svc my-nginx
```



## Service Exposing More Than One Port

Kubernetes Services allow you to define more than one port per service definition. Let’s see how a web server service definition file may look like:

```
apiVersion: v1
kind: Service
metadata:
  name: webserver
spec:
 selector:
   app: web
  ports:
  - name: http
    port: 80
    targetPort: 80
  - name: https
    port: 443
    targetPort: 443
  ```
  
  Notice that if you are defining more than one port in a service, you must provide a name for each port so that they are recognizable.



## Kubernetes Service Without Pods?

While the traditional use of a Kubernetes Service is to abstract one or more pods behind a layer, services can do more than that. Consider the following use cases where services do not work on pods:

You need to access an API outside your cluster (examples: weather, stocks, currency rates).
You have a service in another Kubernetes cluster that you need to contact.
You need to shift some of your infrastructure components to Kubernetes. But, since you’re still evaluating the technology, you need it to communicate with some backend applications that are still outside the cluster.
You have another service in another namespace that you need to reach.
The common thing here is that the service will not be pointing to pods. It’ll be communicating with other resources inside or outside your cluster. Let’s create a service definition that will route traffic to an external IP address:

```
apiVersion: v1
kind: Service
metadata:
  name: webserver
spec:
 selector:
   app: web
  ports:
  - name: http
    port: 80
    targetPort: 80
  - name: https
    port: 443
    targetPort: 443
   ```

Here, we have a service that connects to an external NodeJS backend on port 3000. But, this definition does not have pod selectors. It doesn’t even have the external IP address of the backend! So, how will the service route traffic then?

Normally, a service uses an Endpoint object behind the scenes to map to the IP addresses of the pods that match its selector.

## Service Discovery

Let’s revisit our web application example. You are writing the configuration files for Nginx and you need to specify an IP address or URL to which web server shall route backend requests. For demonstration purposes, here’s a sample Nginx configuration snippet for proxying requests:

```
server {
  listen 80;

  server_name myapp.example.com;

  location /api {
      proxy_pass http://??/;
  }
}
```

The proxy_pass part here must point to the service’s IP address or DNS name to be able to reach one of the NodeJS pods. In Kubernetes, there are two ways to discover services: (1) environment variables, or (2) DNS. let’s talk about each one of them in a bit of detail.



## Connectivity Methods

If you reached that far, you are able to contact your services by name. Whether you’re using environment variables or you’ve deployed a DNS, you get the service name resolved to an IP address. Now you want to be serious about it and make it accessible from outside your cluster? There are three ways to do that:

### CLusterIP

The ClusterIP is the default service type. Kubernetes will assign an internal IP address to your service. This IP address is reachable only from inside the cluster. You can - optionally - set this IP in the service definition file. Think of the case when you have a DNS record that you don’t want to change and you want the name to resolve to the same IP address. You can do this by defining the clusterIP part of the service definition as follows:

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

However, you cannot just add any IP address. It must be within the service-cluster-ip-range, which is a range of IP addresses assigned to the service by the Kubernetes API server. You can get this range through a simple kubectl command as follows:

```
kubectl cluster-info dump | grep service-cluster-ip-range
```

You can also set the clusterIP to none, effectively creating a Headless Service.

## Headless Service In Kubernetes?

As mentioned, the default behavior of Kubernetes is to assign an internal IP address to the service. Through this IP address, the service will proxy and load-balance the requests to the pods behind. If we explicitly set this IP address (clusterIP) to none, this is like telling Kubernetes “I don’t need load balancing or proxying, just connect me to the first available pod”.

Let’s consider a common use case. If you host, for example, MongoDB on a single pod, you will need a service definition on top of it to take care of the pod being restarted and acquiring a new IP address. But you don’t need any load balancing or routing. You only need the service to patch the request to the backend pod. Hence, the name: headless: a service that does have an IP.

But, what if a headless service was created and was managing more than one pod? In this case, any query to the service’s DNS name will return a list of all the pods managed by this service. The request will accept the first IP address returned. Obviously, this is not the best load-balancing algorithm if at all. The bottom line here, use a headless service when you need a single pod.


### NodePort

This is one of the service types that are used when you want to enable external connectivity to your service. If you’re having four Nginx pods, the NodePort service type is going to use the IP address of any node in the cluster combined with a specific port to route traffic to those pods. The following graph will demonstrate the idea:

You can use the IP address of any node, the service will receive the request and route it to one of the pods.

A service definition file for a service of type NodePort may look like this:

```
apiVersion: v1
kind: Service
metadata:
  name: frontend
spec:
  type: NodePort
  ports:
    - port: 80
      nodePort: 30000
      targetPort: 80
  selector:
    app: web
```

Manually allocating a port to the service is optional. If left undefined, Kubernetes will automatically assign one. It must be in the range of 30000-32767. If you are going to choose it, ensure that the port was not already used by another service. Otherwise, Kubernetes will report that the API transaction has failed.

Notice that you must always anticipate the event of a node going down and its IP address becomes no longer reachable. The best practice here is to place a load balancer above your nodes.

### LoadBalancer

his service type works when you are using a cloud provider to host your Kubernetes cluster. When you choose LoadBalancer as the service type, the cluster will contact the cloud provider and create a load balancer. Traffic arriving at this load balancer will be forwarded to the backend pods. The specifics of this process is dependent on how each provider implements its load balancing technology.

Different cloud providers handle load balancer provisioning differently. For example, some providers allow you to assign an IP address to the component, while others choose to assign short-lived addresses that constantly change. Kubernetes was designed to be highly portable. You can add loadBalancerIP to the service definition file. If the provider supports it, it will be implemented. Otherwise, it will be ignored. Let’s have a sample service definition that uses LoadBalancer as its type:

```
apiVersion: v1
kind: Service
metadata:
  name: frontend
spec:
  type: LoadBalancer
  loadBalancerIP: 78.11.24.19
  selector:
    app: web
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

One of the main differences between the LoadBalancer and the NodePort service types is that in the latter you get to choose your own load balancing layer. You are not bound to the cloud provider’s implementation
