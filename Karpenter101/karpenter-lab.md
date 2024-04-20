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

These are the basic policies every nodegroup needs. However, depending on your application, your pods might need additional permissions, so first check your existing nodegroup role and make sure that the newly created karpetner nodegroup role has all the policies it has.

Now that the node role has been set up, let's do the same thing for the node controller, starting with the trust policy:

```
cat << EOF > controller-trust-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:${AWS_PARTITION}:iam::${AWS_ACCOUNT_ID}:oidc-provider/${OIDC_ENDPOINT#*//}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "${OIDC_ENDPOINT#*//}:aud": "sts.amazonaws.com",
                    "${OIDC_ENDPOINT#*//}:sub": "system:serviceaccount:${KARPENTER_NAMESPACE}:karpenter"
                }
            }
        }
    ]
}
EOF
```

Now let's create the role:

```
aws iam create-role --role-name "KarpenterControllerRole-${CLUSTER_NAME}" \
    --assume-role-policy-document file://controller-trust-policy.json
```

Now comes the policy. This controller policy will span across all the different resources that Karpenter needs access to, such as SSM, ECR, EC2, EKS, IAM, etc... Let's put all this into a file first:

```
cat << EOF > controller-policy.json
{
    "Statement": [
        {
            "Action": [
                "ssm:GetParameter",
                "ec2:DescribeImages",
                "ec2:RunInstances",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeLaunchTemplates",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeInstanceTypeOfferings",
                "ec2:DescribeAvailabilityZones",
                "ec2:DeleteLaunchTemplate",
                "ec2:CreateTags",
                "ec2:CreateLaunchTemplate",
                "ec2:CreateFleet",
                "ec2:DescribeSpotPriceHistory",
                "pricing:GetProducts"
            ],
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "Karpenter"
        },
        {
            "Action": "ec2:TerminateInstances",
            "Condition": {
                "StringLike": {
                    "ec2:ResourceTag/karpenter.sh/nodepool": "*"
                }
            },
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "ConditionalEC2Termination"
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "arn:${AWS_PARTITION}:iam::${AWS_ACCOUNT_ID}:role/KarpenterNodeRole-${CLUSTER_NAME}",
            "Sid": "PassNodeIAMRole"
        },
        {
            "Effect": "Allow",
            "Action": "eks:DescribeCluster",
            "Resource": "arn:${AWS_PARTITION}:eks:${AWS_REGION}:${AWS_ACCOUNT_ID}:cluster/${CLUSTER_NAME}",
            "Sid": "EKSClusterEndpointLookup"
        },
        {
            "Sid": "AllowScopedInstanceProfileCreationActions",
            "Effect": "Allow",
            "Resource": "*",
            "Action": [
            "iam:CreateInstanceProfile"
            ],
            "Condition": {
            "StringEquals": {
                "aws:RequestTag/kubernetes.io/cluster/${CLUSTER_NAME}": "owned",
                "aws:RequestTag/topology.kubernetes.io/region": "${AWS_REGION}"
            },
            "StringLike": {
                "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass": "*"
            }
            }
        },
        {
            "Sid": "AllowScopedInstanceProfileTagActions",
            "Effect": "Allow",
            "Resource": "*",
            "Action": [
            "iam:TagInstanceProfile"
            ],
            "Condition": {
            "StringEquals": {
                "aws:ResourceTag/kubernetes.io/cluster/${CLUSTER_NAME}": "owned",
                "aws:ResourceTag/topology.kubernetes.io/region": "${AWS_REGION}",
                "aws:RequestTag/kubernetes.io/cluster/${CLUSTER_NAME}": "owned",
                "aws:RequestTag/topology.kubernetes.io/region": "${AWS_REGION}"
            },
            "StringLike": {
                "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass": "*",
                "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass": "*"
            }
            }
        },
        {
            "Sid": "AllowScopedInstanceProfileActions",
            "Effect": "Allow",
            "Resource": "*",
            "Action": [
            "iam:AddRoleToInstanceProfile",
            "iam:RemoveRoleFromInstanceProfile",
            "iam:DeleteInstanceProfile"
            ],
            "Condition": {
            "StringEquals": {
                "aws:ResourceTag/kubernetes.io/cluster/${CLUSTER_NAME}": "owned",
                "aws:ResourceTag/topology.kubernetes.io/region": "${AWS_REGION}"
            },
            "StringLike": {
                "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass": "*"
            }
            }
        },
        {
            "Sid": "AllowInstanceProfileReadActions",
            "Effect": "Allow",
            "Resource": "*",
            "Action": "iam:GetInstanceProfile"
        }
    ],
    "Version": "2012-10-17"
}
EOF
```

Now let's apply the policies to the previously created controller role:

```
aws iam put-role-policy --role-name "KarpenterControllerRole-${CLUSTER_NAME}" \
    --policy-name "KarpenterControllerPolicy-${CLUSTER_NAME}" \
    --policy-document file://controller-policy.json
```

This takes care of all the permission-related changes needed for Karpenter.

Next comes the process of tagging. When Karpenter starts to add nodes into your cluster, these nodes and nodegroups will have to obviously end up in a subnet. However, Karpenter has no way of knowing which subnets are to be used. This is why you need to tag the subnets you want Karpenter to use with:

Key=karpenter.sh/discovery
Value=${CLUSTER_NAME}

If you want Karpenter to use the same subnets that your existing nodegroups use, you can use the following loop:

```
for NODEGROUP in $(aws eks list-nodegroups --cluster-name "${CLUSTER_NAME}" --query 'nodegroups' --output text); do
  aws ec2 create-tags \
    --tags "Key=karpenter.sh/discovery,Value=${CLUSTER_NAME}" \
    --resources "$(aws eks describe-nodegroup --cluster-name "${CLUSTER_NAME}" \
    --nodegroup-name "${NODEGROUP}" --query 'nodegroup.subnets' --output text )"
done
```

This will automatically tag all the correct subnets. This same theory applies to security groups. Add the Key value pair to the tags in your cluster security group:

Key=karpenter.sh/discovery
Value=${CLUSTER_NAME}

A final thing left to do from the Kubernetes cluster side is to allow the Karpenter role you just created to access the cluster in the same way your default nodegroup role has access to it. Open up your aws-auth ConfigMap:

```
kubectl edit configmap aws-auth -n kube-system
```

You can copy your Nodegroup role entry and change the role name:

```
- groups:
 - system:bootstrappers
 - system:nodes
 rolearn: arn:aws:iam::<AWS_ACCOUNT_ID>:role/KarpenterNodeRole-${CLUSTER_NAME}
 username: system:node:{{EC2PrivateDNSName}}
```

Make sure you change `<AWS_ACCOUNT_ID>`.

This completes all the setup needed from the AWS side. So far we have:

- Created IAM roles and policies to allow Karpenter to work
- Created tags to show Karpenter which subnets and security groups it should work with

Next up is to set up Karpenter on your Kubernetes cluster.