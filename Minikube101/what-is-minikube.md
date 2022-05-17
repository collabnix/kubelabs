# What is Minikube?

For you to work with Kubernetes, you need a Kubernetes cluster. This cluster can be anywhere; on a cloud, on a development server, etc... However, if you wanted to have a test Kubernetes environment for development (or in this case, learning), you need to set up a local cluster. Creating clusters on dedicated machines or the cloud costs money and resources, and this is the problem that Minikube solves.

Minikube sets up and configures a local Kubernetes cluster that runs entirely on your local machine. You can then use the kubeconfig created by Minikube to access this cluster. The best part about this is that it is supported on all major platforms, supports the latest versions of Kubernetes, has a multitude of ways it can be deployed, and has all sorts of advanced features you might expect to find in a normal Kubernetes cluster. It is also actively managed by the community on [https://github.com/kubernetes/minikube](Github).

## Prerequisites

