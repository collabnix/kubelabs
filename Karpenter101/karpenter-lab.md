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

Next up is to set up Karpenter on your Kubernetes cluster. First, let's export the Karpenter version you want to set up. At the time of writing, the latest version is v0.36, so it would be:

```
export KARPENTER_VERSION="0.36.0"
```

Now, let's fetch the chart from `public.ecr.aws/karpenter/karpenter`. You can take a look at the values.yaml [here](https://github.com/aws/karpenter-provider-aws/blob/main/charts/karpenter/values.yaml) and customize it however you want it. In particular, you need to change the `settings.clusterName` and `serviceAccount.annotations`. Since there isn't much to change, we will be setting the values in the helm command itself instead of separately getting the yaml:

```
helm template karpenter oci://public.ecr.aws/karpenter/karpenter --version "${KARPENTER_VERSION}" --namespace "${KARPENTER_NAMESPACE}" \
    --set "settings.clusterName=${CLUSTER_NAME}" \
    --set "serviceAccount.annotations.eks\.amazonaws\.com/role-arn=arn:${AWS_PARTITION}:iam::${AWS_ACCOUNT_ID}:role/KarpenterControllerRole-${CLUSTER_NAME}" \
    --set controller.resources.requests.cpu=1 \
    --set controller.resources.requests.memory=1Gi \
    --set controller.resources.limits.cpu=1 \
    --set controller.resources.limits.memory=1Gi > karpenter.yaml
```

You will notice that we used `helm template` instead of `helm install`. This is because because we will be applying the Deployment.yaml as a kubectl apply after we have slightly modified it. The deployment yaml should have been created on your machine where you ran the above command. Open it and scroll down to the `nodeAffinity` section. Here, we will be setting the name of the nodegroup that you already have and telling Karpenter that it should only schedule its Karpenter pods inside this node group. This is necessary since Karpenter can't deploy its pods on nodes that it manages as the nodes are subject to deletion.

```
affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: karpenter.sh/nodepool
            operator: DoesNotExist
        - matchExpressions:
          - key: karpenter.sh/nodegroup
            operator: In
            values:
            - <your-ng-name>
```

With that out of the way, let's create the namespace where the Karpenter pods will live:

```
kubectl create namespace "${KARPENTER_NAMESPACE}" || true
```

Next, create the CRD's Karpenter will be using:

```
kubectl create -f \
    "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v${KARPENTER_VERSION}/pkg/apis/crds/karpenter.sh_nodepools.yaml"
kubectl create -f \
    "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v${KARPENTER_VERSION}/pkg/apis/crds/karpenter.k8s.aws_ec2nodeclasses.yaml"
kubectl create -f \
    "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v${KARPENTER_VERSION}/pkg/apis/crds/karpenter.sh_nodeclaims.yaml"
```

Before we go any further, let's take a look at the CRDs above. They are:

- NodePools
- NodeClasses
- NodeClaims

NodePools are basically a pool of nodes. You need to create at least 1 NodePool, or Karpenter won't work (since it doesn't know what instances to choose from). So let's start with that. As you might guess, the yaml needs to be kind `NodePool` which is a custom resource defined by the above CRD.

```
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  name: default
spec:
  template:
    spec:
      requirements:
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64"]
        - key: kubernetes.io/os
          operator: In
          values: ["linux"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["on-demand"]
        - key: karpenter.k8s.aws/instance-category
          operator: In
          values: ["c", "m", "r"]
        - key: karpenter.k8s.aws/instance-generation
          operator: Gt
          values: ["2"]
      nodeClassRef:
        apiVersion: karpenter.k8s.aws/v1beta1
        kind: EC2NodeClass
        name: default
  limits:
    cpu: 1000
  disruption:
    consolidationPolicy: WhenUnderutilized
    expireAfter: 720h # 30 * 24h = 720h
```

Let's break down what's happening in the above yaml. You first have the lines that are normal for Kubernetes deployments, with the name of the NodePool being defined as "default". You can change this to better suit the NodePool you want to set up. Afterward, come the requirements. This section details the filters that need to be applied for Karpenter to decide which instances to use. If you were to skip this section entirely, Karpenter would decide on what types of machines to spin up by looking at your workloads. But it's best to have some control over this. For example, the `kubernetes.io/arch` is used to determine the architecture of the machines that start up. Most applications will require a specific architecture to run on, so this section is generally included in any NodePool yaml as Karpenter can't figure that out by itself. The OS specification is the same, and unless your workloads are designed to run independently of the platform (which it usually isn't due to the way applications are started), it's best to specify this here.

We also have the capacity types (spot, on-demand), and the instance category (c, m, r). You could also have an instance family to specify which specific machines (t2, t3, etc...) to use, along with the instance generation to be used. One this to note is that Karpenter might underestimate your workload when setting it up initially, which will result in the lowest and most cost-efficient machine being started up. For example in the above case, Karpenter may decide that the c7a.medium machine, which costs less than other machines in the rest of the allowed categories, is best suited for the workload. However, when a load starts coming in and the memory usage increases, the machine is unable to handle this and it can go into a memory pressure state, thereby crashing your application. Therefore, before implementing Karpenter, it is best to use tools like Prometheus to first get an idea of the type of load your applications receive, and change the requirements of the NodePool so that the minimum requirements are met. For example, in the previous case, you could have this requirement added:

```
- key: karpenter.k8s.aws/instance-memory
 operator: Gt
 values: ["4047"]
```

This will ensure that the machines that start will have at least 4GB of memory and, thereby should be able to handle any initial load your application receives.

Next, the NodeClass this NodePool is going to use has been defined. This NodeClass will specify the AMIs of the EC2s that need to be used. We will be defining this next. We have specified that the name of the NodeClass will be called "default".

Next, we have defined `limits`. This limits the amount of a certain resource the NodePool will create. So in this case, if the number of instances in the NodePool that have been created has reached 1000 CPU units, the NodePool will not create any new nodes. Using these limits wisely will prevent many instances from spinning up unintentionally.

The final part of this yaml is the `disruption` block. Here, we have only used 2 options, which is to say that when the node is being underutilized, remove it, and after 30 days, replace a node (even if it is being used). This ensures that nodes are kept updated with the latest AMIs and thereby have all their security vulnerabilities patched. However, this block can be used to do so much more. Take a look at the [example](https://karpenter.sh/docs/concepts/nodepools/) provided on the Karpenter doc to see the various ways Karpenters' disruption can be changed.

Now that you have an idea of what the NodePool resource looks like and how it can be defined, let's take a look at the next resource: NodeClass. You already know what NodeClasses do, so look at how they have been defined:

```
apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata:
 name: default
spec:
 amiFamily: AL2 # Amazon Linux 2
 role: "KarpenterNodeRole-<cluster-name>" # replace with your cluster name
 subnetSelectorTerms:
  - tags:
    karpenter.sh/discovery: "<cluster-name>" # replace with your cluster name
 securityGroupSelectorTerms:
  - tags:
    karpenter.sh/discovery: "<cluster-name>" # replace with your cluster name
 amiSelectorTerms:
  - id: "ami-01af8560b504eb3db"
  - id: "ami-01520c51b1b0e680b"
```

The resource is of kind `EC2NodeClass` and we are calling it `default`. It is an Amazon Linux 2 machine that uses the IAM role that you defined previously and uses the tags you defined to decide where the node classes can be formed. You also have the security tags picked here so that it knows which security groups to select. The final part of the yaml is where the AMIs are defined. Feel free to change the above AMI to whatever is latest when you are doing the implementation.

Out of the 3 CRDs we deployed, the last remaining one is the NodeClaim. Unlike with the other two, there is no file that you need to create and deploy. This is because the NodeClaim is a resource that gets created automatically based on the NodePool & NodeClass. When you fully deploy Karpenter and remove cluster autoscaler, you will see the NodeClaims starting up. If you know about how Kubernetes volumes work, then you probably have heard of volume claims, where a certain amount of storage is claimed from a volume to supplement a pod. In the same way here, a NodeClaim claims an instance from the NodePool to run a pod. So in this case, since you have 1 NodePool, multiple nodes will be created from this NodePool after the NodeClaim claims them. We will see them in action later.

Now that we have all the deployment files defined, go ahead and apply them. At this point, Karpenter is officially up and running, and there is no longer any need to keep the cluster autoscaler around. So go ahead and delete that:

```
kubectl scale deploy/cluster-autoscaler -n kube-system --replicas=0
```

Now ensure that the Karpenter pods are running. They need at least 1 node from your nodegroup to be able to run. 

```
kubectl get pods -n kube-system
```

If at least 1 of the 2 Karpenter replicas are running, node scaling should have started. To check this out, run:

```
kubectl get nodeclaims
```

You should see something like this:

```
NAME                      TYPE         ZONE         NODE                          READY   AGE
nodepool-resource-p9g5h   c6a.xlarge   us-east-1b   ip-10-0-156-91.ec2.internal   True    2m20s
```

The type will change depending on the restrictions you placed in the NodePool.yml.