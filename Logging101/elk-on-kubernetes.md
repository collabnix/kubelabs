## Setting up the ELK stack on a Kubernetes instance

To set up the ELK stack on Kubernetes, we will be relying on Helm charts. Therefore, make sure you have Helm set up on your machine. If you need a quick refresher on Helm, check out the [Helm section](../Helm101/what-is-helm.md). However, a deep understanding of Helm is not required here. The stack we will be installing is FileBeat, Logstash, Elasticasearch, and Kibana. All of these will ultimately run on the same namespace within containers (pods). Since that will produce container logs, we will be using them as an input data source.

You will also need a Kubernetes cluster ready since that is where everything will be getting deployed to. Once again, I recommend [Minikube](https://minikube.sigs.k8s.io/docs/start/) to set up a cluster on your local machine, but feel free to use any cluster that is available to you.

### Process Overview

Here's a big picture of how this is going to work:

- The container creates logs which get placed in a path
- filebeat reads the logs from the path and sends them to logstash
- logstash transforms and filters the logs before sending them forward to elasticsearch
- Kibana queries elasticsearch and visualizes the log data

Note that logstash here is optional. You could very well send logs directly from filebeat to elasticsearch. However, in a real-world situation, rarely, you wouldn't want to use GROK patterns to match specific patterns that allow Kibana to show the data in a better-formatted manner, or filter logs based on the type of log, or add index patterns that allow the data to be retrieved much faster. Therefore, we will be sending the data to logstash first to transform it.

As you can imagine, all of the above components are quite complex and require multiple resources to be deployed to get up and running. Therefore, we will be using Helm charts for each of the above components that automatically set up all the required resources for us. We could also use the single Kubernetes manifest file that elastic provides us, but the Helm chart allows for better flexibility.

### Setting up

The first component we will look into is filebeat. To set up filebeat, go ahead and get the relevant Helm chart from [its artifacthub page](https://artifacthub.io/packages/helm/elastic/filebeat?modal=install). Then use the provided commands to install the Helm chart:

```
helm repo add elastic https://helm.elastic.co
```

```
helm install my-filebeat elastic/filebeat --version 8.5.1
```

If your kubeconfig file is set properly and it is pointed to your cluster, the command should run with no issues.