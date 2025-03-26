# Upgrading Karpenter

Keeping Karpenter up to date is pretty helpful since a whole bunch of new features gets added in with every major release. Additionally, Karpenter is the tool used to decide which machines your applications would run on, so any cost-efficiency improvements that get added in with every release would help reduce infrastructure expenses. Finally, if you are on a managed Kubernetes service such as AWS EKS, you are required to update the version of EKS to the latest supported version once every 3 months. Older versions of Karpenter can end up getting unsupported during such an upgrade, so it's best to keep the two in sync.

So to start, the first thing you should do is look at the [compatibilty matrix](https://karpenter.sh/v1.0/upgrading/compatibility/). Once you have confirmed that your cluster version and the new version of Karpenter are compatible, let's look at upgrading.

The Karpenter docs already provide detailed instructions on upgrading, including a full [upgrade guide](https://karpenter.sh/docs/upgrading/upgrade-guide/) for every version. Since the switch to version 1.0 has major breaking changes, there is an [additional guide](https://karpenter.sh/v1.0/upgrading/v1-migration/) for that. However, all these guides assume you have installed Karpenter and its CRDs with Helm. This might not be the case if instead of directly installing Karpenter, you first ran cluster autoscaler and then decided to follow the migration guide to switch to Karpenter.

We will be focusing on this scenario. In this case, let's say you had an old 0.3x version of Karpenter installed with Helm. This guide will cover the process of upgrading to the latest (v1.3.3 at the time of writing) version without getting any downtime. For starters, you need to define the correct variables:

```bash
export KARPENTER_NAMESPACE=kube-system
export KARPENTER_VERSION=0.37.0
export K8S_VERSION=1.30

export AWS_PARTITION="aws" # if you are not using standard partitions, you may need to configure to aws-cn / aws-us-gov
export CLUSTER_NAME=<cluster-name>
export AWS_REGION=us-east-1
export AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
export TEMPOUT=$(mktemp)
export ARM_AMI_ID="$(aws ssm get-parameter --name /aws/service/eks/optimized-ami/${K8S_VERSION}/amazon-linux-2-arm64/recommended/image_id --region us-east-1 --query Parameter.Value --output text)"
export AMD_AMI_ID="$(aws ssm get-parameter --name /aws/service/eks/optimized-ami/${K8S_VERSION}/amazon-linux-2/recommended/image_id --region us-east-1 --query Parameter.Value --output text)"
export GPU_AMI_ID="$(aws ssm get-parameter --name /aws/service/eks/optimized-ami/${K8S_VERSION}/amazon-linux-2-gpu/recommended/image_id --region us-east-1 --query Parameter.Value --output text)"

export CLUSTER_ENDPOINT="$(aws eks describe-cluster --name ${CLUSTER_NAME} --region us-east-1 --query "cluster.endpoint" --output text)"
export KARPENTER_IAM_ROLE_ARN="arn:${AWS_PARTITION}:iam::${AWS_ACCOUNT_ID}:role/KarpenterControllerRole-${CLUSTER_NAME}"
```

For the Karpenter version, get your current version with:

```bash
kubectl get deployment -A -l app.kubernetes.io/name=karpenter -ojsonpath="{.items[0].metadata.labels['app\.kubernetes\.io/version']}{'\n'}"
```

Then set that exact version. Also make sure to set the cluster name, region, and k8s version. Now that the variables are set, let's delete the old Karpenter before we can install the new one.