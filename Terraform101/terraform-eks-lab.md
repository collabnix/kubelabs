## Lab

Now that you have all the requirements down, it's time to start creating the Terraform file. For starters, you need a VPC to host everything in, along with a subnet that can allocate your IPs. We will be creating 2 subnets: 1 private and 1 public. The cluster will be held within the private subnet for security reasons while there will be an ALB that connects to the public subnet and allows internet access to select ports on the cluster.

Let's start off with the VPC creation. To make things better formatted, we will create 3 files. One to hold the vpc variables, another to hold the outputs, and a final file that holds the actual VPC configuration. The variables file will hold all the variables, which is handy since you have every changing value consolidated into one file. After your VPC finishes being created, it will have things such as the VPC ID which is needed for future steps, since we need to assign this ID to every other resource we create. 

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

You might notice that this output file is a fair bit longer than the previous one. This is because the cluster has several important variables that need to be used by other resources. You first have the cluster identifiers, such as the cluster ID, arn, and endpoint. These values are needed when you want to deploy applications to your cluster. The next two values concern the IAM roles that you will be using to deal with that cluster. You also get the cluster security group information in the next variable. We will be diving into the security group in more detail later. Since any ports that we need to open should happen from the security group, we will need to add those configurations as well.

Next comes the outputs for the node group. Since we have a public and private node group, there is information about both node groups here such as the ID, ARN, version, etc... With that, we have now exposed all information about the cluster to be used by other scripts.

We are nearing the end of the configurations. The very last thing to define is the node groups themselves.