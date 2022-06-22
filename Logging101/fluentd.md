# Fluentd

Fluentd is a unified logging layer that collects all sorts of logs and processes them into a unified format. The sources of the data can be access logs, weblogs, system logs, database logs, infrastructure logs, or just about any type of logs that you can think of. This data can then be used for things such as archiving information, creating alerts for certain situations, or being further processed by some analysis tool.

Consistency is key when it comes to fluentd. It needs to run continuously and gather as much data as possible without fail. This means that it can't, for any reason, stop working. This is the architecture on which fluentd was built.

## How does it work?

To start, you need to deploy fluentd to your cluster. Once that's done, Fluentd will start collecting logs from each and every application. This includes applications that you have created yourself, as well as any third-party applications that you may be using. All of these applications may choose to output logs in different ways, and this is where Fluentd steps in again.

Fluentd will process all this data and create and group everything into a single file format. You could then choose to add additional data that you may deem useful, such as what pod the log came from, what namespace it was in, and so on. This means that later if you choose to group logs by pod name or namespace, you can do this easily.

Now that the data has all been collected and transformed, it's time to store it. This is where Elasticsearch comes back into the picture. Of course, there is no limitation as to what type of data store is used. For instance, you could just as well use MongoDB or RabbitMQ. But hopefully seeing Elasticsearch being used can give you an idea as to where fluentd fits in with the rest of the architecture.

While there is no limitation saying that you can't use MongoDB instead of Elasticsearch, there is also no limitation saying that you can't use both at the same time. Thanks to the routing flexibility provided by fluentd, you can have some set of logs stored in a database, while the rest of the logs get stored in a separate data store.