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

Now let's look at what should be done from the Kubernetes manifest side. It will be basically the same thing as what we had with filebeat, except we will use the fluent bit image. We will also be pointing the overriding config to fluent-bit.conf which will be mounted in a shared volume, the same as the filebeat yaml. Apart from that, everything will be the same.

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
  args: ["-c", "/fluent-bit/etc/fluent-bit.conf & while [ ! -f /data/completion-flag ]; do sleep 1; done && exit 0"]
  ```

Now that we have covered both areas that need to be changed, let's go ahead and give this a test run. First off, deploy the ConfigMap:

```
kubectl apply -f fluentbit-configmap.yaml
```

Next, apply the deployment.yaml:

```
kubectl apply -f non-parallel-job.yml
```

Now let's observe the containers in the same way we did with the filebeat sidecars.

```
kubectl get po
```

Note the name of the pod, and use it in the below command:

```
kubectl describe pod <POD_NAME> --watch
```

You should see two containers being described by this command under the `Containers` section. Watch as the state of both containers goes from `pending` to `running`.  When the container running the sleep command goes to a `successful` state, the container running fluentbit should immediately stop. Both pods will then go into a `Terminating` state before the pod itself terminates and leaves.