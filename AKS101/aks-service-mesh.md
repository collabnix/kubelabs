# Service meshes in AKS

## What is a service mesh?

A full section on service meshes is now available. Please [read it](./../ServiceMesh101/what-are-service-meshes.md) if you plan to use service meshes with your cluster.

## Service mesh options

AKS supports all major service meshes such as [istio](https://istio.io/latest/about/service-mesh/), [linkerd](https://linkerd.io/2.11/getting-started/), and [Consul](https://learn.hashicorp.com/tutorials/consul/service-mesh-deploy). These are all separate service meshes that warrant their own section, and we will not delve into these. We will be diving into the [Open Service Mesh](https://docs.openservicemesh.io) which runs well on AKS.

## Open Service mesh

Open Service Mesh gives you to do all the above actions out of the box, and connect right into your AKS cluster (as well as other Azure services). To fully understand how the open service mesh works, we need to take a look at sidecar containers.

### Sidecar container and Open Service Mesh

So why were we talking about sidecar containers in the middle of the discussion about Open Service Meshes? Because sidecar containers facilitate the core of the open service mesh concept. As mentioned before, sidecar containers can seamlessly integrate themselves into existing clusters and add things such as infrastructure support and security to the containers, which is something service meshes aim to do. It loads the [Envoy proxy](https://github.com/envoyproxy/go-control-plane) as a sidecar (Envoy being a control plane implementation) to each instance of your application.

While sidecars can be complex and hard to manage, adding OSM to your cluster could not be simpler. Azure ensures that you can simply use the ```enable-addons``` command to get OSM up and running:

```
az aks enable-addons \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --addons open-service-mesh
```

A comprehensive guide on setting up advanced functionalities of OSM can be found in the [official documentation](https://docs.microsoft.com/en-us/azure/aks/open-service-mesh-deploy-addon-az-cli). You can also find exactly what OSM can and can't offer your cluster in the [OSM Page](https://docs.microsoft.com/en-us/azure/aks/open-service-mesh-about#capabilities-and-features) of the Microsoft docs.

Next, let's look into Kubernetes Driven Autoscalers.

[Next: Kubernetes Event-driven Autoscaling (KEDA)](./aks-keda.md)