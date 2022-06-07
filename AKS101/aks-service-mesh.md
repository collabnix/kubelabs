# Service meshes in AKS

## What is a service mesh?

Service meshes provide some essential base infrastructure to your cluster. Things such as managing traffic, setting policies and security to your cluster, ensuring robustness of the cluster, etc... Imagine you had sensitive data flowing through your AKS cluster. You would obviously need to encrypt this data for added security. Normally, you would have to do major changes to your application and infrastructure in order to pull this off. However, with service meshes, that is no longer neccessary since the defualt option provided by service meshes can achieve the same goal without touching your infrastructure. 

When introducing new features to your application, it is always good to have canary, nightly, and staging version to ensure that everything is working fine before releasing to stable. Instead of suddenly replacing your stable system with a brand new service, you could use service meshes to slow send a certain percentage of your traffic to your new service. Eventually, this percentage will reach 100%, and then you can get rid of the old service. This is a phased rollout, and is fully supported by service meshes.

If you have a service that gets popular, then load balancing and traffic management is a must. After all, no one is going to use your service if it takes forever to load. You also need to ensure that you service is protected from Denial of Service (DDoS) attacks, and implementing all these security features can ba a hassle. However, service meshes working with AKS simplifies this for you as well.

Finally, good levels of logging and monitoring are cruitial to ensuring that your system is stable in the long run. If your application fails at any point, then you must have a good method to monitor and log these failures so that you may find the root cause of these issues. This is yet another place where service meshes can help.

If you are using service meshes then all of the above features can be easily implemented on to your cluster. Useful, don't you think?

## Service mesh options

AKS supports all major service meshes such as [istio](https://istio.io/latest/about/service-mesh/), [linkerd](https://linkerd.io/2.11/getting-started/), and [Consul](https://learn.hashicorp.com/tutorials/consul/service-mesh-deploy). These are all seperate service meshes that warrant their own section, and we will not dveleve into these. We will be diving into the [Open Service Mesh](https://docs.openservicemesh.io) which runs well on AKS.

## Open Service mesh

Open Service Mesh gives you to do all the above actions out of the box, and connect right into your AKS clust (as well as other Azure services). In order to fully understand how the open service mesh works, we need to take a look at sidecar containers.

### Sidecar containers

Imagine you have an algorithm that converts certain files to a different file type. This algorithm would be complex, and written in a scripting language such as Python. Now, you want to use this algorithm to complement a container that was built with Java. This means that you would have to spend time and resources re-writing that algorithm in Java, instead of moving forward with the development process, thereby decreasing efficieny. This is where sidecar containers come in. They run alongside your existing container (hence the name sidecar), and share the same resources, authorizations, networks, etc... while being a completely different container. This means that this sidecar container can have your Python algorithm in it and still work nice alongside your Java container. 

This isn't the only use for sidecard containers. Since the sidecar container share all sorts of resources with the main container, it can continously pull logs and other metrics, as well as enforce security on your existing container with ease. This makes it a powerful tool, and ideal for use by a service mesh. 

However, it is not recommended to use sidecar containers freely, these are advanced paradigm that can easily make your cluster unnecessarily complicated. 

### Sidecar container and Open Service Mesh

So why were we talking about sidecar containers in the middle of the discussion about Open Service Meshes? Because sidecar containers facilitate the core of the open service mesh concept. As mentioned before, sidecar containers can seamlessly integrate themselves into existing clusters and add things such as infrastructure support and security to the containers, which is something service meshes aim to do. It loads the [Envoy proxy](https://github.com/envoyproxy/go-control-plane) as a sidecar (Envoy being a control plane implementation) to each instance of your application.

While sidecars can be complex and hard to manage, adding OSM to your cluster could not be simpler. Azure ensures that you can simply use the ```enable-addons``` command to get OSM up and running:

```
az aks enable-addons \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --addons open-service-mesh
```

A comprehensive guide on setting up advances functionalities of OSM can be found in the [official documentation](https://docs.microsoft.com/en-us/azure/aks/open-service-mesh-deploy-addon-az-cli). You can also find exactly what OSM can and can't offer your cluster in the [OSM Page](https://docs.microsoft.com/en-us/azure/aks/open-service-mesh-about#capabilities-and-features) of the Microsoft docs.

Next, let's look into Kubernetes Driven Autoscalers.

[Next: Kubernetes Event-driven Autoscaling (KEDA)](./aks-keda.md)

