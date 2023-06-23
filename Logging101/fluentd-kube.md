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

The next part is the `match` tag, which matches all logs with the `myapp.log` tag. It then redirects these parsed logs to elasticsearch. The details of elasticsearch follow. Having `logstash_format` is useful if you want to be able to index logs with `logstash-*`. With that, our configuration file is complete. Now that that's taken care of, let's look at integrating this config file with your Kubernetes cluster. The integration will happen in the form of a ConfigMap, and the file you just created will be used as-is. This ConfigMap will be mounted as a volume:

```
- name: config-volume
  mountPath: /fluentd/etc/kubernetes.conf
  subPath: Kubernetes.conf
```

Add this to the `volumeMounts` section of your deployment yaml, and deploy the file into your cluster.

If you fetch the configmaps from your cluster with:

```
kubectl get configmap
```

you will see that the map is present. Since you also deployed the fluentd deployment, any old fluentd pods should have terminated and new ones that are bound to the configmap should have started. If you look at the logs of the fluentd pod that got created, you will notice that the logs produced are being tailed:

> following tail of log: xxx.log

This means that the logs have been processed by fluentd, and most likely pushed to elasticsearch. Since Kibana has been installed, you can verify that the logs are actually in elasticsearch by looking at the Kibana dashboard. Use:

```
kubectl get svc
```

to see if the Kibana service is running. Note that at this point, Kibana does not have an external IP, meaning that you won't be able to open it up in your browser. To remedy, this, use port forwarding:

```
kubectl port-forward kibana-xxx 5601:5601
```

Now, you should be able to go to `127.0.0.1:5601` and access the Kibana dashboard. However, you might notice that you see no logs at this point. This is because you first need to create an index. Go into the settings page and select "index management". From here, create an index. If you used `logstash_format true` in your kubeconfig, you should use `logstash-*` as the index.

Now, head back to the dashboard and you should see all of the logs being produced by your application being written to the Kibana dashboard. Since you explicitly specified the path to your logs, you will notice that **only** your logs will be shown. You will also not get fluentd logs since we added `exclude_path ["/var/log/containers/fluent*"]` into the config.

So, to summarize, fluentd is a centralized logging layer that takes in data from an input source and produces a different, more standard form of data to an output source. We've seen how this can be done on a dedicated machine with fluentd running on it, as well as with a Kubernetes cluster where the entire ELK stack runs within the cluster itself. Now let's look at an alternative: Fluent Bit.

[Next: Fluent Bit](./fluentdbit.md)