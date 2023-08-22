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

Next, let's define the file that houses the EKSmodule.