# An Ultimate Kubernetes Hands-on Labs

## Pre-requisite:

- [Introductory Slides](./Kubernetes_Intro_slides-1/Kubernetes_Intro_slides-1.html) 
- [Deep Dive into Kubernetes Architecture](./Kubernetes_Architecture.html) 


## Preparing 5-Node Kubernetes Cluster

### PWK:

  - [Preparing 5-Node Kubernetes Cluster on Play with Kubernetes Platform](./kube101.html) 
  - [Setting up WeaveScope For Visualization on PWK](./weave-pwk.html) 
  
### GKE

  - [Setting up GKE Cluster](./gke-setup.html) 
  - [Setting up Weavescope for Visualization on GKE](./weave.html) 
  
### Docker Desktop for Mac

  - [Setting up Kubernetes Cluster on AWS using Kops running on Docker Desktop for Mac](./dockerdesktopformac/index.html)


## Using Kubectl 

- [Kubectl for Docker Beginners](./kubectl-for-docker.html) 
- [Accessing Kubernetes API](./api.md) 


## Pods101

 - [Introductory Slides](./Pods101_slides/Pods101.html) 
 - [Deploying Your First Nginx Pod](./pods101/deploy-your-first-nginx-pod.md) 
 - [Viewing Your Pod](./pods101/deploy-your-first-nginx-pod.md#viewing-your-pods) 
 - [Where is your Pod running on?](./pods101/deploy-your-first-nginx-pod.md#which-node-is-this-pod-running-on) 
 - [Pod Output in JSON](./pods101/deploy-your-first-nginx-pod.md#output-in-json) 
 - [Executing Commands against Pod](./pods101/deploy-your-first-nginx-pod.md#executing-commands-against-pods) 
 - [Terminating a Pod](./pods101/deploy-your-first-nginx-pod.md#deleting-the-pod) 
 - [Adding a 2nd container to a Pod](./pods101/deploy-your-first-nginx-pod.md#ading-a-2nd-container-to-a-pod) 

 

## ReplicaSet101

 - [Introductory Slides](https://collabnix.github.io/kubelabs/SlidesReplicaSet101/ReplicaSet101.html) 
 - [Creating Your First ReplicaSet - 4 Pods serving Nginx](./replicaset101/index.html#how-does-replicaset-manage-pods) 
 - [Removing a Pod from ReplicaSet](./replicaset101/index.html#removing-a-pod-from-a-replicaset) 
 - [Scaling & Autoscaling a ReplicaSet](./replicaset101/index.html#scaling-and-autoscaling-replicasets) 
 - [Best Practices](./replicaset101/index.html#best-practices) 
 - [Deleting ReplicaSets](./replicaset101/index.html#deleting-replicaset) 
 
## Deployment101
 
 - [Introductory Slides](https://collabnix.github.io/kubelabs/Deployment101_slides/Deployment101.html) 
 - [Creating Your First Deployment](./Deployment101/index.html)
 - [Checking the list of application deployment](./Deployment101/index.html#checking-the-list-of-application-deployment)
 - [Scale up/down application deployment](./Deployment101/index.html#step-2-scale-updown-application-deployment)
 - [Scaling the service to 2 Replicas](./Deployment101/index.html#scaling-the-service-to-2-replicas)
 - [Perform rolling updates to application deployment](./Deployment101/index.html#step-3-perform-rolling-updates-to-application-deployment) 
 - [Rollback updates to application deployment](./Deployment101/index.html#step-4-rollback-updates-to-application-deployment)
 - [Cleaning Up](./Deployment101/index.html#step-5-cleanup)


## Scheduler101

 - [Introductory Slides]() 
 - [How Kubernetes Selects the Right node?](./Scheduler101/index.html)
 - [Node Affinity](./Scheduler101/node_affinity.html) 
 - [Anti-Node Affinity](./Scheduler101/Anti-Node-Affinity.html) 
 - [Nodes taints and tolerations](./Scheduler101/Nodes_taints_and_tolerations.html) 
 
 

## Services101
 
  - [Introductory Slides](https://collabnix.github.io/kubelabs/Slides_Services101/Services101.html) 
  - [Deploy a Kubernetes Service?](./Services101/index.html#deploying--a-kubernetes-service)
  - [Service Exposing More Than One Port](./Services101/index.html#service-exposing-more-than-one-port)
  - [Kubernetes Service Without Pods?](./Services101/index.html#kubernetes-service-without-pods)
  - [Service Discovery](./Services101/index.html#service-discovery)
  - [Connectivity Methods](./Services101/index.html#connectivity-methods)
  - [Headless Service In Kubernetes?](./Services101/index.html#headless-service-in-kubernetes)
 
## StatefulSets101
 
 - [Introductory Slides](Pending)
 - [The difference between a Statefulset and a Deployment](./StatefulSets101/index.html#what-is-statefulset-and-how-is-it-different-from-deployment)
 - [Deploying a Stateful Application Using Kubernetes Statefulset?](./StatefulSets101/index.html#deploying-a-stateful-application-using-kubernetes-statefulset)
 - [Deploying NFS Server](./StatefulSets101#deploying-nfs-server)
 - [Deploying PV](./StatefulSets101#deploying-persistent-volume)
 - [Deploying PVC](./StatefulSets101#deploying-persistent-volume-claim)
 - [Using Volume](./StatefulSets101#using-volume)
 - [Recreate Pod](./StatefulSets101#recreate-pod)
 
 
## DaemonSet101
 
 - [Introductory Slides](Pending)
 - [Why DaemonSets in Kubernetes?](./DaemonSet101/README.md)
 - [Creating your first DeamonSet Deployment](./DaemonSet101/README.md#creating-your-first-deamonset-deployment)
 - [Restrict DaemonSets To Run On Specific Nodes](./DaemonSet101#restrict-daemonsets-to-run-on-specific-nodes)
 - [How To Reach a DaemonSet Pod](./DaemonSet101#how-to-reach-a-daemonset-pod)

## Jobs101
- [Introductory Slides](Pending)
- Creating Your First Kubernetes Job
- Multiple Parallel Jobs (Work Queue)
- Kubernetes Job Failure and Concurrency Considerations


## Ingres101
- [Introductory Slides](Pending)
- What is Kubernetes ingress?
   - NodePort
   - Load Balancer
   - Ingress Controllers and Ingress Resources
  

## Secrets101
 - [Introductory Slides](Pending)
 - What is a Service in Kubernetes?
 - Specifying Pods in a Service
 - Using Services for External Workloads
 - Service Types
 - Service Discovery
 - Multi-Cluster Services with Cluster Federation
 

## RBAC101
- [Introductory Slides](Pending)
- Role-Based Access Control (RBAC) Overview
- Creating a Kubernetes User Account Using X509 Client Certificate
- Note For Local And Self-Hosted Clusters Users
- Authorization Using Kubernetes Roles
- Cluster-Wide Authorization Using ClusterRoles

## Service Catalog101
- [Introductory Slides](Pending)
- What is Kubernetes Service Catalog?
- The Kubernetes Service 
     - Catalog Resources
     - Catalog components
- Creating a sample Service Catalog
- Installing Service Catalog Helm Repo
  - Installing Service Catalog Helm Chart
  - Installing Service Catalog Helm Chart
  - Installing minibroker
- Viewing the classes and plans for the Service Broker
- Using the Service Broker services
  - Using the Service Broker services
  - Creating the ServiceBinding
  - Using the Service Catalog Service
- Cleaning up  
  

## Cluster Networking101
- [Introductory Slides](Pending)
- What Is Cluster Networking In Kubernetes Sense?
- Kubernetes Networking Rules
- What Is An Overlay Network?
- What is a Container Network Interface (CNI)?
   - Cilium
   - Weave Net from WeaveWorks
   - Flannel

## Network Policies101
- [Introductory Slides](Pending)
- What is a Kubernetes Network Policy?
- Creating Your First NetworkPolicy Definition
- How can we fine-tune Network Policy using selectors?
- Deny Ingress Traffic That Has No Rules
- Deny Egress Traffic That Has No Rules
- Allow All Ingress Traffic Exclusively
- Allow All Egress Traffic Exclusively

## Autoscaling101
- [Introductory Slides](Pending)
- Kubernetes Autoscaling Building Blocks
   - Horizontal Pod Autoscaler (HPA)
   - Vertical Pods Autoscaler
   - Cluster Autoscaler
- How Kubernetes Autoscalers Interact Together

## Monitoring101
- [Introductory Slides](Pending)
- Core Monitoring Pipeline
- Services Monitoring Pipeline
- What should you consider in Kubernetes Services Pipeline?
- What about Metrics Visualization?
- Changes To Watch For
  - Heapster is Going Away
  - Metrics Server Will Get More Cool Features

# Contributors

- Ajeet Singh Raina
- Sangam Biradar
- Rachit Mehrotra
- Saiyam Pathak

[Next:  Kubernetes201](https://github.com/collabnix/kubelabs/blob/master/201/README.md)




