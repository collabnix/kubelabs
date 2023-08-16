# Terraform101

You've probably heard of Infrastructure as code if you're in the field of DevOps. You've also likely heard of some IaC tools such as Ansible, Chef, Puppet, Terraform, etc... In this section, we will be diving into the world of Terraform, and how you can use Terraform to automate the creation of Kubernetes clusters.

Before we start, you must understand the usage of these tools. For example, while Ansible and Terraform are both IaC tools, they cannot be used in the same way. So if you wanted to create your own self-managed cluster where you manage your own master and worker nodes in different VMs, Ansible is better suited to the task. However, if you were using a managed Kubernetes solution such as EKS, Terraform would be the way to go. Therefore, this section will use EKS as the platform on which we set up the cluster.

## Requirements

You will need an EKS cluster, kubectl, and Terraform. A free-tier AWS account should be able to handle the lab session we will have in this section.

From the AWS perspective, you won't need anything apart from your account since the whole setup process will be automated via Terraform. In fact, it is required that you don't interfere with the resources Terraform sets up for you. Either you manage the resources all by yourself, or you let Terraform manage the resources all by itself. There is no middle ground. Terraform needs to know the state every resource is in at all times, and if you were to go into the AWS console and change resources created by Terraform manually, then Terraform no longer has this information. As such it will be unable to handle the infrastructure for you.

Before we start, make sure you have some idea about AWS EKS. If you need a quick refresher, head over to the [EKS section](../EKS101/what-is-eks.md) and read up on the topic. 

## Terraform EKS module

If you remember `eksctl`, you will also recall that the reason it exists is to reduce the complexity of creating an EKS cluster. Since an EKS cluster is a resource in AWS, it needs all the prerequisites any other AWS resource needs. This means you will have to create a VPC, subnet, security groups, network ACLs, IAM roles, EC2 key pairs to access your worker nodes, etc... Or you could simply run:

```
eksctl create cluster
```

and all of the above will be created for you, along with a cluster.

When automating cluster creation with Terraform, you will need to set up all of the above things. However, as with the case of `eksctl`, where the common resources get created for you automatically, Terraform has modules, which do the same thing for you. You can find this module, as well as other modules and resources at the [Terraform registry](https://registry.terraform.io). The eks module we will be using can be found [here](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest). The basic usage of the module is given within the page itself:

```
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.16.0"
}
```

The real configuration needed to get EKS up and running is much bigger. You will need to specify the vpcs, subnets, and security groups (or let Terraform create those as well). The final file is going to be quite large. So let's jump straight into the lab.

[Terraform EKS Lab](./terraform-eks-lab.md)