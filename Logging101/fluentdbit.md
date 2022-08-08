# Fluent Bit

Now that we've covered Fluentd, it's time to look into Fluent Bit. Fluent Bit is similar to fluentd, but is significantly more lightweight and consumes very little resources. Fluent Bit also has zero dependencies on anything, meaning you can get it up and running relatively quickly. However, both fluentd and Fluent Bit follow the same architecture for logging and metrics collection and have many similarities. You can also use both to create a custom logging architecture.

## What is Fluent Bit?

Fluent Bit is basically the same thing as fluentd. It acts as a logging layer that collects logs from across any input source that you specify, including infrastructure resources. It then parses, filters, and outputs the data in the same way fluentd does. It even uses plugins in the same way fluentd uses them to handle data. The advantage comes up when we need a logging layer in a containerized environment such as with a Kubernetes cluster which has a limited amount of resources and requires a logging layer that can work on each node to produce logs that can then be forwarded to a centralized logging layer such as fluentd.

There is an additional unique feature that Fluent Bit provides, and that is SQL Stream Processing. Earlier, we compared event-based logs vs object-based databases and came to the conclusion that event-based logs are a much better way to handle data when using microservices. However, databases have one thing about them that makes them superior to log data: the ability to use SQL queries to extract information. The SQL Stream Processor within Fluent Bit is used to query the processed log data and allows you to perform Aggregations, grouping, calculations, data analysis and time-series predictions. So while there is no actual database, you get all the benefits of SQL from stream processing.

Note that this step happens before you send the data to storage. You don't query data that is already in storage. So you can consider this to be an additional level of filtering based on queries that you specified. For instance, you might want to get the min values of the data before you send it to storage or the average. That is where this steps in. Once the processing step is complete, you can go ahead and write the data to whatever storage you need in a format that the storage understands. So if you were to store the data in elastic search, you would convert the logs to the elastic search format and store it. Alternatively, you could send it off to a centralized stream processor for further processing, such as fluentd.

When it comes to running Fluent Bit, you install it as a DaemonSet on every Kubernetes node. The logs relating to the pods and general infrastructure are read from that point onwards. If this all sounds familiar to you, that is likely because this is how fluentd works as well. Additionally, the pluggable nature of the application, as well as security considerations that Fluent Bit has are all the same as with fluentd. 

## Setting up Fluent Bit

Great! Now we know all there is to about Fluent Bit, so let's go ahead and install it. Note that these steps are relevant for Linux environments. There is separate documentation for [Windows environments](https://docs.fluentbit.io/manual/installation/kubernetes#windows-deployment) and [Mac Environments](https://docs.fluentbit.io/manual/installation/macos). There are several different ways you can install Fluent Bit; running it on the cloud, in a docker container, installing it directly into Linux, or since version 1.5.0, even Windows server. Since we are in a Kubernetes environment, let's see how we can install Fluent Bit on a Kubernetes cluster. As with Fluentd, many components go into installing Fluent Bit, but thankfully you will not have to install these by hand as an [official Helm chart](https://github.com/fluent/helm-charts) has been provided. A clear guide as to how Helm charts are installed can be found [in the Helm section](../Helm101/installing-a-chart.md) So go ahead and install the Helm chart:

```
helm repo add fluent https://fluent.github.io/helm-charts
```

Make sure to check out the [Helm tutorial](../Helm101/what-is-helm.md) later for a better understanding of how these charts work. Run:

```
helm search repo fluent
```

If the repo shows up properly, then you have successfully added Fluent as a repo. Note that this repo includes both Fluentd and Fluent Bit. Since we are talking about Fluent Bit here, go ahead and install it:

```
helm upgrade --install fluent-bit fluent/fluent-bit
```

As with Fluentd and Kafka, this will start Fluent Bit as a DaemonSet with default values. You can change them by changing the [values.yaml](https://github.com/fluent/helm-charts/blob/master/charts/fluent-bit/values.yaml) in your local repo. The default file consists of a resource of the type DaemonSet that runs an instance of busybox and requests RBAC support. It also starts a service of type ClusterIp on node 2020. There is also a number of options commented out in the yaml related to Network policies, service monitors, Prometheus, dashboards, ingresses, scaling, pod affinities, and so much more. As such, this file is a great starting point for anyone looking to set up Fluent Bit. 

Towards the bottom, you will get the actual Fluent Bit configuration. This section defines the inputs:

```
inputs: |
    [INPUT]
        Name tail
        Path /var/log/containers/*.log
        multiline.parser docker, cri
        Tag kube.*
        Mem_Buf_Limit 5MB
        Skip_Long_Lines On
```

We can see that the above lines use the [Tail input plugin](https://docs.fluentbit.io/manual/v/1.0/input/tail) which can be used to monitor text files. Then there are filters:

```
filters: |
    [FILTER]
        Name kubernetes
        Match kube.*
        Merge_Log On
        Keep_Log Off
        K8S-Logging.Parser On
        K8S-Logging.Exclude On
```

This adds Kubernetes metadata. Finally, there are the parsers:

```
customParsers: |
    [PARSER]
        Name docker_no_time
        Format json
        Time_Keep Off
        Time_Key time
        Time_Format %Y-%m-%dT%H:%M:%S.%L
```

This is the Container Runtime Interface parser. By default, Fluent Bit expects the logs to be in Docker interface standard, but you can change it to CRI using the above parser and the relevant lines. 

And finishes with information regarding the volume mounts for the DaemonSet.

To sum up, Fluent Bit is basically fluentd, but with a much smaller footprint and file size. It runs in a more lightweight manner and consumes resources which makes it an ideal log processor for systems that have few resources. There are also a few unique features that Fluent Bit has that fluentd doesn't, and vice versa.