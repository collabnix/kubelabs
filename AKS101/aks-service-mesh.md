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

