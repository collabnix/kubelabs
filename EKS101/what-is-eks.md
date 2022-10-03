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

## Cleaning up

Now, remember that all of the above things are AWS resources, and as such, you will be charged if you leave them running without deleting them after you are done. So this means you have a bunch of stuff (VPCs, cluster, EC2 instances) that you have to get rid of, which would have been a pain if you had to do it manually. However, since eksctl created all these resources for you, it can also get rid of all these resources for you, in the same manner, using a single command:

```
eksctl delete cluster --name kubelabs-cluster
```

This will also take a while to run, and all the resources you just created will be removed.

You now know all about setting up and running a cluster with AWS EKS. However, note that you are running your containers on EC2 instances, which aren't that flexible. So, while you ran the above cluster on a t2.micro instance, you might not be using the full resources that the VM provides. Alternatively, your cluster might grow to the point that you need more resources, forcing you to upgrade the VM. However, you might not end up using the full resources of your upgraded VM.

This means you might end up paying for resources that you don't use which is generally something you don't do when using AWS. Consider the case of AWS Lambda functions, where you have specific functions connected to your API, so that each request will run the function, and you **only pay for the number of times the function runs** instead of paying for an EC2 instance that runs forever. AWS now has a similar concept for running Kubernetes clusters, with [AWS Fargate](https://aws.amazon.com/fargate/).

So now, let's take a look at AWS Fargate.

[Next: AWS Fargate](./aws-fargate.md)