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
