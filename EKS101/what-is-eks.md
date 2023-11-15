# Amazon Elastic Kubernetes Service

You are most likely aware of AWS, and the benefits that using a cloud solution like that can have. AWS is the largest cloud provider in the world and has hundreds of services that it provides for a fraction of the cost it takes for you to set up those services yourself (if you can set them up by yourself in the first place). EKS is one of those services and works similar to other rival Kubernetes solutions, such as [AKS](../AKS101/what-is-aks.md), and [LKE](../LKE101/what-is-lke.md).

Since you most likely have used some form of Kubernetes engine at some point, you are probably aware of the problems that exist when setting up the cluster. Software such as minikube makes the process easy, but it is meant for development work and not for large-scale clusters. If you were part of an organization and were planning to run all your clusters on-premise, then you would need separate teams to manage the cluster, teams to enforce cluster security, and other people to maintain cluster infrastructure such as the servers on which these clusters run. In a large organization, this may be somewhat practical. However, for start-ups and even mature companies, hiring all these people and equipment is a costly endeavor that borders on impractical.

EKS, therefore, acts as a reliable solution. Your master nodes will all be managed by EKS, including their security, infrastructure, and backups. You would also be able to scale up and down without having to worry about purchasing new servers and be able to handle everything in an intuitive UI of the AWS console. This means that even a single developer can leverage the power of EKS and start using the Kubernetes cluster without having to worry about start-up costs. They also no longer need to be experts in Kubernetes since EKS does most of the work for them.

## The complexity of EKS

To start, you need to have an AWS account, but that's only the start of the process. You also need a [VPC](https://docs.aws.amazon.com/directoryservice/latest/admin-guide/gsg_create_vpc.html), as well as an [IAM user](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html). You need to make sure this user has the permissions necessary to work with your EKS clusters. When setting up your EKS clusters, you will be using the IAM role to create the clusters, and you will also need to specify a VPC for the cluster to run on, which is why these two prerequisites exist. 

From here onwards, the rest of the steps would seem familiar to you if you have set up a cluster in a cloud service before. You now have to create worker nodes. While each cloud service handles the worker nodes differently, the concept is the same. In the case of EKS, the worker node is an EC2 instance. You will also need to set the cluster it should attach to, along with the security group and the limit on the number of nodes that your cluster may scale up and down depending on the amount of traffic they experience.

## eksctl

All of the above steps might seem complicated, and that is correct. Since AWS is so powerful, there is bound to be some complexity in there since you have so many options. However, some great news is that you don't really have to do any of the above manually. Instead, the community has created a simple tool to help you get up and running in a few commands: [eksctl](https://github.com/weaveworks/eksctl).

You might be familiar with kubectl if you have done anything with Kubernetes before, or lkectl if you've worked Linode's Kubernetes engine. Similar to them eksctl is the command line tool we can use to interact with our cluster. The GitHub readme shows the simple process needed to create a cluster:

```
eksctl create cluster
```

This will set all the values to the defaults, and create the cluster for you. All the prerequisites that you would have had to do yourself are now handled by eksctl. For eksctl to work, you will need to have AWS API credentials configured. If you have used something like the AWS CLI before, then you would have already configured this. You also need [aws-iam-authenticator](https://github.com/kubernetes-sigs/aws-iam-authenticator) for you to be able to authenticate properly, as well as [configure credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) so that eksctl on your local machine can connect to your cloud account to run various commands. Get the latest release and include it in your ```PATH```. That's just about all you need.

You might notice that the very basic usage shown above does not even include a name for your cluster. This means that eksctl will auto-generate the name as well. You will also get 2x ```m5.large``` nodes (best for common use) in the ```us-west-2``` region, and create a default dedicated VPC for you. Naturally, you might not find these default values to your specification, so you have the option to specify them. For example, the ```--region``` option can be used to set the region, ```--name``` allows you to set the name of the cluster. You can set all values manually, so a command like this can change everything at the point of cluster creation:

```
eksctl create cluster --name my-cluster --region region-code --version 1.23 --vpc-private-subnets subnet-ExampleID1,subnet-ExampleID2 --without-nodegroup
```

Even with this longer create command, you can see that this is far less complicated and more straightforward as opposed to writing multiple commands on the AWS CLI, or even navigating through the AWS console.

To start, head over to the EKS area on the AWS console, and navigate to clusters. If you are starting fresh, you will not see any clusters present in this area. To create a cluster, use eksctl. We are going to be creating a cluster with the name "kubelabs-cluster" that runs on Kubernetes v1.24. You can set the region to be anything that is closest to you geographically. We are also going to be creating worker nodes that need to be grouped in a node group, and we will give a name for this node group. Remember earlier that we mentioned worker nodes being EC2 instances? Well, EC2 instances come in different sizes, and you can specify exactly what type of EC2 instance you want your worker nodes to be running, as well as the number of nodes you want. A full list of available types is mentioned [here](https://aws.amazon.com/ec2/instance-types/). We are going to be using the ```t2.micro```, which has 1GB memory, 1 CPU, and is free tier eligible.

```bash
eksctl create cluster \
--name kubelabs-cluster \
--version 1.24 \
--region <your closest region> \
--nodegroup-name kubelabs-group \
--node-type t2.micro \ 
--nodes 2
```

You will have to wait sometime until this command is fully executed, and you can track the progress using the console output you get. First, the cluster will be created, at which point you can head over to the clusters page of the AWS console to see the cluster in action. After the cluster is created, the node group will start creating with the worker nodes that are supposed to be in it. Since these nodes are EC2 instances, you can see these nodes come up by heading over to the EC2 instance section of the AWS console. Another thing to note is that since a cluster was created, there is also a kubeconfig cluster created along with it so that the cluster can be accessed via kubectl commands. This config file will be placed in the default location (under the .kube folder) so that you don't have to do any additional configuration to start accessing the cluster from your local machine. You can verify this by running:

```
kubectl get nodes
```

and if you can see the 2 nodes, then you are all set.

## Additional considerations

Now that you have the entire cluster running on AWS, there are some things you may want to tweak to your liking. Firstly is the security group. While eksctl creates a default security group that has all the permissions needed to run your EKS cluster, it's best if you go back in and take another look at it. Firstly, ensure that your inbound rules do not allow 0.0.0.0, which would allow all external IPs to connect to your EKS ports. Instead, only allow IPs that you want to access your cluster through. You can do this by specifying the proper CIDR ranges and their associated ports. On the other hand, with outbound ports, allowing 0.0.0.0 is fine since this allows your cluster to communicate with any resource from outside your network.

The next thing you can look at is the node groups. Since you specified `t2.micro` in the above command, your nodegroups will be created with that machine type. You can use the AWS console to add node groups with specific tolerations so that only certain pods get scheduled on these nodes. You can read more about taints and tolerations in the [Scheduler101 section](../Scheduler101/Nodes_taints_and_tolerations.md). You can also check the Kubernetes version that is used in your cluster from here. If you follow the above tutorial, you will have a cluster with Kubernetes version 1.24. You can update this version from the console. However, note that a lot of things vary from version to version, and you might end up getting something in your existing application broken if you blindly update your Kubernetes version. However, updating the Kubernetes version is certainly important as AWS ends standard support for older Kubernetes versions (after a generous grace period). After this, the version enters extended support for another year during which support is subject to additional fees.

On the topic of updating, you will also notice an AMI version that is mentioned per each node group. Since you created this cluster recently, you will have the latest AMI version. However, AMIs get updated around twice each month, and while there won't be any major issues if you don't keep your AMIs updated, it is good to update as frequently as possible. Unlike updating the Kubernetes version, AMI updates are relatively safe since they only update the OS to have the latest packages specified by the AWS team. The update can be performed either as a rolling update, or a forced update. A rolling update will create a new node with the new AMI version and move all the pods in the old node to the new node before the old pods are drained and the old node is deleted. A forced update will immediately destroy the old node and start up a new node. The advantage of this method is that it is much faster and will always complete successfully, whereas a rolling update will take much longer and may fail to finish the update if any pods fail to drain.

Another thing to consider is cost tagging. In a large organization, you would have multiple AWS resources that contribute to a large bill that you get at the end of the month. Usually, teams involved in costing would want to know exactly where the costs come from. If you were dealing with a resource such as an EC2 instance, you would not have to look deeply into this as you can just go into the cost explorer, filter by service, and just ask for the cost of the EC2 instances which would give you an exact amount on how much you spend on the resources. However, this becomes much more complicated with the EKS cluster. Not only do you have EC2 instances running in EKS clusters, but you are also paying for the control plane. Additionally, you also pay for EC2 resources such as load balancers and data transfer, along with a host of other things. To fully capture the total cost of your EKS cluster, you must use [cost allocation tags](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/cost-alloc-tags.html)

First, go to your EKS cluster on the AWS console and add a tag with a value. Next, head over to each of your node groups and add the same tag-value pair to them. You can also use the same tags on any EC2 instances that have been spun up by the node group, but if your cluster scales down and comes back up at a later point, this will create brand new EC2 instances that won't have the tag on them. Therefore it is better to head over to the autocale groups section in your AWS console, select the group that corresponds to your EKS cluster, and add the tags there. Also, make sure you select the option to have the tags automatically added onto any new EC2 instances that get spun up by the ASG.

Next, take a look at the IAM role that is used by the cluster in the overview section. eksctl would have already given you the ideal level of permissions in the IAM role, so there is not much you would want to remove from here. However, if you want to allow your cluster to access any additional items, you should add those permissions at this point. The networking section shows you information about the network your cluster is in, including the IPv4 range, subnets, and security group. You can also manage access to the cluster endpoint from here.

The add-ons section allows you to get add-ons for your EKS cluster from the AWS marketplace, and the observability section is where you would enable CloudWatch container insights to get metrics and reports on your containers. Of course, if you wanted to go beyond what AWS was providing, you could go for tools such as Prometheus that give you better fine-grained control as well as better cross-platform integration.

## Cleaning up

Now, remember that all of the above things are AWS resources, and as such, you will be charged if you leave them running without deleting them after you are done. So this means you have a bunch of stuff (VPCs, cluster, EC2 instances) that you have to get rid of, which would have been a pain if you had to do it manually. However, since eksctl created all these resources for you, it can also get rid of all these resources for you, in the same manner, using a single command:

```
eksctl delete cluster --name kubelabs-cluster
```

This will also take a while to run, and all the resources you just created will be removed.

You now know all about setting up and running a cluster with AWS EKS. However, note that you are running your containers on EC2 instances, which aren't that flexible. So, while you ran the above cluster on a t2.micro instance, you might not be using the full resources that the VM provides. Alternatively, your cluster might grow to the point that you need more resources, forcing you to upgrade the VM. However, you might not end up using the full resources of your upgraded VM.

This means you might end up paying for resources that you don't use which is generally something you don't do when using AWS. Consider the case of AWS Lambda functions, where you have specific functions connected to your API, so that each request will run the function, and you **only pay for the number of times the function runs** instead of paying for an EC2 instance that runs forever. AWS now has a similar concept for running Kubernetes clusters, with [AWS Fargate](https://aws.amazon.com/fargate/).

So before we finish this lesson, let's take a quick look at AWS Fargate.

## AWS Fargate

The container orchestration part is already managed by EKS, so Fargate focuses on managing the infrastructure your containers and pods run on. This means that Fargate is serverless (just like AWS Lambda), and will spin EC2 instances up and down depending on your workload. You will not be creating any instances on your own account. You don't even need to specify the number of resources that need to be allocated since Fargate is capable of making that decision on its own.

Once the pod/container has finished running, Fargate will automatically spin down the instance, meaning that you will only pay for the resources you used and for how long you used them. Fargate also comes with integrations to other AWS services, such as IAM, CloudWatch, and Elastic Load Balancer. Fargate also works well with [AWS ECS](https://aws.amazon.com/ecs/), which is a container orchestration tool provided by Amazon similar to Kubernetes or Docker swarm.

To make things easier, you can use eksctl to create a cluster with Fargate support. Doing so is as easy as specifying the argument in CLI:

```
eksctl create cluster --fargate
```

One thing to note is that running your containers on Fargate means that you will not have any control over the infrastructure that it runs on since all that is managed by AWS. So if you need the environment the container runs in to be specific, EC2 instances are still your best option, so you might want to start considering Nodegroups.

Your Kubernetes cluster consists of nodes, and nodegroups, as the name implies, groups the nodes together. You can group several nodes into a single group in a way that makes logical sense, and have the nodegroup automatically manage itself. So you will still be using EC2 instances, but the Nodegroup will be creating, provisioning, and deleting the instances as needed. However, some features that Fargate offers such as scaling will no longer be available to you. So we can consider it a good middle group between manageability and flexibility.

As one last thing, before we finish, I would like to point out that another possibility is to have both Fargate and EC2 instances running to work for the same cluster. That is, you can create EC2 instances for the nodes that you need fine-grained control over while allowing Fargate to handle any other infrastructure that just needs to run, no matter how or where.

That concludes our lesson on AWS EKS.