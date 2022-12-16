# Google Kubernetes Engine

Google cloud is another managed cloud service which allows you to do all sorts of things without having to worry about managing the infrastructure. As will all other cloud platforms, it also comes with its own Kubernetes engine, which will be the focus of this section.

To start, you will need a [Google cloud account](https://cloud.google.com/free). You will get $300 free credit if you are signing up for the first time, which should be more than enough for us to cover this lesson. Once you finish setting up your account, head over to the [cloud console](https://console.cloud.google.com). Now is a good time to become a little familiar with the core GCP concepts. First of all, if you have any experience with other cloud providers, GCP is more or less the same. It has a compute section that allows you to set up compute instances, API section which allows you to manage APIs, IAM section that allows you to manage users and authentication, and a Kubernetes section where we will be creating clusters.

In the top right corner, you can see the option to start up a cloud shell. As with all the other cloud providers, Google allows you to do everything programatically (as opposed to doing them in the portal). The cloud shell has `gcloud` pre-installed, and provides a small VM you can use to run commands on your project.

## GKE Autopilot

Before we start creating clusters, we will first take a look at how GKE handles them. The control plane is the first node that you need in a Kubernetes cluster. This node will contain etcd, kube scheduler, kube proxy, and the controller manager, which are all used to control the worker nodes. Similar to other cloud providers, the control plane will be managed by GKE. However, unlike other cloud providers (such as AKS and LKE), the control plane node is not free. The entire managed cluster is called an "autopilot cluster", meaning that everything from your cluster configuration to scaling, security, and workloads are all handled by GKE.

A flat fee of $0.10/hour is charged for each cluster and is the same price regardless of how big your cluster becomes. This amount is covered by the free credit that you get when you create a new account.

In GCP, the VMs you can create are known as compute instances. They come in different sizes and capacities, just like the VMs of every other cloud provider. When you create worker nodes for your Kubernetes cluster, it is these VMs that get created. The entire cluster including these worker nodes is considered an "autopilot cluster".

## Regions

The next thing you need to consider is the region of your VPC. All resources need to have a region specified for them, which will determine where the resource is created. An example of a region would be something like `us-central1`. Regions are further broken down into zones which allow you to select which zone within the region you can create the resource. An example of a zone would be something like `us-central1-a`, or `us-central1-b`. Each zone has a specific quota, so if you find yourself running into an error along the lines of:

>Insufficient regional quota to satisfy request...

That means you should consider switching to a different zone (or possibly a different region). With most resources, you will need to specify which region/zone you want to create your resource. If you don't, gcloud will ask you if you want the resource to start up in the default region, which will be the region closest to you.

## Cluster creation

We've gone through a lot of theory so far, and you might be thinking that there is much to consider before you can create your cluster. However, that is not true, and you can actually create a whole cluster (including the control plane and worker nodes) with just 1 command, which is outlined below:

```
gcloud container clusters create --machine-type=n1-standard-1 --zone=us-west3-c collabnix-webserver1
```

This short command contains everything we spoke about above. Since this command can create a whole cluster, let's take a closer look at the command itself.