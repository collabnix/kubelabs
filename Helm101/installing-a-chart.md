# Installing a chart

The easiest way to get into the subject is to do it hands-on. So let's go ahead and install a Helm chart.

Firstly, you must have an active Kubernetes cluster. The easiest way to get this up and running is using [Minikube](https://minikube.sigs.k8s.io/docs/start/).

If you have a Kubernetes cluster up and running, then it's time to install Helm. The installation is fairly straightforward, and the full installation steps can be found [here](https://helm.sh/docs/intro/install/). **Make sure you install Helm 3**. There are some [significant changes](https://helm.sh/docs/faq/changes_since_helm2/) between Helm 2 and Helm 3, which means that the below tutorial will not work if you use Helm 2 instead.

Once this is done, you can add a chart repository. Note that this isn't the actual chart. Rather, it is the repository where various packages are stored. The [Artifact Hub](https://artifacthub.io/packages/search?kind=0) has a comprehensive list of chart repositories. We will install the bitnami chart repository:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
```

Once this command has run, you can explore this repo which will show you all the available charts within this repository.

```bash
helm search repo bitnami
```

Next, let's install an example chart. Before we do that, we have to ensure we get the latest list of charts. Do that using:

```bash
helm repo update 
```

The chart we will install is the MySql chart. Install that using:

```bash
helm install bitnami/mysql --generate-name
```

Note that ```--generate-name``` will generate a name for the release. You can also set your own name like so:

```bash
helm install my-custom-name bitnami/mysql
```

The chart you just installed is considered a **release**. This means that each time you install a chart. a new release is created. Thanks to this, you can go ahead and install a chart multiple times into the same cluster.

Let us now explore the MySQL chart we just installed. Run:

```bash
helm show chart bitnami/mysql
```

This will output the details (metadata) about the chart. For example, you get details on the repository, version, and keywords this chart will match for when you search on Artifact Hub. Basically, anything that makes this specific chart stand out. You can get now get a list of available helm charts by running ```helm list```. You should be able to see the unique name of this helm chart from here (something like mysql-xxxxx). This name can be used to get the status of the helm chart:

```bash
helm status mysql-1652869723
```

Uninstalling the chart is as easy as calling ```helm uninstall``` with the chart name. You could also use the flag ```--keep-history``` if you want to get rid of the chart but keep the release history.

Now that we have the basics out of the way, let's do a deep dive into Helm charts.

[Next: Helm Charts Deep Dive](helm-charts.md)