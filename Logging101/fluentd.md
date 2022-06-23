# Fluentd

Fluentd is a unified logging layer that collects all sorts of logs and processes them into a unified format. The sources of the data can be access logs, weblogs, system logs, database logs, infrastructure logs, or just about any type of logs that you can think of. This data can then be used for things such as archiving information, creating alerts for certain situations, or being further processed by some analysis tool.

Consistency is key when it comes to fluentd. It needs to run continuously and gather as much data as possible without fail. This means that it can't, for any reason, stop working. This is the architecture on which fluentd was built.

## How does it work?

To start, you need to deploy fluentd to your cluster. Once that's done, Fluentd will start collecting logs from each and every application. This includes applications that you have created yourself, as well as any third-party applications that you may be using. All of these applications may choose to output logs in different ways, and this is where Fluentd steps in again.

Fluentd will process all this data and create and group everything into a single file format. You could then choose to add additional data that you may deem useful, such as what pod the log came from, what namespace it was in, and so on. This means that later if you choose to group logs by pod name or namespace, you can do this easily.

Now that the data has all been collected and transformed, it's time to store it. This is where Elasticsearch comes back into the picture. Of course, there is no limitation as to what type of data store is used. For instance, you could just as well use MongoDB or RabbitMQ. But hopefully seeing Elasticsearch being used can give you an idea as to where fluentd fits in with the rest of the architecture.

While there is no limitation saying that you can't use MongoDB instead of Elasticsearch, there is also no limitation saying that you can't use both at the same time. Thanks to the routing flexibility provided by fluentd, you can have some set of logs stored in a database, while the rest of the logs get stored in a separate data store.

## How do I use it?

Fluentd runs in your cluster as a DaemonSet. If you need a refresher on what DaemonSets are, head over to the [DaemonSet101](../DaemonSet101/README.md) section of this course. In short, a DaemonSet is a component that runs on each node, which is ideal for fluentd since it is supposed to be present everywhere. You configure fluentd using a configuration file, which can be complex to configure but allows for a great deal of flexibility and configuration using fluentd plugins. If you want to see what plugins exist for fluentd, take a look at the [list of all available plugins](https://www.fluentd.org/plugins/all). You'll notice that it covers everything from Kafka to Windows metrics in terms of what data it can process.

The first part of setting up fluentd is to introduce an input plugin. This corresponds to the source of your data. For instance, if you were using s3 as your input source, you would use the [s3 plugin](https://github.com/fluent/fluent-plugin-s3). The full list of available input and output plugins can be found [here](https://www.fluentd.org/plugins/all#input-output).

Next comes the parser plugins. A parser is something that reads and understands data, and a parser plugin does more or less the same thing in this context. For example, you may need to parse some JSON input, for which you would use a plugin such as the [lazy JSON parser](https://github.com/mathpl/fluent-plugin-lazy-json-parser). A full list of available parser plugins is [listed on the same page](https://www.fluentd.org/plugins/all#parser).

After that, you use the filter plugins. Remember that earlier, I mentioned how we could transform the data and add different information to it, such as the pod name and namespace which will help you filter the logs later? Well, this is what filter plugins are for. For instance, if you want to attach the geographical information related to a log, you could use the [geoip](https://github.com/y-ken/fluent-plugin-geoip) plugin. A list of all available filter plugins is available [here](https://www.fluentd.org/plugins/all#filter).

Finally comes the output plugins. The output plugins share the same [list of plugins](https://www.fluentd.org/plugins/all#input-output) as input plugins since data sources and data storage tends to go both ways.

Additionally, there are [formatter plugins](https://www.fluentd.org/plugins/all#formatter), which number significantly lower compared to all other plugin types, and will likely be left unused in most use cases. Formatter plugins create custom output formats in case the format given by an output plugin doesn't match your requirements. You can extend the output provided and turn it into whatever you like.

So, that's the full process, but we still haven't seen what an actual configuration file looks like. Let's remedy that.