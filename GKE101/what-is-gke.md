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

First, you specify `gcloud`, which is used to interact with all GCP resources, followed by `container`, which tells that you are looking to manage containers and clusters. The `clusters` keyword specifies that you want to work with GKE clusters, and you then say that you want to `create` one. Next, you specify the machine type you want the nodes to have. `n1-standard-1` is a more mid-level machine in terms of performance, and it is a better option to use since Kubernetes clusters are somewhat demanding. Note that the price you pay will scale with the performance level of the VM. You then define the zone. Omitting this value will result in gcloud asking you for the zone when you try to run the command. Finally, you specify the name of your cluster.

Running the above command will require you to have an environment that has gcloud set up and authorized. The fasted way to do this is by running the cloud shell within GCP console. If you are already in the console, you should be able to spot the shell button in the title bar at the top right corner of the screen. Clicking on it will spin up a small Debian-based VM that has everything you need to start running commands on GCP.

When you run the above command on the cloud shell, it will ask you to authorize the shell to make changes to your GCP project. Accept the authorization and start running the command. Note that it will take a while (about 10 mins) for the cluster to be fully set up. GCP will also run readiness health checks to ensure that the cluster is functioning. By default, the cluster will be created with 3 nodes. If you want to change the number of nodes that get created, you can set the number of nodes when running the command. For example: `--nodes=2`.

Click on the navigation page on the left, and go into the Kubernetes section of GCP. This should show you the cluster that is up and running. Now it's time for us to interact with the cluster.

The cloud shell comes with `kubectl` installed, but if you are using a different client environment, you will need to set up kubectl yourself. However, despite having kubectl set up, you will not be able to interact with the cluster immediately. This is because the shell isn't configured with the correct kubeconfig that will allow it to access the cluster. For you to get the kubeconfig, run:

```
gcloud container clusters get-credentials collabnix-webserver1 --zone us-west3-c
```

This command will get the kubeconfig and place it in the proper place so you can start running commands on the cluster immediately. Note that you must specify the zone, or gcloud will throw an error. Try running:

```
kubectl get po -A
```

This should give you a list of all pods. From here onwards, you essentially have a fully functioning managed cluster that you can use as you please.

## Deploying to the cluster

So, as mentioned before, it's really simple getting a cluster up and running in GCP. One command to create the cluster, and one to get access to it. Now, let's deploy something to the cluster. As with all clusters, you can create a deployment yaml and use `kubectl apply -f <file>` to start the cluster. In this case, we will simply use the `kubectl create deployment` command to deploy a simple image by Google. This image will start a new web server within your GKE cluster.

```
kubectl create deployment hello-server --image=gcr.io/google-samples/hello-app:2.0
```

Next, let's create a simple service that will expose the deployment using a service of type `LoadBalancer`:

```
kubectl expose deployment hello-server --type=LoadBalancer --port 8080
```

This should expose the app on port 8080. Use:

```
kubectl get svc
```

to get the list of services, which should include an external IP. You can use this external IP on your web browser to open up the deployed application:

```
http://[EXTERNAL-IP]:8080
```

## Deleting the cluster

The next section of this lesson will go into how you can add service mesh support for GKE. If you are doing that lesson, you may skip deleting the cluster until you have completed the next part. 

Since you get charged per every hour your cluster is running (as well as the charges of the compute instances running your worker nodes), its best that you delete the cluster as the final stage of the lab. You can either delete your cluster via the cloud console or use this gcloud command:

```
gcloud container clusters delete collabnix-webserver1 
```

And that's it! Your cluster should be now deleted.

Now, let's move on to integrating a service mesh to your cluster.

[Next: GKE Service Mesh](gke-service-mesh.md)