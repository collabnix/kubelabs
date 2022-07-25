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

## Setting up the ELK stack

Now that you know what each letter of the stack stands for, let's go ahead and set it up. Luckily, Elastic has provided us with a [large sample repo](https://github.com/elastic/examples) that we can use to try out the stack with minimal hassle. In particular, we will be using the CEF sample that covers all three parts of the stack. We could go for another sample such as the [Twitter sample](https://github.com/elastic/examples/tree/master/Common%20Data%20Formats/twitter), however, this requires access to the Twitter API which isn't readily available. Before we get into the sample, we need to install Elasticsearch, Logstash & Kibana.

Since Elasticsearch and Logstash depend on Java, make sure you have Java 8 or later installed. Then download the [Elasticsearch binary](https://www.elastic.co/downloads/elasticsearch), extract, and run. The same steps apply to the [Logstash binary](https://www.elastic.co/downloads/logstash) and the [Kibana binary](https://www.elastic.co/downloads/kibana). Make sure you follow the next steps provided on the installation page to start Elasticsearch, configure Logstash, and start Kibana. Additionally, check your Logstash installation with the below command:

```
<path_to_logstash_root_dir>/bin/logstash -e 'input { stdin { } } output { stdout {} }'
```

## Drawbacks of Elasticsearch

As great as this system may look, there are some drawback. If your system contains multiple applications from various teams, then all of them would have to have Elasticsearch integration for all this to work. Now, what if one of those applications doesn't have this integration? Then a peice of the system would go missing. If the applications in the system are interconnected, then it would be a requirement for logging to see what processes goes inside each application. This would not be possible if the necessary Elasticsearch integration is not present.

If there all the applications comes from teams within the same company, then a company-wide decision can be made to say that all applications need Elasticsearch integration. But then, what about the third-party applications that you use in your cluster? Should you modify them so that they have Elasticsearch integration? What about any proprietory applications that can't be modified?

Finally, calls between your cluster go through a controller, such as a Nginx controller. What if you would like to see the logs provided by this? Thinking outside the cluster, your system would run on some specific hardware and infrastructure. What happens if you want to get logs about what goes on here? After all, it's entirely possible that the reason your system crashed was due to a failure in the underlying infrastructure. All of these data sources create logs in different ways that you can't control. To make things worse, the data is logged in different ways so there is no single format with which you can read the logs.

So what solution exists for this? Having a unified logging layer that collects data from all these sources, then transforms them so that they all conform to a single format would do the trick.

Enter fluentd.

Fluentd aims to fix all the limiatations mentioned above. So let's go ahead and jump in here.

[Next: fluentd](./fluentd.md)