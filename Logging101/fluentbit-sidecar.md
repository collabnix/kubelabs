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

A

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