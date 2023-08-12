# Helm 101

## What is Helm?

If you have used a Linux environment (and it's safe to assume you have), then you are already acquainted with package managers (apt, yum). Helm basically the same thing, but for Kubernetes. Imagine you want to add MongoDB to your existing Kubernetes implementation, and this resource comes with services, deployments, secrets, stateful sets, etc... Taking the Yaml files of each of these resources and deploying them one by one into your Kubernetes cluster would be both cumbersome and time-consuming. Additionally, this task would also be repetitive since various developers around the world may gather these exact same Yaml files to set up MongoDB over and over again. This is where **Helm Charts** come in.

## What are Helm charts? 

A Helm chart is, simply put, a collection of Yaml files. Imagine someone takes all the necessary Yaml files to set up MongoDB and then bundles them into a package. Similar to how normal package managers work, it would then be a simple matter to upload this package into a common repository. Once that's done, any other developer looking to set up MongoDB would only have to download this package instead of doing the legwork themselves by simply writing:

```
helm install <chart>
```

## What is a Helm repository?

This is a place where Helm charts are storedm and where you can download them.  [Artifact Hub](https://artifacthub.io) is a centralised repository for Helm packages and is extensively used by Kubernetes developers in their daily work. 

## What is a Helm release?

This is once single instance of a chart. Even within a single Kubernetes cluster, the same chart can be installed multiple times. In order to facilitiate this, each installation is considered to be a release. So if you want 2 instances of MongoDb running in your cluster, it is just a matter of installing the chart twice.

## Helm as a templating engine 

If you have used Kubernetes for even a simple project, you would have noticed that the Yaml files you create for various resources tend to get repetitive. For instance, deployment files may be identical to each other apart from the image they use. This means you would end up creating a deployment file for each image even though they have only minor differences. Helm can step into the rescue here as well, by introducing templating to Yaml's. Now, you could get rid of all the duplicates and replace them with a single Yaml file. But what about the parts that are different? Well, Helm allows you to dynamically set those values. So instead of hardcoding the image name like this:

```
...
spec:
    containers:
    - name: nginx
      image: nginx
...
```

You could convert it into a template:

```
...
spec:
    containers:
    - name: {{ .Values.name }}
      image: {{ .Values.container.image }}
...
```

Then set the name and image dynamically.

Now that we have a broad understanding of how Helm works, let's first install a helm chart and see what this is all about, before taking a deep-dive into the specifics, starting with a deeper introduction to Helm charts.

[Next: Installing a Helm Chart](installing-a-chart.md)