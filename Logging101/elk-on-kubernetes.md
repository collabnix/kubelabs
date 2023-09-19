## Setting up the ELK stack on a Kubernetes instance

To set up the ELK stack on Kubernetes, we will be relying on Helm charts. Therefore, make sure you have Helm set up on your machine. If you need a quick refresher on Helm, check out the [Helm section](../Helm101/what-is-helm.md). However, a deep understanding of Helm is not required here. The stack we will be installing is FileBeat, Logstash, Elasticasearch, and Kibana. All of these will ultimately run on the same namespace within containers (pods). Since that will produce container logs, we will be using them as an input data source.

You will also need a Kubernetes cluster ready since that is where everything will be getting deployed to. Once again, I recommend [Minikube](https://minikube.sigs.k8s.io/docs/start/) to set up a cluster on your local machine, but feel free to use any cluster that is available to you.

### Process Overview

Here's a big picture of how this is going to work:

- The container creates logs which get placed in a path
- filebeat reads the logs from the path and sends them to logstash
- logstash transforms and filters the logs before sending them forward to elasticsearch
- Kibana queries elasticsearch and visualizes the log data

Note that logstash here is optional. You could very well send logs directly from filebeat to elasticsearch. However, in a real-world situation, rarely, you wouldn't want to use GROK patterns to match specific patterns that allow Kibana to show the data in a better-formatted manner, or filter logs based on the type of log, or add index patterns that allow the data to be retrieved much faster. If you have a large number of logs, logstash will also act as a buffer and prevent sending all the logs at once to elasticsearch, which would overload it. Therefore, we will be sending the data to logstash first in this example.

As you can imagine, all of the above components are quite complex and require multiple resources to be deployed to get up and running. Therefore, we will be using Helm charts for each of the above components that automatically set up all the required resources for us. We could also use the single Kubernetes manifest file that elastic provides us, but the Helm chart allows for better flexibility.

### Setting up

To keep everything logically grouped together, we will be installing all the components in a namespace called `kube-logging`. So create it:

```
kubectl create ns kube-logging
```

The first component we will look into is filebeat. To set up filebeat, go ahead and get the relevant Helm chart from [its artifacthub page](https://artifacthub.io/packages/helm/elastic/filebeat?modal=install). Then use the provided commands to install the Helm chart:

```
helm repo add elastic https://helm.elastic.co
```

```
helm install filebeat  elastic/filebeat --version 8.5.1 -n kube-logging
```

If your kubeconfig file is set properly and it is pointed to your cluster, the command should run with no issues. You can then open up a terminal instance and run:

```
kubectl get po -n kube-logging
```

This will show you the filebeat pods that have started running in the kube-logging namespace. While the default configuration is meant to work out of the box, it won't fit our specific needs, so let's go ahead and customize it. To get the values.yaml, head back over to the Helm chart page on [Artifact hub](https://artifacthub.io/packages/helm/elastic/filebeat/7.6.1) and click on the "Default Values" option. Download this default values file.

We will start by modifying this file. The values file provides configuration to support running filebeat as both a DaemonSet as well as a regular Deployment. By default, the DaemonSet configuration will be active, but we don't need that right now, so let's go ahead and disable it. Under the `daemonset` section, change `enabled: true` to `enabled: false`.  You can then skip the rest of the DaemonSet section and head over to the `deployment` section. Then set change enabled to true to get filebeat deployed as a deployment. You might notice that the daemonset section and the deployment section are pretty much the same, so you only need to do the configuration for one section for it to work.