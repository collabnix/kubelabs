# What is a Kubernetes Network Policy?

If you were to create two namespaces in your cluster and start two nginx pods in the two different namespaces, you would notice that each pod is able to communicate with all the other pods. This is great if you are running a single node cluster on your local computer where you don't have to worry about pod security. However, when it comes to production clusters or large clusters within organization where several teams deploy their workloads in different namespaces, you likely don't want your clusters interfering with each other. One option is to use [virtual clsuter](../Loft101/what-is-loft.md). The other more obvious way is by introducing Kubernetes network policies.

A network policy is a specification of how groups of pods are allowed to communicate with each other and other network endpoints. NetworkPolicy resources use labels to select pods and define rules which specify what traffic is allowed to the selected pods.
To apply a NetworkPolicy definition in a Kubernetes cluster, the network plugin must support NetworkPolicy. Otherwise, any rules that you apply are useless. Examples of network plugins that support NetworkPolicy include Calico, Cilium, Kube-router, Romana, and Weave Net.

![](img/1.gif)


Do you need a NetworkPolicy resource defined in your cluster? The default Kubernetes policy allows pods to receive traffic from anywhere (these are referred to as non-isolated pods). So unless you are in a development environment, you’ll certainly need a NetworkPolicy in place. So let's take a look at creating your first network policy.

[Next: Creating a network policy](./First_Network_Policy.md)