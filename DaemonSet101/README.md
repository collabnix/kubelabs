## What is a DaemonSet?

- DaemonSets are used to ensure that some or all of your K8S nodes run a copy of a pod, which allows you to run a daemon on every node.

- When you add a new node to the cluster, a pod gets added to match the nodes. Similarly, when you remove a node from your cluster, the pod is put into the trash. Deleting a DaemonSet cleans up the pods that it previously created.

##  Why use DaemonSets?

- Now that we understand DaemonSets, here are some examples of why and how to use it:

- To run a daemon for cluster storage on each node, such as:
       - glusterd
       - ceph
- To run a daemon for logs collection on each node, such as:
      - fluentd
      - logstash
- To run a daemon for node monitoring on ever note, such as:
      - Prometheus Node Exporter
      - collectd
      - Datadog agent

- As your use case gets more complex, you can deploy multiple DaemonSets for one kind of daemon, using a variety of flags or memory and CPU requests for various hardware types.

## Creating your first DeamonSet Deployment

```
git clone https://github.com/collabnix/kubelabs
cd kubelabs/DaemonSet101
kubectl apply -f daemonset.yml
```

- Create a daemonset using following command

``` $ kubectl create -f daemonset.yml --record ```

The --record flag will track changes made through each revision.

- Get the basic details about daemonsets:

```$ kubectl get daemonsets/prometheus-daemonset```

- More details about the daemonset:

kubectl describe daemonset/prometheus-daemonset

Get pods in daemonset:

``` $ kubectl get pods -lname=prometheus-exporter```

Delete a daemonset:

``` $ kubectl delete -f daemonset.yml```


##  Restrict DaemonSets To Run On Specific Nodes



## How To Reach a DaemonSet Pod

- There are several design patterns DaemonSet-pods communication in the cluster:

 - The Push pattern: pods do not receive traffic. Instead, they push data to other services like ElasticSearch, for example.
 - NodeIP and known port pattern: in this design, pods use the hostPort to acquire the node’s IP address. Clients can use the node IP and the known port (for example, port 80 if the DaemonSet has a web server) to connect to the pod.
 - DNS pattern: create a Headless Service that selects the DaemonSet pods. Use Endpoints to discover DaemonSet pods.
 - Service pattern: create a traditional service that selects the DaemonSet pods. Use NodePort to expose the pods using a random port. The drawback of this approach is that there is no way to choose a specific pod.

