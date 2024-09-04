# Get Started with Kubernetes | Ultimate Hands-on Labs and Tutorials

![stars](https://img.shields.io/github/stars/collabnix/kubelabs)
![forks](https://img.shields.io/github/forks/collabnix/kubelabs)
![issues](https://img.shields.io/github/issues/collabnix/kubelabs)
![GitHub contributors](https://img.shields.io/github/contributors/collabnix/kubelabs)
![Twitter](https://img.shields.io/twitter/follow/collabnix?style=social)

A Curated List of Kubernetes Labs and Tutorials

- A $0 Learning Platform for All Levels - from the ground Up
- Over 500+ Highly Interactive Docker Tutorials and Guides
- Well tested on Kubernetes Cluster  and can be run on Browser (no Infrastructure required)

# 📝 Join our Community

- Join 9000+ DevOps Engineers today via [Community Slack](https://launchpass.com/collabnix)
- Join our [Discord Server](https://discord.gg/QEkCXAXYSe)
- Fork, Contribute & Share via [Kubelabs GITHUB Repository](https://github.com/collabnix/kubelabs)
-  Click and Follow us over Twitter [![Twitter URL](https://img.shields.io/twitter/url/https/twitter.com/fold_left.svg?style=social&label=Follow%20%40collabnix)](https://twitter.com/collabnix)
-  Access [500+ blogs](https://collabnix.com) on Docker, Kubernetes and Cloud-Native Technology

# Featured Articles

- [Kubernetes CrashLoopBackOff Error: What It Is and How to Fix It?](https://collabnix.com/kubernetes-crashloopbackoff-error-what-it-is-and-how-to-fix-it/)
- [Top 5 Kubernetes Backup and Storage Solutions: Velero and More](https://collabnix.com/top-5-kubernetes-backup-tools-you-should-be-aware-of/)
- [Top 5 Storage Provider Tools for Kubernetes](https://collabnix.com/top-5-storage-provider-tools-for-kubernetes/)
- [Top 5 Alert and Monitoring Tools for Kubernetes](https://collabnix.com/top-5-alert-and-monitoring-tools-for-kubernetes/)
- [Top 5 Machine Learning Tools For Kubernetes](https://collabnix.com/top-5-machine-learning-tools-for-kubernetes/)
- [Top 5 Cluster Management Tools for Kubernetes in 2023](https://collabnix.com/top-5-cluster-management-tools-for-kubernetes-in-2023/)
- [10 Tips for Right Sizing Your Kubernetes Cluster](https://collabnix.com/10-tips-for-right-sizing-your-kubernetes-cluster/)
- [Step-by-Step Guide to Deploying and Managing Redis on Kubernetes](https://collabnix.com/deploying-and-managing-redis-on-kubernetes/)
- [Update Your Kubernetes App Configuration Dynamically using ConfigMap](https://collabnix.com/update-your-kubernetes-app-configuration-dynamically-using-configmap/)
- [Streamline Your Deployment Workflow: Utilizing Docker Desktop for Local Development and OpenShift for Production Deployment](https://collabnix.com/streamline-your-deployment-workflow-utilizing-docker-desktop-for-local-development-and-openshift-for-production-deployment/)
- [The Impact of Kube-proxy Downtime on Kubernetes Clusters](https://collabnix.com/the-impact-of-kube-proxy-downtime-on-kubernetes-clusters/)
- [How to add a Secret to a Deployment in Kubernetes using Kubectl patch](https://collabnix.com/how-to-add-a-secret-to-a-deployment-in-kubernetes-using-kubectl-patch/)

## Pre-requisite:

- [Introductory Slides](https://collabnix.github.io/kubelabs/Kubernetes_Intro_slides-1/Kubernetes_Intro_slides-1.html) 
- [Deep Dive into Kubernetes Architecture](./Kubernetes_Architecture.md) 


## Preparing 5-Node Kubernetes Cluster

### PWK:

  - [Preparing 5-Node Kubernetes Cluster](./kube101.md) 
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
- [How to know if Kubernetes is using Docker or Containerd as a runtime](detect.md)

## Kubernetes CRUD 

- [Using Python](python/README.md)
- [Using Go](golang/README.md)

## Using AI

- [Deploying Kubernetes via AI](./ai/README.md)


## Pods101

 - [Introductory Slides](https://collabnix.github.io/kubelabs/Pods101_slides/Pods101.html) 
 - [Deploying Your First Nginx Pod](./pods101/deploy-your-first-nginx-pod.md) 
 - [Viewing Your Pod](./pods101/deploy-your-first-nginx-pod.md#viewing-your-pods) 
 - [Where is your Pod running on?](./pods101/deploy-your-first-nginx-pod.md#which-node-is-this-pod-running-on) 
 - [Pod Output in JSON](./pods101/deploy-your-first-nginx-pod.md#output-in-json) 
 - [Executing Commands against Pod](./pods101/deploy-your-first-nginx-pod.md#executing-commands-against-pods) 
 - [Terminating a Pod](./pods101/deploy-your-first-nginx-pod.md#deleting-the-pod) 
 - [Adding a 2nd container to a Pod](./pods101/deploy-your-first-nginx-pod.md#ading-a-2nd-container-to-a-pod) 
 - [Labels and Selectors in a Pod](./pods101/labels-and-selectors/README.md)

### Kubernetes Tools for Pods

- [Kubetail](https://github.com/collabnix/kubelabs/blob/master/pods101/tools/kubetail.md)

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

## ConfigMaps101
 - [What are ConfigMaps?](./ConfigMaps101/what-are-configmaps.md)

## Scheduler101

 - [How Kubernetes Selects the Right node?](./Scheduler101/README.md)
 - [Node Affinity](./Scheduler101/node_affinity.md) 
 - [Anti-Node Affinity](./Scheduler101/Anti-Node-Affinity.md) 
 - [Nodes taints and tolerations](./Scheduler101/Nodes_taints_and_tolerations.md) 
 
 

## Services101
 
  - [Introductory Slides](https://collabnix.github.io/kubelabs/Slides_Services101/Services101.html) 
  - [Deploy a Kubernetes Service?](./Services101/README.md#deploying--a-kubernetes-service)
  - [Labels and Selectors](https://github.com/collabnix/kubelabs/blob/master/Labels-and-Selectors/README.MD)
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
- [Ingress with EKS](./Ingress101/ingress-eks.md)
  


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
 - [Fluentd on Kubernetes](./Logging101/fluentd-kube.md)
 - [Fluent Bit](./Logging101/fluentdbit.md)
 - [ELK on Kubernetes](./Logging101/elk-on-kubernetes.md)

## Autoscalers101

 - [What are autoscalers](./Autoscaler101/what-are-autoscalers.md)
 - [Autoscaler lab](./Autoscaler101/autoscaler-lab.md)
 - [Autoscaler helpers](./Autoscaler101/helpers.md)

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
- [ArgoCD with EKS](./GitOps101/argocd-eks.md)

## Managed Kubernetes Service
- [Managed Kubernetes Service Intro](./ManagedKubernetes/readme.md)

## EKS101
- [What is EKS](./EKS101/what-is-eks.md)

## LKE101
- [What is LKE](./LKE101/what-is-lke.md)

## GKE101
- [What is GKE](./GKE101/what-is-gke.md)
- [Google Cloud Run](./GKE101/cloud-run.md)
- [GKE Service Mesh](./GKE101/gke-service-mesh.md)

## Loft101
- [What is Loft](./Loft101/what-is-loft.md)
- [Loft Lab](./Loft101/loft-lab.md)

## Shipa101
- [What is Shipa](./Shipa101/what-is-shipa.md)
- [Shipa Lab](./Shipa101/shipa-lab.md)

## DevSpace101
- [What is DevSpace](./DevSpace101/what-is-devspace.md)
- [DevSpace Lab](./DevSpace101/devspace-lab.md)

## KubeSphere101
- [What is KubeSphere](./KubeSphere/what-is-kubesphere.md)
- [KubeSphere lab](./KubeSphere/kubesphere-lab.md)

## Kubernetes with GitLab 101
- [What is GitLab](./GitLab101/what-is-gitlab.md)
- [Kubernetes with GitLab](./GitLab101/kubernetes-with-gitlab.md)
- [GitLab runner on Kubernetes](./GitLab101/runner-on-kubernetes.md)

## Kubernetes with Jenkins
- [Jenkins on Kubernetes](./Jenkins101/jenkins-on-kubernetes.md)
- [Using Jenkins on Kubernetes](./Jenkins101/jenkins-ci.md)

## Strimzi (Kafka on Kubernetes)
 - [What is Kafka](./Strimzi101/kafka.md)
 - [Running Kafka on Kubernetes](./Strimzi101/kafka-on-kubernetes.md)

## Java client for Kubernetes
 - [Introduction](./JavaClient101/intro.md)

## KEDA
- [What is KEDA](./Keda101/what-is-keda.md)
- [KEDA lab](./Keda101/keda-lab.md)
- [Scaling with KEDA and Prometheus](./Keda101/keda-prometheus.md)

## Terraform EKS
- [What is Terraform](./Terraform101/what-is-terraform.md)
- [Terraform EKS Lab](./Terraform101/terraform-eks-lab.md)

## Disaster Recover
- [What is Disaster Recovery](./DisasterRecovery101/what-is-dr.md)
- [DR Lab](./DisasterRecovery101/dr-lab.md)

## Kubezoo
- [What is Kubezoo](./Kubezoo/what-is-kubezoo.md)
- [Kubezoo lab](./Kubezoo/kubezoo-lab.md)

## Karpenter
- [What is Karpenter](./Karpenter101/what-is-karpenter.md)
- [Karpenter Lab](./Karpenter101/karpenter-lab.md)

## Observability & Operations
- [Observability tools](./Observability101/observability.md)

## For Node Developers
- [Kubernetes for Node Developers](./nodejs.md)

## Cheat Sheets
- [Kubernetes Cheat Sheet](./Cheat%20Sheets/Kubernetes%20Cheat%20Sheet.md)
- [Helm Cheat Sheet](./Cheat%20Sheets/Helm%20Cheat%20Sheet.md)

# Contributors

- [Ajeet Singh Raina](https://twitter.com/ajeetsraina)
- [Sangam Biradar](https://twitter.com/BiradarSangam)
- [Mewantha Bandara](http://linkedin.com/in/mewantha-bandara)
- [Rachit Mehrotra](https://www.linkedin.com/in/rachit-mehrotra-08a92819/?originalSubdomain=in)
- [Saiyam Pathak](https://twitter.com/SaiyamPathak)
- [Divyajeet Singh](https://www.linkedin.com/in/divyajeet-singh)
- [Apurva Bhandari](https://www.linkedin.com/in/apurvabhandari-linux)

## Workshop Video



[![YouTube](https://github.com/collabnix/kubelabs/blob/master/k8sworkshop.png)](https://www.youtube.com/embed/i0d5ta83c-k)

[Click Here](https://www.youtube.com/embed/i0d5ta83c-k) if the link is not working for you.

## Contribution Guidelines

## Step 1. Clone the repository

```
 git clone https://github.com/collabnix/kubelabs
```

## Step 2. Add _config_dev.yml

Add the following entry for local access

```
url: http://127.0.0.1:4000
```

## Step 2. Run the container


```
docker run --rm \
  -v "$PWD:/srv/jekyll" \
  -e BUNDLE_PATH="/srv/jekyll/.bundles_cache" \
  -p 4000:4000 \
  jekyll/builder:3.8 \
  bash -c "gem install bundler && bundle install && bundle exec jekyll serve --host 0.0.0.0 --verbose --config _config.yml,_config_dev.yml"
 ```




# Further References:

- [Kubetools](https://kubetools.collabnix.com)



[Next:  Kubernetes201](https://github.com/collabnix/kubelabs/blob/master/201/README.md)




