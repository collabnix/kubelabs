## fluentbit as a sidecar container

The concept behind the fluentbit sidecar container will be basically the same as with the filebeat sidecar. The differences will be in the fluentbit conf since that will obviously use a different syntax, and the way the fluentbit container will be loaded into the pod.

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