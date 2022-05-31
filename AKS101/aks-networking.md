# AKS Networking

When deploying a cluster, there are two networking models to consider:

- Kubenet networking
- Azure Container Networking Interface (CNI) networking

## Kubenet networking

This model works off the [Kubenet](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/#kubenet) Kubernetes plugin, and is the default configuration for AKS. Since you would want to integrate your cluster with services across Azure, you would rely on your Azure Virtual Network (VNet). Your VNet is essentially your private network within Azure, and allows unrestricted communication between you Azure resoureces. It also allows communication with external resources, as well as the internet, and this is what Kubenet will be using as well. Both your nodes and your pods will get IP addresses from VNet, grouped by two different address spaces.

## Azure Container Networking Interface (CNI) networking

This is a slightly more advanced form of networking, and will require some planning ahead. This method allows pod to be accessed directly using the IP addresses they get from the subnet. The number of IP addresses needed are set aside for the node. Since this is a hard limit, this is where planning is needed to prevent exshausting IP addresses.

## Deploying networks

