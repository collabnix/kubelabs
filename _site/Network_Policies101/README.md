# What is a Kubernetes Network Policy?
A network policy is a specification of how groups of pods are allowed to communicate with each other and other network endpoints.NetworkPolicy resources use labels to select pods and define rules which specify what traffic is allowed to the selected pods.
To apply a NetworkPolicy definition in a Kubernetes cluster, the network plugin must support NetworkPolicy. Otherwise, any rules that you apply are useless. Examples of network plugins that support NetworkPolicy include Calico, Cilium, Kube-router, Romana, and Weave Net.

![](img/1.gif)


Do you need a NetworkPolicy resource defined in your cluster? The default Kubernetes policy allows pods to receive traffic from anywhere (these are referred to as non-isolated pods). So unless you are in a development environment, you’ll certainly need a NetworkPolicy in place.