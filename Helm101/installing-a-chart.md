# Installing a chart

The easiest way to get into the subject is to do it hands-on. So lets go ahead and install a Helm chart.

Firstly, you must have an active Kubernetes cluster. The easiest way to get this up and running is using [Minikube](https://minikube.sigs.k8s.io/docs/start/).

If you have a Kubernetes cluster up and running, then it's time to install Helm. The installation is fairly straightforward, and the full installation steps can be found [here](https://helm.sh/docs/intro/install/).

Once this is done, you can add a chart repository. Note that this isn't the actual chart. Rather, it is the repository where various packages are stored. The [Artifact Hub](https://artifacthub.io/packages/search?kind=0) has a comprehensive list of chart repositories. We will install the bitnami chart repository:

```
helm repo add bitnami https://charts.bitnami.com/bitnami
```

Once this command has run, you can explore this repo which will show you all the available charts within this repository.

```
helm search repo bitnami
```

Next, let's install an example chart. Before we do that, we have to ensure we get the latest list of charts. Do that using:

```
helm repo update 
```

The chart we will install is the MySql chart. Install that using:

```
helm install bitnami/mysql --generate-name
```

Note that ```--generate-name``` will generate a name for the release. You ca also set your own name like so:

```
helm install my-custom-name bitnami/mysql
```