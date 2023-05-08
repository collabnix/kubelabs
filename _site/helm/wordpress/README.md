# Setting up WordPress Application on GKE Cluster using Helm


## Pre-requisite:

- GKE Cluster
- Google Cloud Engine API Enabled


## Verify the GKE Cluster Nodes

```
[Captains-Bay]🚩 >  kubectl get nodes
NAME                                      STATUS   ROLES    AGE   VERSION
gke-myk8slab-default-pool-ce0301d1-ndjw   Ready    <none>   75m   v1.14.10-gke.36
gke-myk8slab-default-pool-ce0301d1-s1qn   Ready    <none>   75m   v1.14.10-gke.36
gke-myk8slab-default-pool-ce0301d1-zwtd   Ready    <none>   75m   v1.14.10-gke.36
[Captains-Bay]🚩 >
```

## Installing Helm on your macbook

```
brew install helm
```

## Removing the existing Helm repo, if any

```
helm repo list
NAME   	URL
brigade	https://brigadecore.github.io/charts
```

```
helm repo remove brigade
"brigade" has been removed from your repositories
```

## Ensure that no repo is being displayed

```
helm repo list
Error: no repositories to show
```

## Add Helm Repo

```
helm repo add bitnami https://charts.bitnami.com/bitnami
"bitnami" has been added to your repositories
```

```
[Captains-Bay]🚩 >  helm repo list
NAME   	URL
stable 	https://kubernetes-charts.storage.googleapis.com
bitnami	https://charts.bitnami.com/bitnami
```

```bash
$ helm repo add bitnami https://charts.bitnami.com/bitnami
$ helm install my-release bitnami/<chart>           # Helm 3
$ helm install --name my-release bitnami/<chart>    # Helm 2
```

To update an exisiting _stable_ deployment with a chart hosted in the bitnami repository you can execute

```bash
$ helm repo add bitnami https://charts.bitnami.com/bitnami
$ helm upgrade my-release bitnami/<chart>
```

## Deploy Helm

```
helm install mycollabnixblog -f values.yaml stable/wordpress
```

## Accessing  WordPress site from outside the cluster

First check the status

```
kubectl get svc --namespace default -w myblog-wordpress
```

```
export SERVICE_IP=$(kubectl get svc --namespace default myblog-wordpress --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
```

```
echo "WordPress URL: http://$SERVICE_IP/"
```

```
echo "WordPress Admin URL: http://$SERVICE_IP/admin"
```

In my case:

```
[Captains-Bay]🚩 >  echo "WordPress URL: http://$SERVICE_IP/"
WordPress URL: http://35.194.179.135/
[Captains-Bay]🚩 >  echo "WordPress Admin URL: http://$SERVICE_IP/admin"
WordPress Admin URL: http://35.194.179.135/admin
[Captains-Bay]🚩 >
```






