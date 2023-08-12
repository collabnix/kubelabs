# Terraform101

You've probably heard of Infrastructure as code if you're in the field of DevOps. You've also likely heard of some IaC tools such as Ansible, Chef, Puppet, Terraform, etc... In this section, we will be diving into the world of Terraform, and how you can use Terraform to automate the creation of Kubernetes clusters.

Before we start, you must understand the usage of these tools. For example, while Ansible and Terraform are both IaC tools, they cannot be used in the same way. So if you wanted to create your own self-managed cluster where you manage your own master and worker nodes in different VMs, Ansible is better suited to the task. However, if you were using a managed Kubernetes solution such as EKS, Terraform would be the way to go. Therefore, this section will use EKS as the platform on which we set up the cluster.

## Requirements

You will need an EKS cluster, kubectl, and Terraform. A free-tier AWS account should be able to handle the lab session we will have in this section.