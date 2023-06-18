# Fluentd on Kubernetes

First off, let's talk about installation. There are several resources including the fluentd DaemonSet that you need to install on your cluster to get it working. There are several guides on how to do this, such [this article](https://devopscounsel.com/kubernetes-log-collection-with-fluentd-elasticsearch-and-kibana/). Basically, you just need to apply a handful of resources and you will have the full ELK stack running on your cluster. What's more, if you open up Kibana, you will see the logs that fluentd pushed.

How did fluentd push those logs? By default, the containers running on your cluster push their logs to `/var/lib/docker/containers`. These logs follow a specific format which is specified with the regex present in the fluentd DaemonSet (`/^(?<time>.+) (?<stream>stdout|stderr)( (?<logtag>.))? (?<log>.*)$/`). This allows fluentd to match and push logs with no further configuration.

But if you are running a large application on a multi-cluster setup, you might very well have logs that get produced from other sources. How do you get those logs to get pushed by fluentd?

The answer is fluent configs. We look into them in detail in the last section, and it is time to apply that knowledge. As you can imagine, these conf files don't work as is with Kubernetes, so the first step is to create a ConfigMap out of the conf file. Assuming you have mounted the logs files to `/path/to/logs1/*.log,/path/to/logs2/*.log,/path/to/logs2/*.log`, the conf file itself, can look like this:

```
<source>
  @type tail
  @id in_tail_container_logs
  path /path/to/logs1/*.log,/path/to/logs2/*.log,/path/to/logs2/*.log
  pos_file /var/log/fluentd-containers.log.pos
  tag myapp.log
  exclude_path ["/var/log/containers/fluent*"]
  read_from_head true
  <parse>
    @type grok
    grok_pattern %{TIMESTAMP_ISO8601:timestamp}
  </parse>
</source>
<match myapp.log>
  @type elasticsearch
  host elasticsearch.kube-logging.svc.cluster.local
  port 9200
  logstash_format true
</match>
```

Let's go through this configuration block line by line. The first thing to be mentioned is the `source`. This is where the data comes from. In this case, we will simply look at log files and get their tail. The `path` specifies where the logs come from. The `pos_file` holds a record of the position (up to where have the logs already been read?). Then comes `tag`, which tags the logs with a specific tag which will be used to pick up the logs later. You also have some self-explanatory parameters there, followed by a `parse` tag that specifies a grok pattern used to parse the logs. This pattern needs to change to match your log files so that the data is represented properly in Kibana.

The next part is the `match` tag, which matches all logs with the `myapp.log` tag. It then redirects these parsed logs to elasticsearch.

So, to summarize, fluentd is a centralized logging layer that takes in data from an input source and produces a different, more standard form of data to an output source. Now let's look at an alternative: Fluent Bit.

[Next: Fluent Bit](./fluentdbit.md)