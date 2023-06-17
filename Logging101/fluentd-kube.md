# Fluentd on Kubernetes

First off, let's talk about installation. There are several resources including the fluentd DaemonSet that you need to install on your cluster to get it working. There are several guides on how to do this, such [this article](https://devopscounsel.com/kubernetes-log-collection-with-fluentd-elasticsearch-and-kibana/). Basically, you just need to apply a handful of resources and you will have the full ELK stack running on your cluster. What's more, if you open up Kibana, you will see the logs that fluentd pushed.

How did fluentd push those logs? By default, the containers running on your cluster push their logs to `/var/lib/docker/containers`. These logs follow a specific format which is specified with the regex present in the fluentd DaemonSet (`/^(?<time>.+) (?<stream>stdout|stderr)( (?<logtag>.))? (?<log>.*)$/`). This allows fluentd to match and push logs with no further configuration.

But if you are running a large application on a multi-cluster setup, you might very well have logs that get produced from other sources. How do you get those logs to get pushed by fluentd?

The answer is fluent configs. We look into them in detail in the last section, and it is time to apply that knowledge. As you can imagine, these conf files don't work as is with Kubernetes, so the first step is to create a ConfigMap out of the conf file. Assuming you have mounted the logs files to `/path/to/logs1/*.log,/path/to/logs2/*.log,/path/to/logs2/*.log`, the conf file itself, can look like this:

```
<match **>
  @type stdout
</match>
<match fluent.**>
  @type null
</match>
<match docker>
  @type file
  path /var/log/fluent/docker.log
  time_slice_format %Y%m%d
  time_slice_wait 10m
  time_format %Y%m%dT%H%M%S%z
  compress gzip
  utc
</match>
<source>
  @type tail
  @id in_tail_container_logs
  path /path/to/logs1/*.log,/path/to/logs2/*.log,/path/to/logs2/*.log
  pos_file /var/log/fluentd-containers.log.pos
  tag kubernetes.*
  exclude_path ["/var/log/containers/fluent*"]
  read_from_head true
  <parse>
    @type grok
    grok_pattern %{TIMESTAMP_ISO8601:timestamp}
  </parse>
</source>
```

So, to summarize, fluentd is a centralized logging layer that takes in data from an input source and produces a different, more standard form of data to an output source. Now let's look at an alternative: Fluent Bit.

[Next: Fluent Bit](./fluentdbit.md)