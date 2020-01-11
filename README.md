# Kubernetes101 Workshop 

## Pre-requisite:

- [Introductory Slides](http://kubelabs.collabnix.com/Kubernetes_Intro_slides-1/Kubernetes_Intro_slides-1.html) - Done
- [Deep Dive into Kubernetes Architecture](./Kubernetes_Architecture.md) - Done 
- Preparing 3-Node Kubernetes Cluster
  - [Preparing 3-Node Kubernetes Cluster](./kube101.md) - Done
  - [Setting up GKE Cluster]() - Pending
  - [Setting up Weavescope for Visualization on GKE](https://github.com/collabnix/kubelabs/blob/master/weave.md) - Done
  - [Setting up WeaveScope For Visualization on PWK](https://github.com/collabnix/kubelabs/blob/master/weave-pwk.md) - Done
- [Kubectl for Docker Beginners](./kubectl-for-docker.md) - Done

## Pods101

 - [Introductory Slides](./Pods101_slides/Pods101.html) - Done
 - [Deploying Your First Nginx Pod](./pods101/deploy-your-first-nginx-pod.md) - Done
 - [Viewing Your Pod](./pods101/deploy-your-first-nginx-pod.md#viewing-your-pods) - Done
 - [Where is your Pod running on?](./pods101/deploy-your-first-nginx-pod.md#which-node-is-this-pod-running-on) - Done
 - [Pod Output in JSON](./pods101/deploy-your-first-nginx-pod.md#output-in-json) - Done
 - [Executing Commands against Pod](./pods101/deploy-your-first-nginx-pod.md#executing-commands-against-pods) - Done
 - [Terminating a Pod](./pods101/deploy-your-first-nginx-pod.md#deleting-the-pod) - Done
 - [Adding a 2nd container to a Pod](./pods101/deploy-your-first-nginx-pod.md#ading-a-2nd-container-to-a-pod) - Done

 

## ReplicaSet101

 - [Introductory Slides](./SlidesReplicaSet101/ReplicaSet101.html) - Done
 - [Creating Your First ReplicaSet - 4 Pods serving Nginx](./replicaset101/README.md#creating-your-first-replicaset) - Done
 - [Removing a Pod from ReplicaSet](./replicaset101/README.md#removing-a-pod-from-a-replicaset) - Done
 - [Scaling & Autoscaling a ReplicaSet](./replicaset101/README.md#scaling-and-autoscaling-replicasets) - Done
 - [Best Practices](./replicaset101/README.md#best-practices) - Done
 - [Deleting ReplicaSets](./replicaset101/README.md#deleting-replicaset) - Done
 
## Deployment101
 
 - [Introductory Slides]() - Pending
 - [Creating Your First Deployment](./Deployment101/readme.md#creating-your-first-deployment)
 - [Checking the list of application deployment](./Deployment101/readme.md#checking-the-list-of-application-deployment)
 - [Scale up/down application deployment](.s/workshop/Deployment101/readme.md#step-2-scale-updown-application-deployment)
 - [Scaling the service to 2 Replicas](./Deployment101/readme.md#scaling-the-service-to-2-replicas)
 - [Perform rolling updates to application deployment](.p/Deployment101/readme.md#step-3-perform-rolling-updates-to-application-deployment) 
 - [Rollback updates to application deployment](./Deployment101/readme.md#step-4-rollback-updates-to-application-deployment)
- [Cleaning Up](./Deployment101/readme.md#step-5-cleanup)


## Scheduler101

 - [Introductory Slides]() - Pending
 - [How Kubernetes Selects the Right node?](./Scheduler101/readme.md)
 - [Node Affinity](./Scheduler101/node_affinity.md) - Done
 - [Anti-Node Affinity](./Scheduler101/Anti-Node-Affinity.md) - Tested
 - [Nodes taints and tolerations](./Scheduler101/Nodes_taints_and%20_tolerations.md) - Done
 
## StatefulSets101
 
 - [Introductory Slides]() - Pending
 - [The difference between a Statefulset and a Deployment](./StatefulSets101/readme.md#what-is-statefulset-and-how-is-it-different-from-deployment)
 - [Deploying a Stateful Application Using Kubernetes Statefulset?](./StatefulSets101/readme.md#deploying-a-stateful-application-using-kubernetes-statefulset)
 - [Creating the StatefulSet](./StatefulSets101/readme.md#creating-the-statefulset)
 - [Creating a Headless Service for our StatefulSet](./StatefulSets101/readme.md#creating-a-headless-service-for-our-statefulset)
 - [Listing the created components](./StatefulSets101/readme.md#listing-the-created-components)
 - [Connecting one pod to another through the Headless Service](./StatefulSets101/readme.md#connecting-one-pod-to-another-through-the-headless-service)
 - [Deleting the StatefulSet](./StatefulSets101/readme.md#deleting-the-statefulset)

# Contributors

- Ajeet Singh Raina
- Sangam Biradar
- Rachit Mehrotra
- Saiyam Pathak
