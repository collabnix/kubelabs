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

If you have used filebeat before, you would be well aware of the `filebeat.yaml`. This is the file where you specify the filebeat configurations, such as where to get the logs from, and where to send the logs to. In this case, we will be declaring the yaml within the values.yaml. There is a basic filebeat.yml defined within the values file to help you get started. We will be changing everything here. Replace this block with the below code:

```
filebeat.yml: |
    filebeat.inputs:
    - input_type: log
      paths:
        - /var/log/containers/*.log
      document_type: mixlog
    output.logstash:
      hosts: ["logstash-logstash:5044"]
```

The path provided above will get all the logs produced by the container. We will be marking these logs as type "mixlog" and filtering these out based on this type later in the flow. The last piece of configuration is `output.logstash` which tells where the log should be sent to. Here, we specify logstash instead of elasticsearch. The filebeat configuration is now complete. We will now handle the second part of the log flow: logstash. As with filebeat, we will be using Helm charts to get logstash up on the Kubernetes cluster. We will also be changing the values file in the same way.

To start, head over to the logstash chart on [Artifact Hub](https://artifacthub.io/packages/helm/elastic/logstash). As with filebeat, download the values file. While in filebeat we had the filebeat.yml to set our configuration, in logstash we have a `logstash.conf`. We will be declaring the logstash conf in the yaml as we did before. Remove any default logstash conf values that may exist, and replace them with:

```
logstashPipeline:
 logstash.conf: |
   input {
     beats {
      type => mixlog
      port => 5044
     }
   }
   filter {
      if [type] == "mixlog" {
        grok {
          match => {
            "message" => "%{TIMESTAMP_ISO8601:timestamp}"
          }
        }
      }
    }
   output { elasticsearch { hosts => "http://elasticsearch:9200" } }
```

In the above config, we declare that we will be getting inputs from filebeat from port 5044 (which is the port filebeat exposes). This port will send logs of type "mixlog" which we declared in the filebeat.yml. Now, logstash will start gathering all logs that filebeat sends from port 5044, which we can either redirect to Elasticsearch or perform some processing on. In this case, we will be using GROK patterns to do the filtering. GROK patterns are very similar to regex patterns and can be used in other log-matching services such as fluentd. In the above config, we declare that for any log to go through, it must have a timestamp. All sorts of filters can applied, and you can find a comprehensive list of all of them [here](https://www.elastic.co/guide/en/logstash/current/filter-plugins.html). There are also other things logstash can do to your logs apart from filtering them. The final thing we do in the config is to redirect the logs to elasticsearch. For this, we specify the host and port of elasticsearch, and that is all it takes.

Note that all of these steps assume that you are running the entire stack on one single namespace. If, for example, you have logstash in one namespace and elasticsearch in another namespace, this above configuration will not work. This is because we are simply referring to elasticsearch with "http://elasticsearch:9200" without providing any namespaces, which means elasticsearch will automatically assume that it should look within the same namespace. If you need to specify a different namespace, you would have to use the full svc name: elasticsearch.different-namespace.svc.cluster.local:9200.

The filebeat configuration is now complete, and we can move on to the next phase of the flow: elasticsearch. As with the previous two components, we will be setting up elasticsearch using the relevant Helm chart. Go to the page in the [Artifact Hub](https://artifacthub.io/packages/helm/elastic/elasticsearch) and get the provided install command:

```
helm install my-elasticsearch elastic/elasticsearch --version 8.5.1
```

As before, there are several values we need to override for the elasticsearch Helm chart.