## Setting up the ELK stack on a Kubernetes instance

To set up the ELK stack on Kubernetes, we will be relying on Helm charts. Therefore, make sure you have Helm set up on your machine. If you need a quick refresher on Helm, check out the [Helm section](../Helm101/what-is-helm.md). However, a deep understanding of Helm is not required here. The stack we will be installing is FileBeat, Logstash, Elasticasearch, and Kibana. All of these will ultimately run on the same namespace within containers (pods). Since that will produce container logs, we will be using them as an input data source.

### Process Overview

Here's a big picture of how this is going to work:

- The container creates logs which get placed in a path
- filebeat reads the logs from the path and sends them to logstash
- logstash transforms and filters the logs before sending them forward to elasticsearch
- Kibana queries elasticsearch and visualizes the log data

Note that logstash here is optional. You could very well send logs directly from filebeat to elasticsearch. However, in a real-world situation, rarely, you wouldn't want to use GROK patterns to match specific patterns that allow Kibana to show the data in a better-formatted manner, or filter logs based on the type of log, or add index patterns that allow the data to be retrieved much faster.