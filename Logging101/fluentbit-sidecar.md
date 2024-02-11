## fluentbit as a sidecar container

The concept behind the fluentbit sidecar container will be basically the same as with the filebeat sidecar. The differences will be in the fluentbit conf since that will obviously use a different syntax and the way the fluentbit container will be loaded into the pod. We will continue to use the same Ubuntu job that we were using before, and the same concept of using a completion flag to tell when the container should stop will continue to apply. We will also be using the same shared volume, and we will be using a ConfigMap to load the fluent bit conf as well. Below is the fluent bit conf that matches the filebeat config that we had in the previous section:

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentbit-configmap
data:
  fluent-bit.conf: |
    [SERVICE]
        Flush        1
        Log_Level    info
        Daemon       off

    [INPUT]
        Name         tail
        Path         /data/*.log
        Tag          mixlog

    [OUTPUT]
        Name         http
        Match        mixlog
        Host         logstash-logstash
        Port         5044
```

The first five lines are already familiar to you. We then start the fluentbit config. We first have some information on the service, followed by the definition of the input. As with before, we use the tail plugin to get all the log files found in /data/ and tag them with the tag "mixlog". We then match these tagged items in the output plugin and stream the logs into the logstash service. You will notice that while filebeat natively had an input source to logstash called "beats", fluent bit does not. However, we can use "http" to do this instead. From the logstash side, you will have to change the input to point to use "http" instead of "beats", but apart from that, everything should work just fine.

```
- name: fluent-bit-sidecar
  image: cr.fluentbit.io/fluent/fluent-bit:2.2.2
  volumeMounts:
    - name: fluent-bit-config
      mountPath: /fluent-bit/etc/
      readOnly: true
    - name: shared-data
      mountPath: /data/
  command: ["/fluent-bit/bin/fluent-bit"]
  args: ["-c", "/fluent-bit/etc/fluent-bit.conf"]
  ```