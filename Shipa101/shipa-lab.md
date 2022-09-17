# Lab

## Installing Shipa

As always, you need a cluster before you start. For this, you can either use any cluster that you have (on a Linux VM, on the cloud, etc...), or you can use [Minikube](https://minikube.sigs.k8s.io/docs/start/) to start a single node cluster on your local machine.

Next, we will be using [Helm](../Helm101/what-is-helm.md) to install Shipa. Helm allows you to install multiple resources that are packaged together as a chart, which is a lot faster than creating all the resources one by one manually. If you need a refresher on Helm, head over to the [Helm section](../Helm101/what-is-helm.md).

To start, add the ```shipa-charts``` helm repo:

```
helm repo add shipa-charts https://shipa-charts.storage.googleapis.com

helm repo update
```

Next, install the helm chart: 

```
helm upgrade --install shipa shipa-charts/shipa \
--create-namespace --namespace shipa-system \
--timeout=15m \
--set=auth.adminUser=admin@acme.com \
--set=auth.adminPassword=this-is-a-secret \
--set=shipaCluster.ingress.serviceType=ClusterIP \
--set=shipaCluster.ingress.clusterIp=10.100.10.10
```

If you are using Minikube, you also need to add routes to the nginx ingress:

```
sudo route -n add -host -net 10.100.10.10/32 $(minikube ip )
```

You also need to get the Shipa CLI so that you can execute Shipa commands using the command line. To do that, use curl:

```
curl -s https://storage.googleapis.com/shipa-client/install.sh | bash
```

You can also use brew:

```
brew tap shipa-corp/CLI

brew install shipa-cli
```

If you are using Minkube, also change the local Shipa instance so that it points at your Shipa CLI:

```
shipa target add -s shipa-minikube 10.100.10.10
```

Now you essentially have Shipa fully installed. As the last step, let's bring up the Shipa dashboard. To do that, first login (using the dummy credentials your specified), and then list the Shipa instances:

```
shipa login

shipa app list
```

This should output the list of instances, which should also show a link in the ```Address``` column. Use this to open the dashboard. If you have any trouble accessing this link, you may need to use port forwarding. Use:

```
kubectl get svc -n shipa-system
```

You will get a list of ports that are exposed using ClusterIP. You need to choose the one called ```dashboard-web-1``` running on port 8888. ClusterIP is an internal network port and doesn't allow external connections, so we will forward the port:

```
kubectl port-forward -n shipa-system svc/dashboard-web-1 8888
```

You can then open up the page on localhost (port 8888) and follow the three steps to gain access to the Shipa dashboard. Once you're in, the installation part of Shipa is complete.

## Separating the teams