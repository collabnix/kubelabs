# AKS Networking

When deploying a cluster, there are two networking models to consider:

- Kubenet networking
- Azure Container Networking Interface (CNI) networking

## Kubenet networking

This model works off the [Kubenet](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/#kubenet) Kubernetes plugin, and is the default configuration for AKS. Since you would want to integrate your cluster with services across Azure, you would rely on your Azure Virtual Network (VNet). Your VNet is essentially your private network within Azure, and allows unrestricted communication between you Azure resoureces. It also allows communication with external resources, as well as the internet, and this is what Kubenet will be using as well. Both your nodes and your pods will get IP addresses from VNet, grouped by two different address spaces. That is to say, pods don't get real IP's. Since they reside in different address spaces, they have to use IP forwarding and Azure routing services. If you are not sure about these concepts, feel free to take a look at how traffic gets routed around Azue VNets from the [official docs](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview). Any resources that need to be addressed that are outide the Azure VNet get accessed by NAT (Network Address Translation). Once again, if this concept is unfamiliar to you, the [official docs](https://docs.microsoft.com/en-us/azure/virtual-network/nat-gateway/nat-overview) are you best friend.

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

Unlike Kubenet, where the pods didn't get real IPs, using CNI's assigns real routable IP addresses to pods. This is a slightly more advanced form of networking and will require some planning ahead. This method allows the pod to be accessed directly using the IP addresses they get from the subnet. The number of IP addresses needed is set aside for the node. Since this is a hard limit, this is where planning is needed to prevent exhausting IP addresses. Both pods and nodes get IPs from the same subnet and therefore support up to 250 pods per node.

So how would a pod communicate between resources? If the resource is within the same VNet, the target resource will see the pod's IP directly, while if the resource is outside the VNet, then the target resource sees the node IP. Not the pod IP.

### Advantages

There are a couple of advantages to using CNI, which contrasts with Kubenet:

- Supports [Azure network policies](https://docs.microsoft.com/en-us/azure/virtual-network/policy-reference) and [Windows Containers](https://docs.microsoft.com/en-us/virtualization/windowscontainers/about/)
- No additional latency since each pod has its own IP address

### Disadvantages

- Proper planning needed to prevent IP address exhaustion
- Setup is more complex

Next, let's talk about how to manage roles in AKS.

[Next: AKS IAM](./aks-iam.md)