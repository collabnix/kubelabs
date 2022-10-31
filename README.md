# Get Started with Kubernetes | Ultimate Hands-on Labs and Tutorials

![stars](https://img.shields.io/github/stars/collabnix/kubelabs)
![forks](https://img.shields.io/github/forks/collabnix/kubelabs)
![issues](https://img.shields.io/github/issues/collabnix/kubelabs)
![GitHub contributors](https://img.shields.io/github/contributors/collabnix/kubelabs)
![Visitor count](https://shields-io-visitor-counter.herokuapp.com/badge?page=collabnix.kubelabs)
![Twitter](https://img.shields.io/twitter/follow/collabnix?style=social)


## Pre-requisite:

- [Introductory Slides](./Kubernetes_Intro_slides-1/Kubernetes_Intro_slides-1.html) 
- [Deep Dive into Kubernetes Architecture](./Kubernetes_Architecture.md) 


## Preparing 5-Node Kubernetes Cluster

### PWK:

  - [Preparing 5-Node Kubernetes Cluster on Kubernetes Platform](./kube101.md) 
  - [Setting up WeaveScope For Visualization on Kubernetes](./weave-pwk.md) 
  - [Running Portainer on 5 Node Kubernetes Cluster](https://github.com/collabnix/kubelabs/tree/master/portainer#running-portainer-on-5-node-kubernetes-cluster)
  
  
  
### GKE

  - [Setting up GKE Cluster](./gke-setup.md) 
  - [Setting up Weavescope for Visualization on GKE](./weave.md) 
  
### Docker Desktop for Mac

  - [Setting up Kubernetes Cluster on AWS using Kops running on Docker Desktop for Mac](./dockerdesktopformac/README.md)
  
  
### Ubuntu

  - [Setting up Kubernetes on Ubuntu](https://github.com/collabnix/kubelabs/blob/master/install/ubuntu/README.md)


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
 
 - [The difference between a Statefulset and a Deployment](./StatefulSets101/README.md#what-is-statefulset-and-how-is-it-different-from-deployment)
 - [Deploying a Stateful Application Using Kubernetes Statefulset?](./StatefulSets101/README.md#deploying-a-stateful-application-using-kubernetes-statefulset)
 - [Deploying NFS Server](./StatefulSets101#deploying-nfs-server)
 - [Deploying PV](./StatefulSets101#deploying-persistent-volume)
 - [Deploying PVC](./StatefulSets101#deploying-persistent-volume-claim)
 - [Using Volume](./StatefulSets101#using-volume)
 - [Recreate Pod](./StatefulSets101#recreate-pod)
 
 
## DaemonSet101
 
 - [Why DaemonSets in Kubernetes?](./DaemonSet101/README.md)
 - [Creating your first DeamonSet Deployment](./DaemonSet101/README.md#creating-your-first-deamonset-deployment)
 - [Restrict DaemonSets To Run On Specific Nodes](./DaemonSet101/README.md#restrict-daemonsets-to-run-on-specific-nodes)
 - [How To Reach a DaemonSet Pod](./DaemonSet101/README.md#how-to-reach-a-daemonset-pod)

## Jobs101

- [Creating Your First Kubernetes Job](./Jobs101/README.md#creating-your-first-kubernetes-job)
- [Multiple Parallel Jobs (Work Queue)](./Jobs101/README.md#multiple-parallel-jobs-work-queue)



## Ingress101


- [What is Kubernetes ingress?](./Ingress101/README.md)
   - [NodePort](./Ingress101#nodeport)
   - [Load Balancer](./Ingress101#loadbalancer)
   - [Ingress](./Ingress101#ingress)
   - [How to Use Nginx Ingress Controller](./Ingress101#how-to-use-nginx-ingress-controller)
   - [Ingress Controllers and Ingress Resources](./Ingress101#ingress-controllers-and-ingress-resources)
  


## RBAC101
  
  - [Role-Based Access Control (RBAC) Overview](./RBAC101/#role-based-access-control-rbac)
  - [Creating a Kubernetes User Account Using X509 Client Certificate](./RBAC101/#creating-a-kubernetes-user-account-using-x509-client-certificate)
  

## Service Catalog101

 
  - [What is Kubernetes Service Catalog?](./ServiceCatalog101/what-is-service-catalog.md)
  - [Creating a sample Service Catalog](./ServiceCatalog101/Create-Service-Catalog.md)
  - [Installing Service Catalog Helm Chart](./ServiceCatalog101/Install-Service-Catalog-Helm.md)


## Cluster Networking101

 - [What Is Cluster Networking In Kubernetes Sense?](./ClusterNetworking101/README.md/#Cluster-Networking)
 - [Kubernetes Networking Rules](./ClusterNetworking101/README.md/#Kubernetes-Networking-Rules)
 - [Types of Networks](./ClusterNetworking101/README.md/#Types-of-Networks)
   - [Underlay Network](./ClusterNetworking101/README.md/#Underlay-Network)
   - [Overlay Network](./ClusterNetworking101/README.md/#Overlay-Network)
 - [What is a Container Network Interface (CNI)?](./ClusterNetworking101/README.md/#What-is-a-Container-Network-Interface-(CNI))
   - [AWS VPC CNI for Kubernetes](./ClusterNetworking101/README.md/#AWS-VPC-CNI-for-Kubernetes)
   - [AZURE CNI for Kubernetes](./ClusterNetworking101/README.md/#Azure-CNI-for-Kubernetes)
   - [Calico](./ClusterNetworking101/README.md/#Calico)
   - [Cilium](./ClusterNetworking101/README.md/#Cilium)
   - [Weave Net from WeaveWorks](./ClusterNetworking101/README.md/#Weave-Net-from-WeaveWorks)
   - [Flannel](./ClusterNetworking101/README.md/#Flannel)
 - [LAB- Weave Net Implementation](./ClusterNetworking101/README.md/#LAB-Weave-Net-Implementation)

## Network Policies101


 - [What is a Kubernetes Network Policy?](./Network_Policies101/README.md)
 - [Creating Your First NetworkPolicy Definition](./Network_Policies101/First_Network_Policy.md)
 - [How can we fine-tune Network Policy using selectors?](./Network_Policies101/how_can_we_fine-tune_network_policy_using_selectors.md)
 - [Deny Ingress Traffic That Has No Rules](./Network_Policies101/Deny_ingress_traffic_that_has_no_rules.md)
 - [Deny Egress Traffic That Has No Rules](./Network_Policies101/Deny_egress_traffic_that_has_no_rules.md)
 - [Allow All Ingress Traffic Exclusively](./Network_Policies101/allow_all_ingress_traffic_exclusively.md)
 - [Allow All Egress Traffic Exclusively](./Network_Policies101/allow_all_egress_traffic_exclusively.md)



## Monitoring101


 - [Monitoring in Kubernetes](./Monitoring101/README.md/#Monitoring-in-Kubernetes)
 - [Core Monitoring Pipeline](./Monitoring101/README.md/#Core-Monitoring-Pipeline)
 - [Services Monitoring Pipeline](./Monitoring101/README.md/#Service-Monitoring-Pipeline)
 - [What should you consider in Kubernetes Services Pipeline?](./Monitoring101/README.md/#What-should-you-consider-in-Kubernetes-Services-Pipeline)
 - [What about Metrics Visualization?](./Monitoring101/README.md/#Metrics-Visulization) 
 - [Changes To Watch For](./Monitoring101/README.md/#Changes-To-Watch-For)
   - [Heapster is Going Away](./Monitoring101/README.md/#Heapster-is-going-away)
   - [Metrics Server Will Get More Cool Features](./Monitoring101/README.md/#Metrics-Server-Will-Get-More-Cool-Features)

## Logging101

- [Logging introduction](./Logging101/logging-intro.md)
 - [Elasticsearch](./Logging101/what-is-elasticsearch.md)
 - [Fluentd](./Logging101/fluentd.md)
 - [Kafka](./Logging101/kafka.md)
 - [Fluent Bit](./Logging101/fluentdbit.md)

## Helm101

- [What is Helm?](./Helm101/what-is-helm.md)
- [Installing a Helm Chart](./Helm101/installing-a-chart.md)
- [Helm Charts](./Helm101/helm-charts.md)
- [Helm Chart Hooks](./Helm101/chart-hooks.md)
- [Helm Chart Testing](./Helm101/test-charts.md)
- [Helm Chart Repository](./Helm101/chart-repos.md)

## AKS101
- [What is AKS?](./AKS101/what-is-aks.md)
- [AKS Networking](./AKS101/aks-networking.md)
- [AKS IAM](./AKS101/aks-iam.md)
- [AKS Storage](./AKS101/aks-storage.md)
- [AKS Service Mesh](./AKS101/aks-service-mesh.md)
- [AKS KEDA](./AKS101/aks-keda.md)

## Security101
- [What is DevSecOps?](./Security101/devsecops.md)
- [Securing your cluster](./Security101/kubernetes-security.md)

## GitOps101
- [What is GitOps](./GitOps101/what-is-gitops.md)
- [ArgoCD](./GitOps101/argocd.md)

## Managed Kubernetes Service
- [Managed Kubernetes Service Intro](./ManagedKubernetes/readme.md)

## EKS101
- [What is EKS](./EKS101/what-is-eks.md)

## LKE101
- [What is LKE](./LKE101/what-is-lke.md)

## Loft101
- [What is Loft](./Loft101/what-is-loft.md)
- [Loft Lab](./Loft101/loft-lab.md)

## Shipa101
- [What is Shipa](./Shipa101/what-is-shipa.md)
- [Shipa Lab](./Shipa101/shipa-lab.md)

## DevSpace101
- [What is DevSpace](./DevSpace101/what-is-devspace.md)
- [DevSpace Lab](./DevSpace101/devspace-lab.md)

## Kubernetes with GitLab 101
- [What is GitLab](./GitLab101/what-is-gitlab.md)
- [Kubernetes with GitLab](./GitLab101/kubernetes-with-gitlab.md)

## Kubernetes with Jenkins
- [What is Jenkins](./Jenkins101/what-is-jenkins.md)

# Contributors

- [Ajeet Singh Raina](https://twitter.com/ajeetsraina)
- [Sangam Biradar](https://twitter.com/BiradarSangam)
- [Mewantha Bandara](http://linkedin.com/in/mewantha-bandara)
- [Rachit Mehrotra](https://www.linkedin.com/in/rachit-mehrotra-08a92819/?originalSubdomain=in)
- [Saiyam Pathak](https://twitter.com/SaiyamPathak)
- [Divyajeet Singh](https://www.linkedin.com/in/divyajeet-singh)
- [Apurva Bhandari](https://www.linkedin.com/in/apurvabhandari-linux)


# Join Collabnix Discord Server


[![Title](https://user-images.githubusercontent.com/34368930/198940642-50d0e7f0-c670-4800-b0ea-5b95d56aaf0e.png)](https://discord.gg/ztZpXzjSmF)
  



# Further References:

- [Kubetools](https://kubetools.collabnix.com)



[Next:  Kubernetes201](https://github.com/collabnix/kubelabs/blob/master/201/README.md)




