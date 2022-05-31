# AKS Networking

When deploying a cluster, there are two networking models to consider:

- Kubenet networking
- Azure Container Networking Interface (CNI) networking

## Kubenet networking

This model works off the [Kubenet](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/#kubenet) Kubernetes plugin, and is the default configuration for AKS. Since you would want to integrate your cluster with services across Azure, you would rely on your Azure Virtual Network (VNet). Your VNet is essentially your private network within Azure, and allows unrestricted communication between you Azure resoureces. It also allows communication with external resources, as well as the internet, and this is what Kubenet will be using as well. Both your nodes and your pods will get IP addresses from VNet, grouped by two different address spaces. Since they reside in different address spaces, they have to use IP forwarding and Azure routing services. If you are not sure about these concepts, feel free to take a look at how traffic gets routed around Azue VNets from the [official docs](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview). Any resources that need to be addressed that are outide the Azure VNet get accessed by NAT (Network Address Translation). Once again, if this concept is unfamiliar to you, the [official docs](https://docs.microsoft.com/en-us/azure/virtual-network/nat-gateway/nat-overview) are you best friend.

### Advantages

Why would you want to use Kubenet? There are a couple of reasons:

- Not too much pre-planning required
- Little setup time (default option)
- Only node get real IP addresses, not pods, which means you don't need as many allocatable IP addresses.

### Disadvantages

There are several disadvantages of Kubenet, which can make organizations consider Azure CNI instead. They are:

- User defined routes can be hard to manage as your cluster gets bigger
- Since pods don't have IP addresses, there is addional latency when communicating among nodes
- You can only have one AKS cluster per subnet

## Azure Container Networking Interface (CNI) networking

This is a slightly more advanced form of networking, and will require some planning ahead. This method allows pod to be accessed directly using the IP addresses they get from the subnet. The number of IP addresses needed are set aside for the node. Since this is a hard limit, this is where planning is needed to prevent exshausting IP addresses.
