# Upgrading Karpenter

Keeping Karpenter up to date is pretty helpful since a whole bunch of new features gets added in with every major release. Additionally, Karpenter is the tool used to decide which machines your applications would run on, so any cost-efficiency improvements that get added in with every release would help reduce infrastructure expenses. Finally, if you are on a managed Kubernetes service such as AWS EKS, you are required to update the version of EKS to the latest supported version once every 3 months. Older versions of Karpenter can end up getting unsupported during such an upgrade, so it's best to keep the two in sync.

So to start, the first thing you should do is look at the [compatibilty matrix](https://karpenter.sh/v1.0/upgrading/compatibility/). Once you have confirmed that your cluster version and the new version of Karpenter are compatible, let's look at upgrading.

The Karpenter docs already provide detailed instructions on upgrading, including a full [upgrade guide](https://karpenter.sh/docs/upgrading/upgrade-guide/) for every version. Since the switch to version 1.0 has major breaking changes, there is an [additional guide](https://karpenter.sh/v1.0/upgrading/v1-migration/) for that. However, all these guides assume you have installed Karpenter and its CRDs with Helm. This might not be the case if instead of directly installing Karpenter, you first ran cluster autoscaler and then decided to follow the migration guide to switch to Karpenter.

We will be focusing on this scenario. In this case, let's say you had an old 0.3x version of Karpenter installed with Helm. This guide will cover the process of upgrading to the latest version (v1.3.3 at the time of writing) without getting any downtime. The process will be as follows:

- Remove the current Karpenter version not installed by Helm
- Install the same Karpenter version but with Helm this time
- Upgrade to the latest minor version with Helm
- Upgrade to v1.0
- Switch resources to be compatible with the latest supported Karpenter version
- Upgrade to v1.3

For starters, you need to define the correct variables:

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

Then set that exact version. Also make sure to set the cluster name, region, and k8s version. Now that the variables are set, let's delete the old Karpenter before installing the new one. Since the only other way to install Karpenter is by generating the `Karpenter.yaml`, you need to simply run the delete command:

```bash
kubectl delete -f karpenter.yaml
```

This will delete most resources related to Karpenter, but won't result in your running node pools and node classes being deleted. This is because the CRDs used for these custom resources are installed separately, and not as part of the `karpenter.yaml`. These CRDs should **never be deleted** and only updated, since their removal also means the removal of your nodes and thereby downtime. However, it is fine (and required) to update them.

Since Karpenter is gone, the first step is done and we need to quickly re-install it since node scaling won't be happening during this period. As the variables are already defined:

```bash
# Logout of helm registry to perform an unauthenticated pull against the public ECR
helm registry logout public.ecr.aws

helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter --version "${KARPENTER_VERSION}" --namespace "${KARPENTER_NAMESPACE}" --create-namespace \
  --set "serviceAccount.annotations.eks\.amazonaws\.com/role-arn=${KARPENTER_IAM_ROLE_ARN}" \
  --set "settings.clusterName=${CLUSTER_NAME}" \
  --set controller.resources.requests.cpu=1 \
  --set controller.resources.requests.memory=1Gi \
  --set controller.resources.limits.cpu=1 \
  --set controller.resources.limits.memory=1Gi \
  --set webhook.enabled=true \
  --set webhook.port=8443 \
  --wait
```

Re-check the Karpenter version now:

```bash
kubectl get deployment -A -l app.kubernetes.io/name=karpenter -ojsonpath="{.items[0].metadata.labels['app\.kubernetes\.io/version']}{'\n'}"
```

Also, check the Karpenter pods and ensure that they are working as expected. If you are on a production cluster, you can run a test app on a separate node pool to double-verify that node scaling is active.

Now that we've switched to Helm, we can move on to the next steps. We start by moving to the latest minor version of the current Karpenter version. If you are using 0.37.0, the latest minor version would be 0.37.7:

```bash
export KARPENTER_VERSION="0.37.7" # Replace with your minor version

# Service account annotation can be dropped when using pod identity
helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter --version ${KARPENTER_VERSION} --namespace "${KARPENTER_NAMESPACE}" --create-namespace \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=${KARPENTER_IAM_ROLE_ARN} \
  --set settings.clusterName=${CLUSTER_NAME} \
  --set controller.resources.requests.cpu=1 \
  --set controller.resources.requests.memory=1Gi \
  --set controller.resources.limits.cpu=1 \
  --set controller.resources.limits.memory=1Gi \
  --set webhook.enabled=true \
  --set webhook.port=8443 \
  --wait
  ```

If you look at the official doc, you would see that you need to also update the CRDs with Helm. If you had installed Karpenter with Helm in the first place this would be correct, but since you didn't, you can't use Helm. One option would be to delete the resources and re-create them but that would result in downtime. So instead, simply update them with `kubectl`:

```bash
kubectl apply -f \
    "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v${KARPENTER_VERSION}/pkg/apis/crds/karpenter.sh_nodepools.yaml"
kubectl apply -f \
    "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v${KARPENTER_VERSION}/pkg/apis/crds/karpenter.k8s.aws_ec2nodeclasses.yaml"
kubectl apply -f \
    "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v${KARPENTER_VERSION}/pkg/apis/crds/karpenter.sh_nodeclaims.yaml"
```