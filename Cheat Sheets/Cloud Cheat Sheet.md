# Cloud cheatsheet

There are several cloud providers out there, with Azure, AWS, and GCP dominating the market share. Each of these cloud providers has a fully managed Kubernetes platform that you can use to spin up a cluster within seconds without worrying about the infrastructure. They also handle the security, scaling, and other aspects that make them superior choices over self-managed clusters. While each cloud service has different commands, all of them run under the same concepts. So here, we will be discussing the various commands that are important to keep in memory for each of the three cloud providers. If you want a deep dive into each of these providers' Kubernetes engines, be sure to look at the relevant sections: [AKS](../AKS101/what-is-aks.md), [GKE](../GKE101/what-is-gke.md), [EKS](../EKS101/what-is-eks.md), [LKE](../LKE101/what-is-lke.md).

Note that most of the commands for these cloud providers can get quite complex, and it is unlikely that you will be expected to keep every command and every parameter in memory. Instead, the general format of the command is what you should try to remember. Also note that all three of these providers (as well as other providers) have a user-friendly console which you can use to perform operations on your cluster (as well as other cloud resources), so be sure to take advantage of that.

The command line options for each of these cloud providers are as follows:

**Azure**: az
**GCP**: gcloud
**AWS**: aws

When managing their respective Kubernetes engines, the commands would change. For everything you want to do anything with Microsoft AKS, you should use

```
az aks [COMMAND]
```

While anytime you want to use Amazon EKS, you should use

```
eksctl
```

Technically, you can manage your whole Kubernetes infrastructure through `aws` commands alone, but [eksctl](https://eksctl.io) significantly reduces the complexity of using those commands.

Let's start off with cluster creation. All Kubernetes clusters need a master node, and all three services provide the master node at a very cheap price (AKS provides it free). Then, you also need one or more worker nodes. These are the nodes that do that actual work and therefore cost much more than the master node. In all cases, the worker nodes consist of regular vms provided by the cloud service. There are recommended specs for worker nodes, but the standard vm type should usually be fine. 

```
az aks create
```

This is the command used to create a cluster with AKS. This command should be followed by the necessary arguments:

```
az aks create --resource-group rgname --name clustername --node-count 1 --generate-ssh-keys
```

The above command shows a sample of how a cluster can be created in AKS.

```
gcloud container clusters create
```

This is how you would achieve the same thing with GKE. 

```
gcloud container clusters create CLUSTER_NAME \
    --zone COMPUTE_ZONE \
    --node-locations COMPUTE_ZONE,COMPUTE_ZONE1
```

Note that you provide the zone directly into the create command with gcloud while you provide the resource group to AKS. Since the zone is contained within the resource group, AKS uses that.

```
eksctl create cluster
```

The above command creates a cluster with AWS EKS. Note that while the other two cloud providers require you to provide additional information, with eksctl, the above command alone will create a cluster for you. The region will be your accounts' default region with one managed nodegroup containing two m5.large nodes.