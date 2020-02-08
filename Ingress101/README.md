## What is an Ingress?

- In Kubernetes, an Ingress is an object that allows access to your Kubernetes services from outside the Kubernetes cluster. You configure access by creating a collection of rules that define which inbound connections reach which services.

- This lets you consolidate your routing rules into a single resource. For example, you might want to send requests to example.com/api/v1/ to an api-v1 service, and requests to example.com/api/v2/ to the api-v2 service. With an Ingress, you can easily set this up without creating a bunch of LoadBalancers or exposing each service on the Node.


### Kubernetes Ingress vs LoadBalancer vs NodePort

These options all do the same thing. They let you expose a service to external network requests. 
They let you send a request from outside the Kubernetes cluster to a service inside the cluster.





### NodePort 

![](https://raw.githubusercontent.com/collabnix/kubelabs/master/Ingress101/nodeport.png)

- NodePort is a configuration setting you declare in a service’s YAML. Set the service spec’s type to NodePort. Then, Kubernetes will allocate a specific port on each Node to that service, and any request to your cluster on that port gets forwarded to the service.

- This is cool and easy, it’s just not super robust. You don’t know what port your service is going to be allocated, and the port might get re-allocated at some point.

### LoadBalancer

![](https://raw.githubusercontent.com/collabnix/kubelabs/master/Ingress101/loadbalancer.png)

- You can set a service to be of type LoadBalancer the same way you’d set NodePort— specify the type property in the service’s YAML. There needs to be some external load balancer functionality in the cluster, typically implemented by a cloud provider.

- This is typically heavily dependent on the cloud provider—GKE creates a Network Load Balancer with an IP address that you can use to access your service.

- Every time you want to expose a service to the outside world, you have to create a new LoadBalancer and get an IP address.

## Ingress

![](https://raw.githubusercontent.com/collabnix/kubelabs/master/Ingress101/ingress.png)

- NodePort and LoadBalancer let you expose a service by specifying that value in the service’s type. Ingress, on the other hand, is a completely independent resource to your service. You declare, create and destroy it separately to your services.

- This makes it decoupled and isolated from the services you want to expose. It also helps you to consolidate routing rules into one place.

- The one downside is that you need to configure an Ingress Controller for your cluster. But that’s pretty easy—in this example, we’ll use the Nginx Ingress Controller.

## How to Use Nginx Ingress Controller


