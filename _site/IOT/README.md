# Five Key Kubernetes Resources for IoT

IoT workloads are moving from central clouds to the edge, for reasons pertaining to latency, privacy, autonomy, and economics. However, workloads spread over several nodes at the edge are tedious to manage. Although Kubernetes is mostly used in the context of cloud-native web applications, it could be leveraged for managing IoT workloads at the edge. A key prerequisite is lightweight and production-grade k8s distributions like MicroK8s, running on Ubuntu Core. In this blog, we describe the most compelling Kubernetes resources for IoT.

ReplicaSets
A ReplicaSet is a resource that ensures pods are always kept running. Should a pod disappear for any reason, the ReplicaSet notices the missing pod and creates a replacement.


Implementation

ReplicaSets may be used for backing up mission-critical devices. In this schema, a worker node running a critical workload would be backed up with an additional one running in idle. In case of failure, the ReplicaSet in the master node would reschedule the workload on the backup. This redundancy would reduce the probability of unavailability of critical workloads.

Possible use cases

Smart city: this approach can increase the availability of security or surveillance applications. A ReplicaSet would for instance reschedule a camera application on a backup camera node in the event of a failure.
Energy management: for battery-powered devices, this approach could double the time between failures. In this case, an idle backup would be activated when the primary node runs out of power. This would halve the cost of maintenance. The savings could be significant for difficulty accessible installations like wind farms.
DaemonSets
DaemonSets are used to run a pod on all cluster nodes. This is a contrast to ReplicaSets that are used for deploying a set number of pods anywhere in a cluster. Pods run with DaemonSets could contain infrastructure-related workloads that perform system-level operations, such as logging or monitoring. Alternatively, DaemonSets can run a pod on a target node in the cluster.


Implementation

DaemonSets can manage workloads on a cluster made of various groups of IoT devices. If a label is attached to each group, DaemonSets will run group-specific workloads. This is achieved by creating a DaemonSet on the master node, with a label selector for target worker nodes. Should a node be a single target for a workload, a unique label should be attached to it.

Possible use cases

Manufacturing: with DaemonSets, large-scale manufacturing execution systems can be powered by Kubernetes. This will be achieved by running containerised event monitoring workloads in pods deployed on factory industrial machines.
Security: some security workloads need to be executed in a reliable manner on every node. DaemonSets would be the right resource for such cases.
Jobs
The job resource is intended for running tasks that terminate after execution. Associated containers will not be restarted when processes within finish successfully. This contrasts with ReplicaSets and DaemonSets that run continuous workloads that are never considered complete. 

Job resources run pods immediately after creation. However, some jobs need to run at a specific time in the future, or repeatedly in a fixed time interval. These types of jobs are referred to as CronJobs in Linux based operating systems. Kubernetes supports them too.


Implementation

A job manifest must be created on the master node, to schedule a workload on workers. For single completable tasks, the sequence of execution of workloads can be specified. For CronJobs, the schedule and the periodicity should be specified.

Possible use cases

Automotive: deep learning applications for autonomous cars generate volumes of data. This data is collected on geographically-spread edge nodes. Jobs could be implemented to periodically upload collected data from edge gateways to a central data center. Thus could data collected over several locations be periodically centralised. Data centralisation eases model refinement and transfer learning.
HostPath Volumes
Kubernetes makes it possible for pods to access the file system of their host node. Access is enabled through hostPath Volumes. A hostPath Volume points to a specific file or directory on the node’s file system. Pods using the same path in their hostPath Volume see the same files.


## Implementation

A Volumes is mounted by specifying its mounting location in pod’s definition manifest. The hostPath volume will point at a file or directory within the node’s file system. The file or directory will be shared between pods. One can also mount device files with hostPath volumes to create an interface between pods and peripheral devices.

## Potential use cases

Remote sensing: a hostPath Volumes can increase the performance of remote sensing applications by multiplexing input data from sensing devices. In the case of an image sensor for instance, this resource cold run several processing workloads in parallel on the same data stream. This could mean running two different image recognition models on the same camera stream, and therefore extracting richer meaning from a single input.
Deployments
The deployment resource provides a mechanism to update applications. Deployments can perform rolling updates on pods in a single command. On command, the deployment will delete pods with the old application. A ReplicaSet will subsequently launch a pod running the updated application. This process will be repeated until all the pods with the old application are replaced by pods running the updated application.


Availability during updates is especially important in mission-critical IoT installations. This is the case because downtime causes lost sales. Deployments enable zero-downtime updates for mission-critical applications.

## Implementation

To implement rolling updates one needs to create a Deployment resource through a manifest. The label-selector and pod templates will be specified in the manifest. Additionally, the manifest will contain a field, stating the chosen deployment strategy. 

To update a Deployment, one only needs to modify the pod template. Kubernetes automatically takes all the steps necessary to change the system state to what is declared in the resource.

## Possible use cases

Maintenance operations: Deployments simplify otherwise tedious and costly software updates on remotely installed IoT devices. Maintenance actions are carried out with simple commands, rather than manual intervention by skilled operators. Rolling updates are executed in a non-disruptive way, with no impact on device availability.

## Conclusion

The Kubernetes resources discussed above can improve availability, reliability, maintainability, and performance of IoT installations. However, to take advantage of these capabilities, the right software stack needs to be chosen. This stack could be built upon Ubuntu Core and microk8s, a lightweight Kubernetes distribution suitable for IoT. 
