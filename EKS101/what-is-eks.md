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

To start, head over to the EKS area on the AWS console, and navigate to clusters. If you are starting fresh, you will not see any clusters present in this area.