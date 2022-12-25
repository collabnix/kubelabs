# GKE Service Mesh

Similar to other cloud Kubernetes providers, GKE also provides support for service meshes. For a quick refresher on what service meshes are, refer to the [service meshes](../ServiceMesh101/what-are-service-meshes.md) section. If you also want to get an insight into how service meshes are supported on Azure, that's is [also convered](../AKS101/aks-service-mesh.md).

This lesson will also assume you know what Istio is. If you would like to read further on the subject, please refer to the [Istio section](../ServiceMesh101/what-is-istio.md). The reason we would be looking at Istio is that we will be talking about the [Anthos Service Mesh](https://cloud.google.com/service-mesh/docs/overview), which is powered by Istio. Anthos also has full support on GCP, making it the easiest service mesh to set up on your GKE cluster.

The Anthos service mesh provides all the usual features you get from a service mesh, such as managing cluster traffic. This includes the ability to load balance services, perform blue-green deployments, and more. The service mesh applies across the entire infrastructure without having any impact on your code so that you don't have to change anything within your existing cluster. It also allows you to perform better monitoring and logging as well as security validation using things such as Anthos Service Mesh access logging, which keeps tabs on which IPs access the cluster, as well as control plane centric encryption modules. An overview of the architecture of the Anthos service mesh can be found below:

![Anthos Service Mesh architecture](mesh-arch.svg)

It's important to note that while Anthos works well with GKE, it is not limited to the Google Cloud Platform. When Anthos runs on GCP, it is used with an ordinary GKE cluster where the control plane is managed by Google while the worker nodes are compute engine instances. Anthos can also be used with other cloud service providers such as AWS and Azure. Alternatively, you could also run Anthos on your on-prem Kubernetes clusters.

Additionally, since Anthos gets applied across your entire infrastructure, you get management over multiple GKE clusters, which is really useful if you are in a large organization running multiple Kubernetes clusters. Anthos also provides a service mesh dashboard that gives you a complete overview of all the services in your mesh (your whole infrastructure). 

Another interesting version of Anthos is Cloud Run for Anthos.