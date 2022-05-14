# Creating a service catalog

We will be creating a sample service catalog in [Minikube](https://minikube.sigs.k8s.io/docs/start/). Note that it is not necessary to use Minikube, and you can choose to use a cluster that is hosted on the cloud.

However, there are several requirements with regards to the Kubernetes version running on the cluster, the etcd datastore, RBAC, and the DNS used within this cluster. If you were to go ahead and get the latest version of minikube, all these requirements would be fulfilled, and you can jump right into the implementation. Otherwise refer to [the official docs](https://kubernetes.io/docs/tasks/service-catalog/install-service-catalog-using-helm/) for the prerequisites.

Finally, we will be using [Helm](https://www.helm.sh). Helm is, simply put, a Kubernetes package manager. This can help us install a service catalog very quickly, so first go ahead and [install Helm](https://helm.sh/docs/intro/).

Run ```helm --init``` to start helm, and let's get to the actual implementation.
