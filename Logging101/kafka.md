# What is Apache Kafka?

Event-driven architecture is the basis of what most modern applications follow. This section is on logging, and it is a perfect example of what event-driven architecture is. When an event happens, some other event occurs. In the case of logging, when an event happens, information about what just happened is logged in. The event in question usually involves some sort of data transfer from one data source to another, and while this may be easy to grasp and understand when the application is small or there are only a handful of data streams, it gets complicated and unmanageable very quickly once the amount of data in your system increases. This is where Apache Kafka comes in. 

If you think about it, you could even say that logs were an alternative to data stored in a database. After all, at the end of the day, everything is just data. The difference is that with databases, it is very hard to scale up and is not an ideal tool to handle data streams. Logs, on the other hand, are. Logs can also be distributed across multiple systems (by duplication) so there is no single point of failure. This is especially useful in the case of microservices. A microservice is a small component that does only one or a small handful of functionalities that you can logically group into your head. In a complicated system, there would be hundreds of such microservices working in tandem to do all sorts of things. As you can imagine, this is an excellent place for logging to be used. One microservice may handle authentication, and it does so by running the user through a series of steps. At each step, there is a log produced. Now, it would make little sense if the logs were jumbled and disorderly. Logs **must** maintain order for them to be useful. For this, Kafka introduces topics.

## Kafka topics

A topic is simply an ordered list of events. Unlike database records, logs are unstructured and there is nothing governing what the data should be like. You could have small data logs or relatively larger data logs. Data logs can be stored for a small amount of time, or logs can be stored indefinitely. Kafka topics exist to support all of these situations. What's interesting is that topics aren't write-only. While microservices may log their events in a Kafka topic, they can also read logs from a topic. This is useful in cases where a microservice may hold information that a different microservice must consume. The output can then be piped into yet another Kafka topic where it can be processed separately. 

Topics aren't static and can be considered to be a stream of data. This means that topics are being expanded as new events get added in. If you consider a large system, there may be hundreds of such topics that maintain logs for all sorts of events in real-time. I think you can already see how real-time data being appended into a continuous stream can be a gold mine for data scientists or engineers looking to perform analysis and gain insights from the data. So, this naturally means that entire services can be introduced simply to process or simply to visualize and display this data.

## Kafka Connect

While Kafka was initially released in 2011, it really started gaining popularity in recent years. This means that many large businesses which already had large quantities of data and processes on how the data was handled would have a hard time switching to Kafka. Additionally, some parts of the system may never be converted to Kafka at all. Kafka connect exists to support these kinds of situations.

Consider fluentd. Fluentd doesn't require the input or output sources to be anything fluentd specific. Instead, it is happy to process just about anything into a consistent fluentd format using fluend plugins. This is the same thing that happens with Kafka. There are a lot of things with varying degrees of complexity when it comes to connecting two completely different services together. For example, if you were to try and connect your service to elasticsearch, then you would need to use the Elasticsearch API and handle the topics with log streams, etc... All very complicated, and with Kafka streams, very unnecessary. This is because, like with fluentd, you can expect this connector to already exist. All you have to do is to use it. Some other similarities to fluentd include the solution being highly scalable and fault-tolerant. 

### How does Kafka connect work?

Kafka Connect is basically an API that is open and easily understandable. Connectors are created against this API and allow you to maintain all sorts of connections. This means that you don't even have to use the actual API since the connectors you use will be handling calls to the API for you. So where exactly can you get these connectors?

The [Confluent hub](https://www.confluent.io/hub/) is the best place to go for your connectors. It is curated and comes with a command-line tool to install whatever plugin you need directly from this hub. However, there are no limitations are saying that this is the only place for you to get connectors. There are plenty of [connectors on GitHub](https://github.com/topics/kafka-connector) that you can use. In fact, there is no restriction at all on where you get your connectors. If they are connectors they will work with Kafka Connect. This means that you have an almost unlimited number of sources from which to get plugins. 

Now, what happens if your use case is so specific that there are no existing connectors? Since the connector ecosystem is so large, the possibility of this situation is very low. However, if this situation arises, then you can create your own connector. The Kafka Connect API is easy to understand and well documented, so you will have no trouble getting up and running with it.

## Setting up Kafka

Since Kafka depends on Java, make sure that you first have Java 8 installed.

Now that you are armed with an overall knowledge of Kafka, let's see about setting it up. Depending on your use case, the way you would get started varies, but of course, the first thing is to [download Kafka](https://www.confluent.io/get-started/?product=software). The Confluent version of Kafka is one of the best options since it is well tested, and has plugins such as a REST proxy, connectors, etc... You can also choose to get the [Apache version](https://www.apache.org/dyn/closer.cgi?path=/kafka/3.2.0/kafka_2.13-3.2.0.tgz) instead and the installation instructions are still the same. Once you have the download, simply unzip it somewhere. Inside the bin folder, you will find Kafka-server-start.sh, which is the entry point of the program. Run it with:

```
$ bin/kafka-server-start.sh config/server.properties
```

That's all that takes to get a basic Kafka environment up and running. Let's move on to creating topics. As we've discussed, topics are a stream of events and are the most fundamental part of Kafka. You start it with:

```
$ bin/kafka-topics.sh --create --topic <topic-name> --bootstrap-server localhost:9092
```

This will create a topic with the name you provide. The bootstrap-server option here is where your resource gets its initial data from, and further configuration related to this server can be found in the ```bootstrap.servers``` value of the ```consumer.properties``` file.

Now that your topic is up, let's start logging events to the topic. For this, you need to run the producer client that will create a few logs and write them into the topic you specify. The content of these logs can be specified by you:

```
$ bin/kafka-console-producer.sh --topic <topic-name> --bootstrap-server localhost:9092
LoggingLab101 first event
LoggingLab101 second event
```

You can continue typing in newline separate events and use Ctrl + c to exit out. Now, your topic has events written into it, and it's time to read these events. Do so with the consumer in the same way as you did with the producer:

```
$ bin/kafka-console-consumer.sh --topic quickstart-events --from-beginning --bootstrap-server localhost:9092
```

Once you have verified that Kafka is working well, it's time to start using Kafka connect. The file you are looking for here is called ```connect-file-<version>.jar```, and this file needs to be added to the ```plugin.path``` variable within the ```config/connect-standalone.properties``` file. If this variable does not exist, create it:

```
echo "plugin.path=libs/connect-file-3.2.0.jar"
```

Now, you need some sample data to test with, and you can simply create a text file for this:

```
echo -e "foo\nbar" > test.txt
```

Next, it's time to fire up the Kafka connectors. We will be using two in this example, and the file you need to execute to start this is the ```bin/connect-standalone.sh```. The arguments that you need to pass to it are the properties file you just modified, the properties file of the data source (input) and the properties file of the data sink (output), both of which are already provided by Kafka:

```
bin/connect-standalone.sh config/connect-standalone.properties config/connect-file-source.properties config/connect-file-sink.properties
```

The connectors provided by Kafka will now start reading and writing lines via the Kafka topic. In this case, the connection that Kafka connect makes is between the input text file, the Kafka topic, and the output text file. Of course, this is a very basic usage of Kafka connect, and you will most likely be using custom-written connectors that read from all sorts of inputs and are written to any number of outputs, but this small example shows Kafka connectors at work. You can verify that the data was indeed handled properly by looking at the output file (```test.sink.txt```). Since the topic that was used still has the data,  you can also go ahead and run the previous command we used to read data from the topic:

```
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic connect-test --from-beginning
```

Appending a line to the input txt should also show it in the consumer.

Another topic we briefly touched on was [Kafka streams](https://kafka.apache.org/documentation/streams/), and you can find a [starter example](https://kafka.apache.org/quickstart#quickstart_kafkastreams) provided by Apache that you can look through if you are planning on using this part of Kafka.

Now, since you have a Kafka environment up and running along with Kafka connectors, feel free to play around with the system and see how things work. Once you're done, you can tear down the environment by stopping the producer and consumer clients, Kafka broker, and the Zookeeper server (with ```Ctrl + C```). Delete any leftover events with a recursive delete:

```
rm -rf /tmp/kafka-logs /tmp/zookeeper
```

## Kafka and fluentd

At this point, you might be thinking that Kafka can now replace fluentd. Indeed, you can choose between either fluentd or Kafka depending on what best suits your test case. However, this doesn't necessarily need to be the case. You can run both of them together with no issues. Case in point, if you were to look at fluentd's [list of available input plugins](https://www.fluentd.org/datasources), you would be able to see Kafka listed there. This applies to the [available output plugins](https://www.fluentd.org/dataoutputs) as well. In the same way, there exists [Kafka connect plugins for fluentd](https://github.com/fluent/kafka-connect-fluentd). What this means is that the two services can act as data sources/data sink for each other. But why would you want to do that at all? 

Kafka has a publisher-subscriber model, where Kafka sits on each host and provides a distributed logging system. This ensures that logs will be produced and maintained regardless of issues such as inter-resource connectivity. Fluentd on the other hand is a centralized logging system that can collect all data produced by individual Kafka topics, as well as any other data sources to create a unified logging layer. The basic idea here is that the two services work in two different places, and can be perfectly integrated with each other to provide a very comprehensive logging system.

That just about wraps up this lesson on Kafka.

[Next: Fluent Bit](./fluentdbit.md)