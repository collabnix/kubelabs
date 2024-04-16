# Karpenter Lab

## Requirements

Before we start, you need to have a simple EKS cluster. Using `eksctl` is the fastest way to get everything up and running, so look through the [relevant section](../EKS101/what-is-eks.md) and run the `create cluster` command. If you are going to be creating the cluster manually, make sure that it runs the latest EKS version possible. Once you create the cluster, make it a point to go into the plugins section and add all the necessary plugins (VPC CNI, kube proxy, cluster autoscaler). The cluster autoscaler will be removed later in favor of Karpenter, but let's have some form of infrastructure scaling available now. As for the nodegroup, you can create a single nodegroup with a single node that runs a t3 small machine. Karpenter will be changing all of this later. You will also need to set up the IAM master & nodegroup roles accordingly. Before we begin, please note that this lab assumes you have already set up a cluster with the cluster autoscaler. If that's not the case, you can follow the instructions in the [Karpenter documentation](https://karpenter.sh/docs/getting-started/getting-started-with-karpenter/) to set up Karpenter along with a Kubernetes cluster.

In addition, you will need a Linux machine with your AWS profile and AWS CLI set up. This machine should have access to your Kubernetes cluster, as the instructions for setting up Karpenter will involve several Linux commands. You will also need to have Helm installed.

Now, let's move on to the lab. Setting up Karpenter involves several steps, as you will need to give Karpenter access to your cluster, nodegroups, and cluster resources. However, the steps are pretty straightforward, so there is little chance of errors popping up in the setup process.

Before we begin, it's worth noting that Karpenter has a [Terraform module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest/submodules/karpenter) that can be used if you plan on setting up Karpenter across multiple clusters. This way, you wouldn't need to set up Karpenter for each cluster manually. However, the use of Terraform to set up Karpenter is not covered in this section.

To get started, let's set up variables that define your Kubernetes cluster. Make sure to set the cluster name properly.

```
KARPENTER_NAMESPACE="kube-system"
KARPENTER_VERSION="0.36.0"
K8S_VERSION="1.29"
CLUSTER_NAME="<cluster-name>
```

Now let's define your AWS environment:

```
AWS_PARTITION="aws"
AWS_REGION="$(aws configure list | grep region | tr -s " " | cut -d" " -f3)"
OIDC_ENDPOINT="$(aws eks describe-cluster --name "${CLUSTER_NAME}" \
    --query "cluster.identity.oidc.issuer" --output text)"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' \
    --output text)
ARM_AMI_ID="$(aws ssm get-parameter --name /aws/service/eks/optimized-ami/${K8S_VERSION}/amazon-linux-2-arm64/recommended/image_id --query Parameter.Value --output text)"
AMD_AMI_ID="$(aws ssm get-parameter --name /aws/service/eks/optimized-ami/${K8S_VERSION}/amazon-linux-2/recommended/image_id --query Parameter.Value --output text)"
GPU_AMI_ID="$(aws ssm get-parameter --name /aws/service/eks/optimized-ami/${K8S_VERSION}/amazon-linux-2-gpu/recommended/image_id --query Parameter.Value --output text)"
```

While there may be a lot of different properties defined up there, you likely don't need to change anything from the default values that you see above since all the necessary information is extracted from your AWS profile.

First, let's deal with the IAM role that is needed. Much like you already have your nodegroup IAM role that gives all the pods in your node the access it needs to perform their tasks, we will need to create an AWS role for Karpenter. Let's start by creating the trust policy:

```
echo '{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}' > node-trust-policy.json
```

Next, let's create the role, pointing it to the trust policy we just created:

```
aws iam create-role --role-name "KarpenterNodeRole-${CLUSTER_NAME}" \
    --assume-role-policy-document file://node-trust-policy.json
```

Now, we need the basic policies that every nodegroup role needs: 
- AmazonEKSWorkerNodePolicy
- AmazonEKS_CNI_Policy
- AmazonEC2ContainerRegistryReadOnly
- AmazonSSMManagedInstanceCore

Let's go ahead and attach these policies to the nodegroup:

```
aws iam attach-role-policy --role-name "KarpenterNodeRole-${CLUSTER_NAME}" \
    --policy-arn "arn:${AWS_PARTITION}:iam::aws:policy/AmazonEKSWorkerNodePolicy"

aws iam attach-role-policy --role-name "KarpenterNodeRole-${CLUSTER_NAME}" \
    --policy-arn "arn:${AWS_PARTITION}:iam::aws:policy/AmazonEKS_CNI_Policy"

aws iam attach-role-policy --role-name "KarpenterNodeRole-${CLUSTER_NAME}" \
    --policy-arn "arn:${AWS_PARTITION}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

aws iam attach-role-policy --role-name "KarpenterNodeRole-${CLUSTER_NAME}" \
    --policy-arn "arn:${AWS_PARTITION}:iam::aws:policy/AmazonSSMManagedInstanceCore"
```