# What is Elasticsearch

Elasticsearch is simply a data store. This is similar to a database, with some key differences. First of all, this is a JSON-based datastore that is very unstructured. The reason for the unstructuredness is due to the nature of the problem Elasticsearch aims to solve. We have brought forward Elasticsearch as an alternative to simply writing logs to a file, and in the same way, an ordinary file is unstructured, this datastore also needs to have the same properties. This allows it to collect data from various sources such as application trace files, metrics, and plain text logs.

Secondly, you interact with the DB using REST API calls. If you have used something like CouchDB before, this concept should be familiar to you. Now, you might notice right away that the architecture here is rather different from either RDMBS or NoSql databases, but it really isn't that far off. Instead of DBs, you have indexes, and tables are replaced with patterns or types. Similar to NoSql databases, rows are replaced with documents, and columns are replaced with fields. So basically, Elasticsearch isn't a brand new concept, and you can try to match it up with what you already know about databases to understand the concepts.

## ELK Stack

Elasticsearch, despite how powerful it is, is only a datastore. This means that it isn't of much use alone. Instead of having heaps of data in a text file, you would now have heaps of data in a data store. For us to start making sense of this data, we should take the ELK stack into consideration. 

ELK stands for: 
- Elasticsearch
- LogStash
- Kibana

We already know what the "E" stands for, so let's skip ahead to the "L"

### LogStash

Let's begin with LogStash. This is what actually takes in that data. The input source. This could be anything from a log file to Kafka to an S3 bucket. LogStash is responsible for accepting data, transforming it, and stashing all that data somewhere. 

You must have guessed where the "somewhere" is. LogStash feeds data directly into Elasticsearch, which handles the long-term storing of data. Note that at this stage, the data would have already been transformed. However, there is no hard limitation saying that LogStash only works with Elasticsearch. It could also dump the data in a DB such as MongoDB, a large-scale file system like Hadoop, or a different S3 bucket. I needed, you could even have LogStash output data to multiple sources at a time.

Now I did say that LogStash transforms the data. What does transform here mean? Well, it means doing things such as deriving information from the data (such as a structure that the data has), parsing the data, or filtering it. Take, for instance, a situation where the raw data has personal information that should be anonymized. This would be a huge breach in compliance if we consider regulations such as GDPR. LogStash can identify this information before it gets stored and automatically anonymize/exclude it. Another great thing about LogStash is that it is scalable, which means that it can scale out to cater for increased demand. In a situation where there is a huge influx of data, LogStash can act as a buffer to prevent overloading the data store.

### Kibana

Now we move on to the "K". That's Kibana.

At this point, the data still isn't very human-friendly. Kibana (similar to Grafana or other visualisation techniques), lays out all the data provided by Elasticsearch into an easy-to-read format. This could be in the form of charts, graphs, time-series data, and much more. You can also use Kibana's built-in query language to perform queries on the Elasticsearch datastore and have this data represented in a dashboard.

The dashboards can also be bound to specific roles. For example, people in management roles would want to see different dashboards from those working in system security. This helps improve policy compliance as well as usability. You can also export and share data easily from within Kibana, and create alerts to notify you of certain trigger events. Kibana is a huge application and deserves its own course. But the important takeaway here is that it integrates beautifully into the ELK stack and provides a lot of customizable visualisations.

The best part about the ELK stack is that it is built to run continuously. LogStash will transform and stash data into Elasticsearch, which will then serve this data to Kibana. All in real-time. This means that data about your cluster will always be visible in an up-to-date, understandable manner. Certainly, better than a bunch of log files, isn't it?

## Setting up the Elasticsearch

Now that you know what each letter of the stack stands for, let's go ahead and set it up. Luckily, Elastic has provided us with a [large sample repo](https://github.com/elastic/examples) that we can use to try out the stack with minimal hassle. In particular, we will be using the MonitoringKubernetes sample that covers all three parts of the stack. Note that this sample substitutes Logstash with [Beats](https://www.elastic.co/beats/), which is an alternative provided by Elastic. We could go for another sample such as the [Twitter sample](https://github.com/elastic/examples/tree/master/Common%20Data%20Formats/twitter), however, this requires access to the Twitter API which isn't readily available. However, feel free to try out any sample in the repo. Before we get into the sample, you will need to have a working stack set up. If you don't, then it would be much faster to get started on [Elastic cloud](http://cloud.elastic.co), which has a free tier that would suffice for this sample.

As always, you also need an available Kubernetes cluster. Once again, I recommend [Minikube](https://minikube.sigs.k8s.io/docs/start/) to set up a cluster on your local machine, but feel free to use any cluster that is available to you. Once you have a cluster available, use RBAC to create a cluster role that binds to your elastic user:

```
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=<elastic cloud email>
```

The above command will create a role in your cluster that says that your email from Elastic cloud is a cluster admin. You can then use wget (or curl) to get the files specific to this sample:

```
mkdir MonitoringKubernetes
cd MonitoringKubernetes
wget https://raw.githubusercontent.com/elastic/examples/master/MonitoringKubernetes/download.txt
sh download.txt
```

or if you have cloned the whole repo, then just head over to ```examples/MonitoringKubernetes``` folder. Either way, you should have a bunch of yaml files that define the Kubernetes resources, as well as two files, called ```ELASTIC_PASSWORD``` and ```CLOUD_ID```. Set these values with the values you got from setting up your elastic cloud account. Afterward, create a Kubernetes secret:

```
kubectl create secret generic dynamic-logging --from-file=./ELASTIC_PASSWORD --from-file=./CLOUD_ID --namespace=kube-system
```

This secret will reside in the ```kube-system```, which is a namespace managed by Kubernetes. You should also check if the ```kube-state-metrics``` pod is running  in the same namespace:

```
kubectl get pods --namespace=kube-system | grep kube-state
```

If you get nothing as a result, then create it:

```
git clone https://github.com/kubernetes/kube-state-metrics.git kube-state-metrics    
kubectl apply -f kube-state-metrics/examples/standard
kubectl get pods --namespace=kube-system | grep kube-state 
```


Now, you have all the infrastructure ready to go. The secrets are ready and the metrics pod is up. The next step is to install the sample application, which is going to be the guestbook example provided by the [Kubernets sample repo](https://github.com/kubernetes/examples). The resource file is the guestbook.yaml, which contains declarations for a bunch of services. Start by applying them to your cluster:

```
kubectl create -f guestbook.yaml 
```

Now, it's time to deploy the elastic beats resource files. The first will be the lightweight log shipper [Filebeat]https://www.elastic.co/beats/filebeat. This resource file consists of several resources including a ConfigMap, DaemonSet, and RBAC-related resources. However, you can [configure Filebeat](https://www.elastic.co/guide/en/beats/filebeat/current/configuring-howto-filebeat.html) in whichever way you prefer. Deploy it with:

```
kubectl create -f filebeat-kubernetes.yaml 
```

Next, we will be deploying the metrics shipper [Metricbeat](https://www.elastic.co/beats/metricbeat), which is [fully configurable](https://www.elastic.co/guide/en/beats/metricbeat/current/configuring-howto-metricbeat.html). Deploy it with:

```
kubectl create -f metricbeat-kubernetes.yaml 
```

Finally, we need to install the network analysis data shipper [Packetbeat](https://www.elastic.co/beats/packetbeat) which you can also [configure](https://www.elastic.co/guide/en/beats/packetbeat/current/configuring-howto-packetbeat.html). Deploy with:

```
kubectl create -f packetbeat-kubernetes.yaml
```

Now that beats have been set up, it's time to open up Kibana. If you're using elastic cloud, Kibana should already be available. Head over to your Kibana URL and open up the dashboard. To see how changes are reflected in your dashboard, scale your deployments up so that more pods start:

```
kubectl scale --replicas=2 deployment/frontend
```

You should now see Kibana reflecting these changes as log streams and visualizations.

## Drawbacks of Elasticsearch

As great as this system may look, there are some drawback. If your system contains multiple applications from various teams, then all of them would have to have Elasticsearch integration for all this to work. Now, what if one of those applications doesn't have this integration? Then a peice of the system would go missing. If the applications in the system are interconnected, then it would be a requirement for logging to see what processes goes inside each application. This would not be possible if the necessary Elasticsearch integration is not present.

If there all the applications comes from teams within the same company, then a company-wide decision can be made to say that all applications need Elasticsearch integration. But then, what about the third-party applications that you use in your cluster? Should you modify them so that they have Elasticsearch integration? What about any proprietory applications that can't be modified?

Finally, calls between your cluster go through a controller, such as a Nginx controller. What if you would like to see the logs provided by this? Thinking outside the cluster, your system would run on some specific hardware and infrastructure. What happens if you want to get logs about what goes on here? After all, it's entirely possible that the reason your system crashed was due to a failure in the underlying infrastructure. All of these data sources create logs in different ways that you can't control. To make things worse, the data is logged in different ways so there is no single format with which you can read the logs.

So what solution exists for this? Having a unified logging layer that collects data from all these sources, then transforms them so that they all conform to a single format would do the trick.

Enter fluentd.

Fluentd aims to fix all the limiatations mentioned above. So let's go ahead and jump in here.

[Next: fluentd](./fluentd.md)