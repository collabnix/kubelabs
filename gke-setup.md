# How to setup GKE Cluster directly using Docker Desktop for Mac

Refer [this](https://collabnix.com/bootstrapping-kubernetes-cluster-using-docker-for-mac-18-03-0-ce-edition/) link

## Pre-requisite

- Install/Upgrade Docker for Mac 18.03 CE Edition

![My Image](https://raw.githubusercontent.com/collabnix/kubelabs/master/images/1.png)

- Install [google-cloud-sdk](https://cloud.google.com/sdk/docs/quickstart-macos)
- Enable Google Cloud Engine API


![My Image](https://raw.githubusercontent.com/collabnix/kubelabs/master/images/2.png)



- Authenticate Your Google Cloud using `gcloud auth`

## Step-1

### Installing Google Cloud SDK on your macOS

Make sure that Python 2.7 is installed on your system:

```
Ajeets-MacBook-Air:~ ajeetraina$ python -V
Python 2.7.10
```

Download the corresponding version of Google Cloud SDK. 
In this case the Mac OS version for 64-bits systems is downloaded. 

```
wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-195.0.0-darwin-x86_64.tar.gz
```

Untar the downloaded file, as follows:

```
tar xfz google-cloud-sdk-195.0.0-darwin-x86_64.tar.gz
```

and execute the following command to install Google Cloud SDK in your system:

```
./google-cloud-sdk/install.sh
```

## Initializing the SDK

```
gcloud init
```

In your browser, log in to your Google user account when prompted and click `Allow to grant permission to access Google Cloud Platform resources`.

## Enabling Kubernetes Engine API

## Authenticate Your Google Cloud

```
gcloud auth login
```

## Creating GKE Cluster

```
gcloud container clusters create k8s-lab1 --disk-size 10 --zone asia-east1-a --machine-type n1-standard-2 --num-nodes 3 --scopes compute-rw
```

## Viewing it on Docker for Mac UI

You should be able to view GKE cluster under Preference UI by now.

![My Image](https://raw.githubusercontent.com/collabnix/kubelabs/master/images/3.png)

*Be aware that your Kubernetes context can be named differently and it depends on the project's name under which the Kubernetes cluster is being deployed.*


## Install gke-gcloud-auth-plugin 

This is required for use with kubectl by following https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke

```
./google-cloud-sdk/bin/gcloud components install kubectl


Your current Google Cloud CLI version is: 432.0.0
Installing components from version: 432.0.0

┌──────────────────────────────────────────────┐
│     These components will be installed.      │
├────────────────────────┬─────────┬───────────┤
│          Name          │ Version │    Size   │
├────────────────────────┼─────────┼───────────┤
│ gke-gcloud-auth-plugin │   0.5.3 │   7.2 MiB │
│ kubectl                │  1.25.9 │ 107.5 MiB │
│ kubectl                │  1.25.9 │   < 1 MiB │
└────────────────────────┴─────────┴───────────┘

For the latest full release notes, please visit:
  https://cloud.google.com/sdk/release_notes

Do you want to continue (Y/n)?  Y

╔════════════════════════════════════════════════════════════╗
╠═ Creating update staging area                             ═╣
╠════════════════════════════════════════════════════════════╣
╠═ Installing: gke-gcloud-auth-plugin                       ═╣
╠════════════════════════════════════════════════════════════╣
╠═ Installing: gke-gcloud-auth-plugin                       ═╣
╠════════════════════════════════════════════════════════════╣
╠═ Installing: kubectl                                      ═╣
╚
```


## Put gcloud under PATH 

```
./google-cloud-sdk/bin/gcloud container clusters get-credentials k8s-lab1 --zone us-west4-b  --project arctic-robot-387304
export PATH=./google-cloud-sdk/bin:$PATH
```

## Listing the Nodes

```
kubectl get nodes
NAME                                      STATUS   ROLES    AGE   VERSION
gke-k8s-lab1-default-pool-35628f19-762j   Ready    <none>   47m   v1.25.8-gke.500
gke-k8s-lab1-default-pool-35628f19-83xz   Ready    <none>   47m   v1.25.8-gke.500
gke-k8s-lab1-default-pool-35628f19-w5xq   Ready    <none>   47m   v1.25.8-gke.500
```

You can connect to your cluster via command-line or using a dashboard.
**Remember** your project's name can be different.

```
gcloud container clusters get-credentials k8s-lab1 --zone asia-east1-a --project captain-199803
```

## Deploy Nginx on GKE Cluster

```
$ kubectl run nginx --image=nginx --replicas=3


deployment "nginx" created
```

## Verify that the pods are running

```
kubectl get pods -owide
NAME                    READY     STATUS    RESTARTS   AGE       IP          NODE
nginx-7c87f569d-glczj   1/1       Running   0          8s        10.12.2.6   gke-k8s-lab1-default-pool-b2aaa29b-w904
nginx-7c87f569d-pll76   1/1       Running   0          8s        10.12.0.8   gke-k8s-lab1-default-pool-b2aaa29b-2gzh
nginx-7c87f569d-sf8z9   1/1       Running   0          8s        10.12.1.8   gke-k8s-lab1-default-pool-b2aaa29b-qpc7
```

You can see that each `nginx` pod is now running in a different node (virtual machine).

## Expose the nginx cluster as an external service

```
$ kubectl expose deployment nginx --port=80 --target-port=80 \
--type=LoadBalancer

service "nginx" exposed
```

###  Find the network load balancer address:

```
kubectl get service nginx
NAME      TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
nginx     LoadBalancer   10.15.247.8   <pending>     80:30253/TCP   12s
```

It may take several minutes to see the value of `EXTERNAL_IP`. 
If you don’t see it the first time with the above command, retry every minute or so until the value of `EXTERNAL_IP` is displayed.

You can then visit `http://EXTERNAL_IP/` to see the server being served through network load balancing.

![My Image](https://raw.githubusercontent.com/collabnix/kubelabs/master/images/8.png)

GKE provides amazing platform to view `Workloads & Load-balancer` as shown below:

![My Image](https://raw.githubusercontent.com/collabnix/kubelabs/master/images/9.png)


GKE also provides UI for displaying `Loadbalancer`:

![My Image](https://raw.githubusercontent.com/collabnix/kubelabs/master/images/11.png)

## Cleaning Up

```
gcloud container clusters delete k8s-lab1 --zone asia-east1-a
```
[ Next >>](https://collabnix.github.io/kubelabs/weave.html)
