# Lab

As always, you need a cluster before you start. For this, you can either use any cluster that you have (on a Linux VM, on the cloud, etc...), or you can use [Minikube](https://minikube.sigs.k8s.io/docs/start/) to start a single node cluster on your local machine.

Next, we will be using [Helm](../Helm101/what-is-helm.md) to install Shipa. Helm allows you to install multiple resources that are packaged together as a chart, which is a lot faster than creating all the resources one by one manually. If you need a refresher on Helm, head over to the [Helm section](../Helm101/what-is-helm.md).

To start, add the ```shipa-charts``` helm repo:

```
helm repo add shipa-charts https://shipa-charts.storage.googleapis.com

helm repo update
```
