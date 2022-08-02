# Fluentd

Fluentd is a unified logging layer that collects all sorts of logs and processes them into a unified format. The sources of the data can be access logs, weblogs, system logs, database logs, infrastructure logs, or just about any type of logs that you can think of. This data can then be used for things such as archiving information, creating alerts for certain situations, or being further processed by some analysis tool.

Consistency is key when it comes to fluentd. It needs to run continuously and gather as much data as possible without fail. This means that it can't, for any reason, stop working. This is the architecture on which fluentd was built.

Now, you might think that this sounds a little bit like Logstash. That's because it is. If you are using fluentd, then you don't have to also use LogStash. However, the rest of the ELK stack is fully usable alongside fluentd.

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

## Fluentd Configuration File

The fluentd configuration file is already present when you deploy fluentd. An environment variable also gets conveniently set (```FLUENT_CONF```) to access the config file. Depending on how you installed fluentd, the location and name of the file may change so the env variable is the best option when locating the config file.

Now, let's talk about the syntax of this conf file. The syntax looks similar to XML, although there are several notable differences. The "tags", officially called directives, that are available for use are:

### source

As the name implies this refers to the input source of fluentd and corresponds to the input plugins we discussed. ```@type``` should be used to specify the plugin being used.
```
<source>
  @type forward
  port 24224
</source>
```
### match

This would be the output destination fluentd should use and corresponds to the output plugins we discussed. But why is it called "match"? Well, the primary purpose of this directive is to **match** tags so that they can be processed.
```
# Match events tagged with "myapp.access" and
# store them to /var/log/fluent/access.%Y-%m-%d
<match myapp.access>
  @type file
  path /var/log/fluent/access
</match>
```
### filter

This handles the processing within fluentd and corresponds to the filter plugins we discussed.
```
<filter myapp.access>
  @type record_transformer
  <record>
    host_param "#{Socket.gethostname}"
  </record>
</filter>
```

This sits in the middle of the other two plugins and allows filter plugins to be chained to each other. So you will have an input, which leads to a filter (or filters), which eventually leads to an output.

### system

This is used if you want to set a directive that affects the entire system.

```
<system>
  # equal to -qq option
  log_level error
  # equal to --without-source option
  without_source
  # ...
</system>
```

Various parameters can be used under the system directive, and you can get a list of them [here](https://docs.fluentd.org/deployment/system-config).

### label

Handling tags can be a complex process, and the label syntax is present to simplify this to some extent. To add a label, you simply use ```@label @SYSTEM```.

```
<source>
  @type tail
  @label @SYSTEM
</source>
```

### @include

If you already have a comprehensive configuration file that has to get duplicated for a different configuration file, there is no reason to create the same config file twice. Instead, you can use the ```include``` syntax to simply include one config file in another.

```
@include a.conf
@include config.d/*.conf
```

## Setting up Fluentd

Alright, so we know all about Fluentd now, and we have taken a look at the different tags we can use in the fluentd configuration files, let's get it set up on a cluster. For that, you need to have a cluster up and running, and [Minikube](https://minikube.sigs.k8s.io/docs/start/) is the perfect solution. Its easy to set up and use, and is an excellent tool for local development. You can also use clusters hosted elsewhere, as well as the cloud.

Note that Fluentd v0.12 does not support Windows since it's very rare that your cluster would have to deal with a Windows machine. However, if you need to collect logs from a Windows server, Fluent has provided a [guide](https://docs.fluentd.org/v/0.12/use-cases/windows) on how you can do that. If you are working with a Redhat-based environment, refer to the [guide for redhat](https://docs.fluentd.org/v/0.12/articles/install-by-rpm), and if you are using a Debian-based server, refer to the [guide for Debian](https://docs.fluentd.org/v/0.12/articles/install-by-deb). We will be installing fluentd using a Ruby gem, and this is a standard way you can use to install fluentd on any platform that supports gems.

The first thing you need to do is to set up a Network time protocol Daemon on your operating system so that Fluentd can have an accurate timestamp. Since the time an event occurs is crucial to the system, this is a rather necessary step.

The next thing that needs consideration is the file descriptor limit. The file descriptor limit determines how many open files you can have at a moment, and since fluent would generally deal with thousands of files at once, your operating system needs to be able to cater to this need:

```
root soft nofile 65536
root hard nofile 65536
* soft nofile 65536
* hard nofile 65536
```

You likely don't need to do this last preparation step, but if you are running a high-load environment, make sure you [optimize your network kernel parameters](https://docs.fluentd.org/v/0.12/articles/before-install#optimize-network-kernel-parameters).

Since we are using a ruby gem, you would have to install a ruby interpreter. Make sure your version is 1.9.3 or higher. You also need the ruby-dev package installed. Both can be installed using ```sudo apt install ruby-full``` on ubuntu and ```sudo yum install ruby``` in RHEL.

Next, we get to installing the Fluentd gem and running it:

```
gem install fluentd -v "~> 0.12.0" --no-ri --no-rdoc
fluentd --setup ./fluent
fluentd -c ./fluent/fluent.conf -vv &
echo '{"json":"message"}' | fluent-cat debug.test
```

If you now get a message output similar to ```debug.test: {"json":"message"}```, then you have successfully set up Fluentd on your development environment. Now it's time to create some Fluentd configuration files. We have already looked at the syntax that makes up these files, and now we will look at how to use this syntax from end to end.

## Setting up configuration files

Since we installed Fluentd with a gem, use:

```
sudo fluentd --setup /etc/fluent
sudo vi /etc/fluent/fluent.conf
```

If you installed Fluentd with RPM/DEB/DMG, then use

```
sudo vi /etc/td-agent/td-agent.conf
```

First, you need a Fluentd daemonset, which you can grab from the official [GitHub repo](https://github.com/fluent/fluentd-kubernetes-daemonset), so start by cloning the repo itself:

```
$ git clone https://github.com/fluent/fluentd-kubernetes-daemonset
```

Once you have the repo, you will find the ```fluentd-daemonset-elasticsearch.yaml``` placed in the root folder alongside several other daemonset resource files. In this case, we will be sticking to the ```fluentd-daemonset-elasticsearch.yaml```, and use it to deploy our DaemonSet, but feel free to also experiment with the other DaemonSets as the rest of the instructions are equally applicable to those as well.

A quick observation of this DaemonSet shows that it uses the fluentd image with volume mounts, and has a couple of environment variables that define things such as port, SSL verification requirement, and most importantly, elasticsearch credentials. You have to change these credentials out with your elasticsearch credentials. You can use the same ones you used for the Elasticsearch lab.

So, to summarize, fluentd is a centralized logging layer that takes in data from an input source and produces a different, more standard form of data to an output source. Now let's look at alternatives that aren't necessarily alternatives: Apache Kafka. Kafka is an important part of any serious logging architecture, and we will take a look at that, as well as how you can get Kafka and fluentd to live together, in the next section.

[Next: Apache Kafka](./kafka.md)