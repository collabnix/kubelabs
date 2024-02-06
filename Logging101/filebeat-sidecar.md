# Filebeat as a sidecar container

Kubernetes has a highly distributed nature, where each pod runs a separate application. This in itself is not a problem. Even if you have hundreds of pods running a hundred different applications, filebeat is more than capable of handling all those open log files that are being constantly written into and passing them on to logstash. Logstash then manages the in-flow of logs to make sure elasticsearch isn't overwhelmed. The problems start appearing if you have a sudden surge in the number of pods. This is not normal when it comes to everyday Kubernetes use cases. However, if you were using autoscaling jobs that massively scaled up and down depending on the workload, this could happen. One good example is with [KEDA](../Keda101/what-is-keda.md). KEDA looks at whatever metric you specify and massively scales jobs (basically pods) up and down to handle the demand. If each of these jobs writes a log to a common data source (such as EFS or other network file system), you could potentially have hundreds of open log files that are concurrently being written into. At this point, a single instance of filebeat may be unable to keep track of all these log files and either end up skipping some logs or stop pushing logs entirely. The solution for this is to either have multiple replicas of filebeat or to launch filebeat as a sidecar container for each pod that comes up.

In this section, we will be discussing how we can launch filebeat as a sidecar container, and the various pitfalls to look out for when doing this. But first, you need to know what a sidecar container is. The concept is explained in detail in the [Pods101 section](../pods101/deploy-your-first-nginx-pod.md), but in summary, it is simply a case where you run two containers inside a single pod. Generally, this will consist of 1 main container that runs your application, and 1 support container that runs another application designed to support the first application. In this case, this support application will be the filebeat container that pushes the logs created by the main container to elasticsearch. Note that while we term the containers as "main" and "sidecar", Kubernetes itself does not make this distinction. This is not an issue if you were running a regular application in a pod that runs forever since you want both the application as well as the filebeat sidecar to run continuously. However, if you were running a job instead of a pod, you want the job to terminate and disappear after the job finishes. This would be a problem since filebeat would continue to run after the job finishes, meaning that the job will hang around forever. We will be looking at a workaround to mitigate this.

Let's start off by defining a Kubernetes job. If you want a deep dive into Kubernetes jobs, take a look at the [Jobs101 section](../Jobs101/README.md). We will be using the same example used there and adding the filebeat sidecar onto it. To keep things simple, we will use the [non-parallel-job.yml](../Jobs101/non-parallel-job.yml). Deploying this file to your cluster will create a job that starts, sleeps for 20 seconds, then succeeds and leaves. We will be editing the yaml to add the filebeat sidecar:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: wait
spec:
  template:
    metadata:
      name: wait
    spec:
      containers:
      - name: wait
        image: ubuntu
        volumeMounts:
        - name: data
          mountPath: /data/
        command: ["sleep",  "20"]
      - name: filebeat-sidecar
        image: elastic/filebeat:5.6.16
        volumeMounts:
        - name: data
          mountPath: /data/
        command: ["/bin/sh", "-c"]
        args: ["/usr/share/filebeat/filebeat -e -c /usr/share/filebeat/filebeat.yml & while [ ! -f /data/completion-flag ]; do sleep 1; done && exit 0"]
      restartPolicy: Never
```

This is the chunk that was added:

```yaml
- name: filebeat-sidecar
    image: elastic/filebeat:5.6.16
    volumeMounts:
    - name: data
      mountPath: /data/
    command: ["/bin/sh", "-c"]
    args: ["/usr/share/filebeat/filebeat -e -c /usr/share/filebeat/filebeat.yml & while [ ! -f /data/completion-flag ]; do sleep 1; done && exit 0"]
```

Let's take a closer look at this chunk. We define a container called "filebeat-sidecar" and specify that the image is filebeat version 5.6.16. We also mount a few volumes, which we will get to later, and finally run the filebeat command. This command may look a little complicated, so let's break it down. First, we have:

```
/usr/share/filebeat/filebeat -e -c /usr/share/filebeat/filebeat.yml
```

This is the actual filebeat command. By default, filebeat is found in `/usr/share/filebeat/`, which has both the filebeat executable as well as the filebeat.yml which specifies the filebeat properties that filebeat should work based on. Since we will be using the default filebeat.yml, we will not be overriding this. However, keep in mind that to override it. you only have to specify a volume mount:

```
- name: filebeat-config
  mountPath: /usr/share/filebeat/filebeat.yml
  subPath: filebeat.yml
```

Next to the command to run filebeat, you will see a while loop. Let's get into this.

As mentioned before, a job does not run infinitely. However, filebeat does. Since there is no way to distinguish between a main and sidecar container, filebeat may run forever and hold up the pod even after the main job has finished running. This is where we use a slightly unconventional means of detecting whether the main container has finished. We start by mounting a volume called "data":

```
volumeMounts:
  - name: data
    mountPath: /data/
```

Notice that we mount this same path on both the main and sidecar containers. Now we have established a single mount that both containers can read/write to. Now, we will be adding steps to the yaml so that when the main container finishes running, a file called "completion-flag" will be created in the shared "data" directory. Meanwhile, from the point where the filebeat container starts, it will be checking for this file. The moment the file appears, the exit 0 command will run and the filebeat container will stop. Thereby both containers will stop simultaneously and the job will finish.

The sleep command will be modified like so:

```
command: ["sleep 20; touch /data/completion-flag"]
```

We use `;` instead of `&&` so that even if the command fails, the file will be created. From the filebeat side, this is the command that runs the filebeat container:

```
args: ["/usr/share/filebeat/filebeat -e -c /usr/share/filebeat/filebeat.yml & while [ ! -f /data/completion-flag ]; do sleep 1; done && exit 0"]
```

From here, we've already looked at the filebeat command, so let's take a look at the second half of this command:

```
while [ ! -f /data/completion-flag ]; do sleep 1; done && exit 0
```

This is a while loop that runs as long as there is no file called "completion-flag" present. Once the flag does show up, `exit 0` will be called and the filebeat container will stop running.

Now that we have fully explored these files, let's go ahead and perform the deployment. If you have filebeat/fluentd deployed to your cluster from the previous sections, make sure to remove it since filebeat will now come bundled with the job yaml. Then go ahead and deploy:

```
kubectl apply -f non-parallel-job.yml
```

Now let's observe each container. Since we need to watch both pods, let's use the `kubectl describe` command:

```
kubectl get po
```

Note the name of the pod, and use it in the below command:

```
kubectl describe pod <POD_NAME> --watch
```

You should see two containers being described by this command under the `Containers` section. Watch as the state of both containers goes from `pending` to `running`.  When the container running the sleep command goes to a `successful` state, the container running filebeat should immediately. Both pods will then go into a `Terminating` state before the pod itself terminates and leaves.

This brings us to the end of this section on logging with filebeat sidecars. You can use the same concept with similar tools such as fluentd if you plan to scale up your jobs/logs massively. Just make sure that there are no bottlenecks in any other points such as logstash and elasticsearch.