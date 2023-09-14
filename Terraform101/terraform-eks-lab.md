## Lab

Now that you have all the requirements down, it's time to start creating the Terraform file. For starters, you need a VPC to host everything in, along with a subnet that can allocate your IPs. We will be creating 2 subnets: 1 private and 1 public. The cluster will be held within the private subnet for security reasons while there will be an ALB that connects to the public subnet and allows internet access to select ports on the cluster.

Let's start off with the VPC creation. To make things better formatted, we will create 3 files. One to hold the vpc variables, another to hold the outputs, and a final file that holds the actual VPC configuration. The variables file will hold all the variables, which is handy since you have every changing value consolidated into one file. After your VPC finishes being created, it will have things such as the VPC ID which is needed for future steps, since we need to assign this ID to every other resource we create.

variable "aws_region" {
  description = "AWS region"
  type = string
  default = "us-east-1"  
}

variable "environment" {
  description = "env var used as a prefix"
  type = string
  default = "collabnix-cluster"
}

So for starters, we will create the vpc variable file. Name this file `vpc-variable.tf` and include the below variables:

```
variable "vpc_name" {
  description = "VPC Name"
  type = string 
  default = "myvpc"
}

variable "vpc_cidr_block" {
  description = "VPC CIDR Block"
  type = string 
  default = "10.0.0.0/16"
}

variable "vpc_availability_zones" {
  description = "VPC Availability Zones"
  type = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "vpc_public_subnets" {
  description = "VPC Public Subnets"
  type = list(string)
  default = ["172.13.1.0/24", "172.13.2.0/24"]
}

variable "vpc_private_subnets" {
  description = "VPC Private Subnets"
  type = list(string)
  default = ["172.13.3.0/24", "172.13.4.0/24"]
}

variable "vpc_enable_nat_gateway" {
  description = "Enable NAT Gateways for Private Subnets"
  type = bool
  default = true  
}

variable "vpc_single_nat_gateway" {
  description = "Enable single NAT Gateway"
  type = bool
  default = true
}
```

The variables are self-explanatory. There is the VPC name, CIDR block, and azs. Then there are the private and public subnets. Now that you have all the variables defined, it's simply a matter of plugging these variables into the VPC module.

As with EKS, we will be using a module to help us create the VPC. Call this file `vpc-module.tf`

Start by defining the vpc module:

```
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"
}
```

Now, add the variables previously defined as follows:

```
name = "collabnix"
cidr = var.vpc_cidr_block
azs = data.aws_availability_zones.available.names
public_subnets = var.vpc_public_subnets
private_subnets = var.vpc_private_subnets  
```

Enable the NAT gateway and DNS:

```
enable_nat_gateway = true
single_nat_gateway = true
enable_dns_hostnames = true
enable_dns_support   = true
```

And that's it! This will automatically create the new VPC, subnet, and relevant security groups.

Once all that is created, you need some way to be able to reference these resources. After all, every other resource you create is going to be inside them and therefore needs their relevant ids. So, you now need an output file. This output file will handle all of the outputs such as ids and other variables that get created after the script has finished running.

Create a file called `vpc-outputs.tf` and define the outputs.

```
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR blocks"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "Public subnets IDs"
  value       = module.vpc.public_subnets
}

output "azs" {
  description = "Az list"
  value       = module.vpc.azs
}
```

This will allow you to output important information such as VPC IDs, and CIDR blocks alongside information about the subnet. This information can then be used by other Terraform resources like this:

```
subnet_ids = module.vpc.private_subnets
```

At this point, you should have everything you need to set up your VPC, subnet, and security groups. Now, it's time to set up the cluster. Similar to the VPC, we will be using the EKS module to set it up, and likewise, we will have files for variables and outputs. Let's start with creating the variable file. Name it `eks-variables.tf` and populate it with the below values:

```
variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  default     = "COLLABNIX"
}

variable "cluster_service_ipv4_cidr" {
  description = "ipv4 cidr for kubernetes cluster"
  type        = string
  default     = null
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = null
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "Public API server endpoint accessible CIDR blocks"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
```

Before we get defining the cluster tf file, there are a couple of prerequisites that need to be created. As you already know, a cluster has nodes that are basically VMs. In the case of AWS, these are EC2 instances. As such, we need to create an IAM role that is able to work with them, along with a couple of specialized EKS policies. Create a file called `eks-iamrole.tf` and add the following script:

```
resource "aws_iam_role" "eks_iam_role" {
  name = "eks_iam_role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonSSMFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
  role       = aws_iam_role.eks_nodegroup_role.name
}
```

This role will be used by the EKS nodegroups. As such, they have policies about EC2, EKS, and SSM. A role like this gets created for you when you use `eksctl` to create a cluster.

Next, let's define the file that houses the EKS resource. Call this file `eks-cluster.tf`, and populate it with the below content:

```
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_iam_role.arn
  version = var.cluster_version

  vpc_config {
    subnet_ids = module.vpc.private_subnets
    endpoint_private_access = "true"
    endpoint_public_access  = "false"
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs    
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.cluster_service_ipv4_cidr
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController,
  ]
}
```

The above script will create the cluster. However, note that we have not mentioned anything about nodegroups in the above tf script. Running this script alone will create a control plane and set up the cluster in EKS, but you won't be able to deploy anything since you don't have any nodes. You specify the cluster name, role, version, and vpc_config along with any other dependencies. As with the creation of the VPC, running this Terraform file will create a bunch of resources that you will need to reference in the future. Therefore, we need an EKS outputs file. Create a new file and call it `eks-outputs.tf`. Populate it with the following:

```
output "cluster_id" {
  description = "ID of the EKS cluster."
  value       = aws_eks_cluster.eks_cluster.id
}

output "cluster_arn" {
  description = "Cluster ARN."
  value       = aws_eks_cluster.eks_cluster.arn
}

output "cluster_endpoint" {
  description = "EKS Kubernetes API endpoint."
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_version" {
  description = "Kubernetes version."
  value       = aws_eks_cluster.eks_cluster.version
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster."
  value       = aws_iam_role.eks_dr_master_role.name 
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster."
  value       = aws_iam_role.eks_dr_master_role.arn
}

output "cluster_primary_security_group_id" {
  description = "Cluster SG."
  value       = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}
```

You might notice that this output file is a fair bit longer than the previous one. This is because the cluster has several important variables that need to be used by other resources. You first have the cluster identifiers, such as the cluster ID, arn, and endpoint. These values are needed when you want to deploy applications to your cluster. The next two values concern the IAM roles that you will be using to deal with that cluster. You also get the cluster security group information in the next variable. We will be diving into the security group in more detail later. Since any ports that we need to open should happen from the security group, we will need to add those configurations as well.

We are nearing the end of the configuration. The very last thing to define is the node groups themselves. Before we do that, you need to create an ec2 key-pair. This is going to be used to connect to the nodegroup instances. However, this cannot be automated as of yet by Terraform, so you will need to do it manually. Head over to the EC2 section in AWS and select the key pair option. Create a key pair with all the default options and name it "eks-key". Now, we are ready to create the nodegroups. We will have public and private nodegroups. Let's start with the private nodegroup. Begin by creating a file called `node-group-private.tf`:

```
resource "aws_eks_node_group" "eks_ng_private" {
  cluster_name    = aws_eks_cluster.eks_cluster.name

  node_group_name = "eks-ng-private"
  node_role_arn   = aws_iam_role.eks_iam_role.arn
  subnet_ids      = module.vpc.private_subnets
  
  ami_type = "AL2_x86_64"  
  capacity_type = "ON_DEMAND"
  disk_size = 100
  instance_types = ["t3.small"]
  
  
  remote_access {
    ec2_ssh_key = "eks-key"    
  }

  scaling_config {
    desired_size = 2
    min_size     = 1    
    max_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
  ]  
  tags = {
    Name = "Private-Node-Group"
  }
}
```

Most of the above values are self-explanatory. We set the cluster name so that the node group knows which cluster to attach to. Then the IAM role that we created earlier is set. Note that we make use of outputs here. The IAM role ARN is not something that is hardcoded, and we are taking the output value of the previous .tf file that ran and created the role. This is a good demonstration of why the output files are important.

Additionally, we set the subnet IDs that we specified in the VPC module (which were hardcoded there) and then give information about the type of machines we want our nodes to be. In this case, we are using a machine with a disk size of 100 and a t3 small instance to ensure that we don't go beyond free tier limits. Next comes the key pair that you made earlier. Since the key is already in AWS, you can just specify the name of the key and EKS will automatically use it.

Next is the scaling section. Depending on the workload faced by your EKS cluster, the number of nodes needs to scale up and down so that operations keep running smoothly. However, you need some control over this scaling as it can affect your costs. In the above case, we tell AWS to keep at least 1 node running at all times, and a maximum of 2 nodes if needed. We then finish the node group configuration by setting the dependent IAM policies so that the permissions are in place. With that, the node group is complete.

In the same way, you exposed the output values of the EKS cluster and VPC, the outputs of this node group need to be available to other resources. So we need another output file. Since the node group is part of the EKS cluster, it makes logical sense to simply put the outputs in the EKS outputs file instead of creating a new one, thereby logically grouping everything. So open up the `eks-outputs.tf` file and append these output values:

```
output "node_group_public_id" {
  description = "Public Node Group ID"
  value       = aws_eks_node_group.eks_ng_public.id
}

output "node_group_public_arn" {
  description = "Public Node Group ARN"
  value       = aws_eks_node_group.eks_ng_public.arn
}

output "node_group_public_version" {
  description = "Public Node Group Kubernetes Version"
  value       = aws_eks_node_group.eks_ng_public.version
}

output "node_group_private_id" {
  description = "Node Group 1 ID"
  value       = aws_eks_node_group.eks_ng_private.id
}

output "node_group_private_arn" {
  description = "Private Node Group ARN"
  value       = aws_eks_node_group.eks_ng_private.arn
}

output "node_group_private_version" {
  description = "Private Node Group Kubernetes Version"
  value       = aws_eks_node_group.eks_ng_private.version
}
```

Since we have a public and private node group, there is information about both node groups here such as the ID, ARN, version, etc... With that, we have now exposed all information about the cluster to be used by other scripts.

Once your cluster has finished setting up, you might want to run kubectl commands on it. While this can be done from your host machine, you might also want to do things such as create namespaces from within your Terraform scripts themselves. This means that your scripts need to create the cluster and also connect to the cluster that was newly created to run a `kubectl create ns` command in it. To do this, we need to introduce a Kubernetes provider. Create a file called `kubernetes-provider.tf` and add the following blocks:

```
data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.eks_cluster.id
}

provider "kubernetes" {
  host = aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  token = data.aws_eks_cluster_auth.cluster.token
}
```

You can see several outputs being referenced here, such as the ID of the cluster, along with the cluster endpoint, certificate authority, and cluster token. This is so that any kubectl commands that need to run in the future know exactly what cluster they need to run on, and that the command has the necessary authority to run it.

## Running the scripts

Now with everything set up, it's time to start deploying the Terraform scripts. To begin, you need to install the Terraform CLI, which is pretty straightforward if you [follow the docs](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli). Next, you need to set up access between your Terraform scripts and AWS account. You don't need any special configuration for this. If you have already done `aws configure`, Terraform should be able to use those credentials.

Open up a terminal or command prompt and run:

```
terraform init
```

This will download all the necessary providers such as AWS and Kubernetes, alongside the required modules such as EKS and VPC. While it isn't really necessary, you can head over to the `.terraform` folder that will have been created as a result of the last command so that you can see how the modules and providers have been downloaded and structured within your local machine. Once you have a good idea of the way Terraform handles external providers, we can move on to the next step. As you might have guessed, we are about to deploy a whole bunch of resources to AWS. Since there are several files that have been created which may have errors in them, run the following command:

```
terraform validate
```

This will identify any obvious errors or mistakes made in the configuration files. However, note that this isn't a guarantee that fixing those errors means that there will be no errors going forward. If validation fails, you will get a detailed error telling you how to fix it, if it passes, you are good to move on to the next part.

One great command that needs to be mentioned is `terraform fmt`. This will format the Terraform configuration files to have the correct indentation and line spacing so that the code looks nice. You only have to run it once and all the configuration files across the directory will be properly formatted.

Now we are ready to do the actual deployment, but it's always recommended to do one final step before that. Run the below command:

```
terraform plan
```

This command does a dry run of the deployment. It deploys the configuration files without actually deploying anything. It also provides an output that shows everything that has changed. If there were any errors that weren't caught by `terraform validate`, you will see them displayed here. There might be mistakes or errors that were made which don't technically count as syntax errors, and these can be caught here. Even so, this won't catch all the errors that may appear, and some may show up only when you actually apply the configurations. Since this is the first time you are running Terraform, you might notice that everything has a green `+` sign next to it, indicating that all resources are going to be created. You can also see an exhaustive list of resources. It's worth going through them all one by one to make sure you aren't doing anything you don't intend to do.

In any subsequent runs, this command will also show you any resources that are getting removed as well as resources that remain unchanged. This allows you to have a complete overview of exactly what will happen when you run the final command. This is the plan that you have when deploying. You can also save this plan onto a file that can be read by Terraform so that you can come back at a later point and apply the configurations as dictated in this plan.

Once you have verified that everything is correct, it is finally time to apply your changes. Run this command:

```
terraform apply
```

This will run `terraform plan` again and ask you one more time to verify the changes that you are about to make. Type in `yes` and the cluster creation will begin.

The deployment will take a fair bit of time, and it is a good opportunity to look at how Terraform does the actual deployment. It will create the pre-requisite resources first before moving on to the dependent resources. The command can fail at any moment which would result in the deployment halting. What's important to note is that when the application fails, Terraform will NOT remove all of the resources it has created so far. Instead, it will take note of the point where it failed and do nothing beyond that. You can then fix the issue and run `terraform apply` again, which will start the deployment from the point where it failed, meaning that it doesn't have to create all those resources it did before.

A very important concept here is that Terraform does not like any external sources meddling with the infrastructure changes they do. For example, if you found out that you had accidentally duplicated an IAM role in your Terraform configuration, and therefore had a redundant role created by Terraform, you might want to simply head over to the IAM section on the AWS console and delete that role. However, this would be quite a headache the next time you want Terraform to do anything. This is because Terraform created that role, and now it no longer exists. To function properly, Terraform keeps a `.tfstate` file that you will notice getting created the second `terraform apply` starts running. If you open up this file, you will see that the entire state of your infrastructure is being written into this file. However, if you were to go off on your own and change resources in AWS, the state written in this file will no longer correctly reflect the state of your actual infrastructure. This means that the next time you run `terraform apply`, the command will fail.

So, the bottom line is that you should not modify resources created by Terraform yourself. If you want some change to happen, do it in the Terraform configuration scripts, and apply the changes. Terraform will handle the rest without breaking your infrastructure. However, if you happen to have existing infrastructure that was not created by Terraform, you can [import existing resources](https://developer.hashicorp.com/terraform/language/state/import) as long as you're running Terraform v1.5.0 or later. For example, to import an already existing ec2 instance, you would say:

```
import {
  to = aws_instance.example
  id = "i-abcd1234"
}

resource "aws_instance" "example" {
  name = "hashi"
  ...
}
```

This will add the infrastructure to the `.tfstate` file, allowing you to manage it with the rest of the configurations.

Now that we have looked at the ins and outs of `terraform apply`, let's continue with the actual application. Once the apply command has been completed, you should be able to head over to the AWS console and ensure that the resources are now created. This would include everything from the VPC, subnets, security groups, IAM roles, EKS cluster, nodegroups, and worker nodes. If you notice that something is missing, check to see if the apply command failed somewhere along the way. If not, there might be something missing from your configuration files. Whatever the case may be, remember that you should NOT create the resource manually since Terraform will not have any control over it. If you create a manual resource that depends on a resource the Terraform created (for example, you create a NAT gateway manually that links to a subnet created by AWS), then if you want to change anything about the subnet, you won't be able to do it with Terraform. This is because Terraform might have to delete and re-create the subnet for any changes to happen, and deleting a subnet is not possible if there are any dependent resources attached to it. If the dependent resource was also created by Terraform, this wouldn't be an issue since Terraform has control over it and will delete it in the correct order.

Now that the cluster is up and running, you can connect to this cluster. Use:

```
aws eks update-kubeconfig --name collabnix --region us-east-1 --alias collabnix
```

This will update your local kubeconfig file with the cluster information which will allow you to use `kubectl` commands as needed. Once you are confident that your infrastructure has been set up properly, let's move on to the final part of the process: deleting infrastructure.

## Destroying infrastructure

Since the cluster you created costs a fair bit of money to keep running, you should destroy it once you have finished the lab. Provided that you haven't made any changes manually using the AWS console or CLI, you should be able to delete everything in one step with:

```
terraform destroy
```

Similar to `terraform apply`, you will get a full list of all the resources that will be changed. In this case, you will see everything being deleted. Confirm the deletion and the cluster along with any VPCs, subnets, and other supporting resources should start getting destroyed. Similar to the apply command, it will take some time for the destroy command to complete. Once it is done, head over to the EKS page in the console and ensure that the cluster no longer exists.

## Conclusion

We have now reached the end of the Terraform lab about setting up an entire EKS cluster (along with the relevant pre-requisite resources) using Terraform. This is just the first step and only a fraction of what both Terraform and EKS can do. If you want more information on how Terraform can help you with EKS and other AWS resources, the best place for you to go is the [docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).