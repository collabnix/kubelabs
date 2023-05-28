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

### Region

As always, let's start off by looking at flags. Flags help you augment a command to perform your specific requirement. The first flag we will look at is the region. In all cases, you need to specify where a resource should get created.

```
---zone
```

The above flag lets you set the compute zone that is used when creating a GKE cluster. Note that you can also specify the locations of the individual nodes with:

```
--node-locations 
```

In the case of AKS, the situation is different, and you specify the region when you set:

```
--resource-group
```

When creating a resource group, you also assign a location to that resource group, which is where the cluster will be created. So when you want to specify a location in AKS, you do so by specifying the resource group instead of an actual location.

Finally, we have EKS:

```
--region
```

and 

```
--zones
```

Which allows you to specify the regions and zones for your EKS cluster.

### Machine type

Every Kubernetes cluster needs worker nodes. These are the nodes that do that actual work and therefore cost much more than the master node. In all cases, the worker nodes consist of regular vms provided by the cloud service. There are recommended specs for worker nodes, but the standard vm type should usually be fine.

```
-s 
```

This is the flag used with AKS to set the machine type, for example:

```
-s Standard_DS3_v2
```

It is equally straightforward with GKE:

```
--machine-type
```

example:

```
--machine-type=e2-medium 
```

With EKS, you get some more flexibility. You could either define:

```
--instanceType
```

and set it to a predefined type of EC2 instance

```
--instanceType=m5.large
```

Or specify the actual specs as arguments:

```
--instance-selector-vcpus
--instance-selector-memory
```

which will dynamically decide on the instance that gets spun up:

```
--instance-selector-vcpus=2 --instance-selector-memory=4
```

Note that you can do this with AKS as well:

```
--node-osdisk-type Ephemeral --node-osdisk-size 48
```

As well as GKE:

```
--disk-size=250
```

### Connecting to nodes

While the master node can fully manage the worker node, you will still need to ssh into the nodes for troubleshooting purposes. To do this, you will require ssh keys, which you can generate. Note that while these commands are regularly used in day-to-day cluster maintenance, you are not expected to memorize them.

```
--generate-ssh-keys
```

This flag needs to be set when creating the AKS cluster, which will result in SSH keys being generated for your worker nodes. You can then use these ssh keys to ssh into your Azure worker nodes.

However, you can also use `kubectl debug` to reach this same goal.

```
kubectl debug node/aks-nodepool1-12345678-vmss000000 -it --image=mcr.microsoft.com/dotnet/runtime-deps:6.0
```

The above command will run a container image in the node and connect to it.

You do much the same thing with GKE, where you get the ssh keys and use them to connect to the node:

```
kubectl --kubeconfig [CLUSTER_KUBECONFIG] get secrets -n [USER_CLUSTER_NAME] ssh-keys \
-o jsonpath='{.data.ssh\.key}' | base64 -d > \
~/.ssh/[USER_CLUSTER_NAME].key && chmod 600 ~/.ssh/[USER_CLUSTER_NAME].key
```

As you can see, the command is slightly complicated, and that is because it queries your cluster for the ssh keys, copies them, assigns the appropriate permissions, and prepares them for use.

As for EKS, since your worker nodes are ordinary EC2 instances and there already is an extensive system to connect to these instances, you can simply go ahead and [specify a key pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-launch-instance-wizard.html#liw-key-pair).

### Setting up multiple nodes

When creating your cluster, there is going to be a certain number of nodes that you want to be started. With AKS, you can specify this number with:

```
--node-count
```

So this command will create 2 worker nodes:

```
--node-count 2
```

It's pretty similar to GKE:

```
--num-nodes 2
```

As well as EKS:

```
--nodes=2
```

If you are using autoscaling clusters, you can set min and max nodes using pretty much the same syntax in EKS:

```
--nodes-min=3 --nodes-max=5
```

This also exists in GKE, where you have to use a different flag to enable autoscaling before you can set the min and max number of nodes:

```
--enable-autoscaling --min-nodes=1 --max-nodes=4
```

It's the same with Azure:

```
--enable-cluster-autoscaler --min-count 1 --max-count 3
```


### Cluster creation

Now that we have all the flags we need, let's put them together and create clusters.

All Kubernetes clusters need a master node, and all three services provide the master node at a very cheap price (AKS provides it free). Then, you also need one or more worker nodes. 

```
az aks create
```

This is the command used to create a cluster with AKS. This command should be followed by the necessary arguments:

```
az aks create --resource-group rgname --name clustername --node-count 2 --generate-ssh-keys
```

The above command shows a sample of how a cluster can be created in AKS, along with 2 worker nodes, and includes all of the flags we discussed previously.

```
gcloud container clusters create
```

This is how you would achieve the same thing with GKE. 

```
gcloud container clusters create CLUSTER_NAME \
    --zone COMPUTE_ZONE \
    --node-locations COMPUTE_ZONE,COMPUTE_ZONE1
    --machine-type=e2-medium 
```

Note that you provide the zone directly into the create command with gcloud while you provide the resource group to AKS. Since the zone is contained within the resource group, AKS uses that. Also note that similar to AKS, you can specify the worker nodes (and their machine types) with the command.

```
eksctl create cluster
```

The above command creates a cluster with AWS EKS. Note that while the other two cloud providers require you to provide additional information, with eksctl, the above command alone will create a cluster for you. The region will be your accounts' default region with one managed node group containing two m5.large nodes. Of course, you can specify the type of nodes.

With that, you can create clusters across all three Kubernetes engines. Now that the initial cluster is set up, we need to get the kube config for the cluster so that we can start interacting with it. So let's take a look at how we can do that.

### Get credentials

With AKS, the command is:

```
az aks get-credentials --resource-group <rg> --name <clustername>
```

This will automatically get the cluster kubeconfig and place it at `.kube/config` so that kubectl can immediately start using it. If you want to specify a different kubeconfig, you can do so with the `-f` flag:

```
--file 
```

or

```
-f
```

The syntax is largely similar to GKE, where you have to specify the cluster name and location:

```
gcloud container clusters get-credentials <clustername> --location=<clusterlocation>
```

Setting an alternate kubeconfig with GKE is different. For this, you need to create an environment variable called KUBECONFIG and set the path to the config file, which gets used. If not KUBECONFIG variable is present, it is automatically placed in the default location (`.kube/config`).

As for EKS, if you are using eksctl, you don't need to do anything, since the kubeconfig is created when you create the cluster. Setting the config file is the same as with GKE, where you set the KUBECONFIG parameter.

However, you can force update the kubeconfig if you require, using the same format as with AKS and GKE:

```
aws eks update-kubeconfig --region region-code --name my-cluster
```

Note that we use `aws eks` and not `eksctl` here.

### Scaling

One of the most obvious reasons to use Kubernetes is its ability to scale up and down to handle workloads. This ability is especially useful in the case of cloud providers, where you are paying for each moment the machine is running. Therefore it is important to remember the commands associated with scaling so that you don't end up paying for processing time that never gets used.

Let's start with EKS since that has an inbuilt [cluster autoscaler](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md). Getting this autoscaler running is simply a matter of adding a flag during cluster creation:

```
--asg-access
```

So the full command would be:

```
eksctl create cluster --asg-access
```

The autoscaler is fairly complex but is worth learning if you primarily use AWS since this will help you save a lot of costs.

### Managed nodegroups

Nodegroups (or nodepools) are collections of nodes that take away the responsibility of node management from your hands and places it in the hands of the cloud provider. This means that the provisioning and lifecycle management of these nodes is no longer your problem. This is obviously a very important feature of cluster management, and therefore all three cloud providers give you the option of using a nodegroup. So let's see how we can manipulate nodegroups with the CLI.

First, let's look at creating a nodegroup. In AKS, the stub that acts as a gateway to all other nodegroup commands is:

```
az aks nodepool
```

You would then append a keyword to this command. If you wanted to add a nodepool, you would append `add`:

```
az aks nodepool add -g MyResourceGroup -n nodepool1 --cluster-name MyManagedCluster --node-osdisk-type Ephemeral --node-osdisk-size 48
```

As you can see, the flags that were introduced in the previous sections can be used here as well. Note that these parameters are **mandatory**:

```
-cluster-name

--name --nodepool-name -n

--resource-group -g
```

In the same way, if you wanted to delete an item, you would append `delete`:

```
az aks nodepool delete --cluster-name
                       --name
                       --resource-group
                       [--no-wait]
```

### Cluster Deletion

Deleting clusters that you don't need is pretty important on the cloud since it can save you considerable amounts of money. Having an unused cluster that has idling worker nodes also makes it confusing to the cluster administrator when doing cluster maintenance. Fortunately, deleting clusters is a rather simple operation, regardless of the cloud service.

With AKS, you first need to stop the cluster:

```
az aks stop --name myAKSCluster --resource-group myResourceGroup
```

You can verify that the cluster is stopped:

```
az aks show --name myAKSCluster --resource-group myResourceGroup
```

Finally, you can delete the cluster:

```
az aks delete --name myAKSCluster --resource-group myResourceGroup
```

Note that while this deletes the cluster, the nodes are still active. This helps if you want to get the cluster back up and running quickly again. Otherwise, you can delete the node pool as well:

```
az aks nodepool delete -g myResourceGroup --cluster-name myAKSCluster --name myPool
```

But this will permanently delete the node pool, making it impossible to reclaim the cluster. Another option, therefore, is to scale down the entire node pool:

```
az aks nodepool scale --node-count 0 --name nodepool2 --cluster-name myAKSCluster --resource-group myResourceGroup
```

The above line will scale down the node count to 0, effectively meaning that all active nodes are no longer running.

Deleting clusters with GKE is even more straightforward. To delete the cluster, use:

```
gcloud container clusters delete CLUSTER_NAME
```

This will not only delete the cluster but the associated node instances as well. Similar to AKS, you could also scale a node pool as well:

```
gcloud container clusters resize CLUSTER_NAME \
    --node-pool POOL_NAME \
    --num-nodes NUM_NODES
```

Deleting an EKS cluster is as simple as creating one:

```
eksctl delete cluster --name CLUSTER_NAME
```

This will delete the cluster as well as any associated nodes. You could also scale nodegroups in a fairly simple manner:

```
eksctl scale nodegroup --cluster=<clusterName> --nodes=<desiredCount> --name=<nodegroupName> [ --nodes-min=<minSize> ] [ --nodes-max=<maxSize> ] --wait
```

## Conclusion

In this cheat sheet, you can find commands and flags for the three major cloud providers. We covered important cloud concepts that are needed before cluster creation such as region specification, machine specification, and infrastructure specification. Following this, we covered cluster creation, cluster authentication, and cluster scaling. Finally, we finished off with cluster deletion. This covers a large part of Kubernetes engine functions that are used daily.