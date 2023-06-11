## Kubesphere lab

### Requirements
First off, you need a Kubernetes cluster. Kubesphere supports deploying on a Linux VM (as well as their own managed Kubesphere cloud), but we will be doing this lab by deploying on a Kubernetes cluster. Since Kubesphere has so many features you will need a fair bit of resources. As such, it is best if the cluster has 4GB memory and at least 3 cores. [Minikube](https://minikube.sigs.k8s.io/docs/start/) is a great way to get a single-node cluster up and running on your local machine. As of the time of writing, minikube supports Kubernetes version 1.26 by default, which is not supported by Kubesphere. So when running minikube, use this command:

```
minikube start --kubernetes-version=v1.23.17 --cpus 3 --memory 4g
```

This sets the latest supported version of Kubernetes for Kubesphere while also setting the required memory and CPU for the cluster.

### Deployment

Now that you have a cluster, let's install Kubesphere. This is a fairly straightforward process. Simple open up your terminal and paste in these kubectl commands:

```
kubectl apply -f https://github.com/kubesphere/ks-installer/releases/download/v3.3.2/kubesphere-installer.yaml

kubectl apply -f https://github.com/kubesphere/ks-installer/releases/download/v3.3.2/cluster-configuration.yaml
```

Now, the installation will begin. After a minute or so, use this command to view the progress:

```
kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l 'app in (ks-install, ks-installer)' -o jsonpath='{.items[0].metadata.name}') -f
```

You will see the installation happening. Note that installation will take a while (around 20 minutes) depending on the speed of your machine and cluster.