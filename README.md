# An Ultimate Kubernetes Hands-on Labs

## Pre-requisites

- [Introductory Slides](https://collabnix.github.io/kubelabs/Kubernetes_Intro_slides-1/Kubernetes_Intro_slides-1.html)
- [Deep Dive into Kubernetes Architecture](./Kubernetes_Architecture.md)

## Preparing 5-Node Kubernetes Cluster

### PWK

- [Preparing 5-Node Kubernetes Cluster on Play with Kubernetes Platform](./kube101.md)
- [Setting up WeaveScope For Visualization on PWK](./weave-pwk.md)

### GKE

- [Setting up GKE Cluster](./gke-setup.md)
- [Setting up Weavescope for Visualization on GKE](./weave.md)

### Docker Desktop for Mac

- [Setting up Kubernetes Cluster on AWS using Kops running on Docker Desktop for Mac](./dockerdesktopformac/README.md)

## Using Kubectl

- [Kubectl for Docker Beginners](./kubectl-for-docker.md)
- [Accessing Kubernetes API](./api.md)

## Pods101

- [Introductory Slides](https://collabnix.github.io/kubelabs/Pods101_slides/Pods101.html)
- [Deploying Your First Nginx Pod](./pods101/deploy-your-first-nginx-pod.md)
- [Viewing Your Pod](./pods101/deploy-your-first-nginx-pod.md#viewing-your-pods)
- [Where is your Pod running on?](./pods101/deploy-your-first-nginx-pod.md#which-node-is-this-pod-running-on)
- [Pod Output in JSON](./pods101/deploy-your-first-nginx-pod.md#output-in-json)
- [Executing Commands against Pod](./pods101/deploy-your-first-nginx-pod.md#executing-commands-against-pods)
- [Terminating a Pod](./pods101/deploy-your-first-nginx-pod.md#deleting-the-pod)
- [Adding a 2nd container to a Pod](./pods101/deploy-your-first-nginx-pod.md#ading-a-2nd-container-to-a-pod)

## ReplicaSet101

- [Introductory Slides](https://collabnix.github.io/kubelabs/SlidesReplicaSet101/ReplicaSet101.html)
- [Creating Your First ReplicaSet - 4 Pods serving Nginx](./replicaset101/README.md#how-does-replicaset-manage-pods)
- [Removing a Pod from ReplicaSet](./replicaset101/README.md#removing-a-pod-from-a-replicaset)
- [Scaling & Autoscaling a ReplicaSet](./replicaset101/README.md#scaling-and-autoscaling-replicasets)
- [Best Practices](./replicaset101/README.md#best-practices)
- [Deleting ReplicaSets](./replicaset101/README.md#deleting-replicaset)

## Deployment101

- [Introductory Slides](https://collabnix.github.io/kubelabs/Deployment101_slides/Deployment101.html)
- [Creating Your First Deployment](./Deployment101/README.md)
- [Checking the list of application deployment](./Deployment101/README.md#checking-the-list-of-application-deployment)
- [Scale up/down application deployment](./Deployment101/README.md#step-2-scale-updown-application-deployment)
- [Scaling the service to 2 Replicas](./Deployment101/README.md#scaling-the-service-to-2-replicas)
- [Perform rolling updates to application deployment](./Deployment101/README.md#step-3-perform-rolling-updates-to-application-deployment)
- [Rollback updates to application deployment](./Deployment101/README.md#step-4-rollback-updates-to-application-deployment)
- [Cleaning Up](./Deployment101/README.md#step-5-cleanup)

## Scheduler101

- [Introductory Slides](#Deployment101)
- [How Kubernetes Selects the Right node?](./Scheduler101/README.md)
- [Node Affinity](./Scheduler101/node_affinity.md)
- [Anti-Node Affinity](./Scheduler101/Anti-Node-Affinity.md)
- [Nodes taints and tolerations](./Scheduler101/Nodes_taints_and_tolerations.md)

## Services101

- [Introductory Slides](https://collabnix.github.io/kubelabs/Slides_Services101/Services101.html)
- [Deploy a Kubernetes Service?](./Services101/README.md#deploying--a-kubernetes-service)
- [Service Exposing More Than One Port](./Services101/README.md#service-exposing-more-than-one-port)
- [Kubernetes Service Without Pods?](./Services101/README.md#kubernetes-service-without-pods)
- [Service Discovery](./Services101/README.md#service-discovery)
- [Connectivity Methods](./Services101/README.md#connectivity-methods)
- [Headless Service In Kubernetes?](./Services101/README.md#headless-service-in-kubernetes)

## StatefulSets101

- [Introductory Slides]
- [The difference between a Statefulset and a Deployment](./StatefulSets101/README.md#what-is-statefulset-and-how-is-it-different-from-deployment)
- [Deploying a Stateful Application Using Kubernetes Statefulset?](./StatefulSets101/README.md#deploying-a-stateful-application-using-kubernetes-statefulset)
- [Deploying NFS Server](./StatefulSets101/README.md#deploying-nfs-server)
- [Deploying PV](./StatefulSets101/README.md#deploying-persistent-volume)
- [Deploying PVC](./StatefulSets101/README.md#deploying-persistent-volume-claim)
- [Using Volume](./StatefulSets101/README.md#using-volume)
- [Recreate Pod](./StatefulSets101/README.md#recreate-pod)

## DaemonSet101

- [Introductory Slides]
- [Why DaemonSets in Kubernetes?]
- [Creating your first DeamonSet Deployment]
- [Restrict DaemonSets To Run On Specific Nodes]
- [How To Reach a DaemonSet Pod]

## Jobs101

- [Introductory Slides]
- [Creating Your First Kubernetes Job]
- [Multiple Parallel Jobs (Work Queue)]
- [Kubernetes Job Failure and Concurrency Considerations]

## Ingres101

## Secrets101

## RBAC101

## Service Catalog101

## Cluster Networking101

## Network Policies101

## Autoscaling101

## Monitoring101

## Contributors

- Ajeet Singh Raina
- Sangam Biradar
- Rachit Mehrotra
- Saiyam Pathak

[Next: Kubernetes201](https://github.com/collabnix/kubelabs/blob/master/201/README.md)
