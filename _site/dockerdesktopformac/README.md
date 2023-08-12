
# Kubernetes Cluster on AWS using Kops running on Docker for Mac

Pre-requisites:

- Docker Desktop for Mac 
- Install AWS CLI using ```brew install aws```
- Create an AWS Account if you are first time user.
- Run the below command to install kops on your macOS:

```
brew update && brew install kops
```

## Adding Access & Secret Key 


```
aws configure
```

This will store your credential under ~/.aws/credentials


```
bucket_name=collabstore
```


## Create a AWS Bucket
```
[Captains-Bay]🚩 >  aws s3api create-bucket --bucket ${bucket_name} --region us-east-1
{
    "Location": "/collabstore"
}
```

## Configure

```
aws s3api put-bucket-versioning --bucket ${bucket_name} --versioning-configuration Status=Enabled
```


## Configure DNS Name

```
 aws route53 create-hosted-zone --name collabnix.com --caller-reference 2
```

```
export KOPS_CLUSTER_NAME=ajeet.k8s.local
```

## Export Cluster Name


```
export KOPS_CLUSTER_NAME=ajeet.k8s.local
```

## Exporting Kops State Store

```
[Captains-Bay]🚩 >  export KOPS_STATE_STORE=s3://${bucket_name}
```

```
ssh-keygen -t rsa
```

```
kops create secret --name ajeet.k8s.local sshpublickey admin -i ~/.ssh/id_rsa.pub
```


```
[Captains-Bay]🚩 >  kops create cluster \
> --node-count=2 \
> --node-size=t2.medium \
> --zones=us-east-1a \
> --name=${KOPS_CLUSTER_NAME}
```

Must specify --yes to apply changes

Cluster configuration has been created.

Suggestions:
 * list clusters with: kops get cluster
 * edit this cluster with: kops edit cluster k8.aws.dev.collabnix.com
 * edit your node instance group: kops edit ig --name=ajeet.k8s.local nodes
 * edit your master instance group: kops edit ig --name=ajeet.k8s.local master-us-east-1a

Finally configure your cluster with: kops update cluster ajeet.k8s.local --yes





```
[Captains-Bay]🚩 >  kops get cluster
NAME		CLOUD	ZONES
ajeet.k8s.local	aws	us-east-1a
[Captains-Bay]🚩 >
```


## Deploy Kubernetes

```
kops update cluster --name ${KOPS_CLUSTER_NAME} --yes
```


```
kops get cluster
NAME				CLOUD	ZONES
ajeet.k8s.local	aws	us-east-1a

```


```
[Captains-Bay]🚩 >  kops update cluster --name ${KOPS_CLUSTER_NAME} --yes
I0531 07:01:41.613598    1366 apply_cluster.go:456] Gossip DNS: skipping DNS validation
I0531 07:01:44.786395    1366 executor.go:91] Tasks: 0 done / 77 total; 30 can run
I0531 07:01:46.893202    1366 executor.go:91] Tasks: 30 done / 77 total; 24 can run
I0531 07:01:49.007022    1366 executor.go:91] Tasks: 54 done / 77 total; 19 can run
I0531 07:01:51.649219    1366 executor.go:91] Tasks: 73 done / 77 total; 3 can run
I0531 07:01:53.079596    1366 executor.go:91] Tasks: 76 done / 77 total; 1 can run
I0531 07:01:53.440746    1366 executor.go:91] Tasks: 77 done / 77 total; 0 can run
I0531 07:01:54.102339    1366 update_cluster.go:291] Exporting kubecfg for cluster
kops has set your kubectl context to ajeet.k8s.local

Cluster changes have been applied to the cloud.


Changes may require instances to restart: kops rolling-update cluster

[Captains-Bay]🚩 >
```


Now you can see K8s cluster under Context UI.

![My image](https://raw.githubusercontent.com/collabnix/kubelabs/master/dockerdesktopformac/context-aws.png)

```
Suggestions:
 * validate cluster: kops validate cluster
 * list nodes: kubectl get nodes --show-labels
 * ssh to the master: ssh -i ~/.ssh/id_rsa admin@api.ajeet.k8s.local
 * the admin user is specific to Debian. If not using Debian please use the appropriate user based on your OS.
 * read about installing addons at: https://github.com/kubernetes/kops/blob/master/docs/operations/addons.md.
```

```
[Captains-Bay]🚩 >  kubectl get nodes
NAME                            STATUS   ROLES    AGE    VERSION
ip-172-20-40-58.ec2.internal    Ready    node     107s   v1.17.6
ip-172-20-41-233.ec2.internal   Ready    node     103s   v1.17.6
ip-172-20-43-50.ec2.internal    Ready    master   3m7s   v1.17.6
ip-172-20-52-114.ec2.internal   Ready    node     104s   v1.17.6
[Captains-Bay]🚩 >
```

```
kops get instancegroups
NAME			ROLE	MACHINETYPE	MIN	MAX	ZONES
master-us-east-1a	Master	t3.medium	1	1	us-east-1a
nodes			Node	t2.medium	3	3	us-east-1a
```

![My Image](https://github.com/collabnix/kubelabs/blob/master/dockerdesktopformac/Screen%20Shot%202020-06-07%20at%2010.39.20%20AM.png)


```
kops delete cluster --state=s3://kubernetes-aws-io --yes
```




[Next >>](https://collabnix.github.io/kubelabs/kubectl-for-docker.html)
