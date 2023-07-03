## Kubesphere lab

### Requirements
First off, you need a Kubernetes cluster. Kubesphere supports deploying on a Linux VM (as well as their own managed Kubesphere cloud), but we will be doing this lab by deploying on a Kubernetes cluster. Since Kubesphere has so many features you will need a fair bit of resources. As such, it is best if the cluster has 4GB memory and at least 3 cores. [Minikube](https://minikube.sigs.k8s.io/docs/start/) is a great way to get a single-node cluster up and running on your local machine. As of the time of writing, minikube supports Kubernetes version 1.26 by default, which is only partially supported by Kubesphere. You may use the latest version if you don't intend to use feature such as setting up multiple host-member cluster, or using KubeEdge. Otherwise, when running minikube, use this command:

```
minikube start --kubernetes-version=v1.23.17 --cpus 3 --memory 4g
```

This sets the latest supported version of Kubernetes for Kubesphere while also setting the required memory and CPU for the cluster.

### Deployment

Now that you have a cluster, let's install Kubesphere. This is a fairly straightforward process. Simply open up your terminal and paste in these kubectl commands:

```
kubectl apply -f https://github.com/kubesphere/ks-installer/releases/download/v3.3.2/kubesphere-installer.yaml

kubectl apply -f https://github.com/kubesphere/ks-installer/releases/download/v3.3.2/cluster-configuration.yaml
```

Now, the installation will begin. After a minute or so, use this command to view the progress:

```
kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l 'app in (ks-install, ks-installer)' -o jsonpath='{.items[0].metadata.name}') -f
```

You will see the installation happening. Note that installation will take a while (around 20 minutes) depending on the speed of your machine and cluster. In the end, you should see a message giving you the login details and providing the URL you can use.

Depending on the cluster you are using, the URL may or may not work. Run:

```
kubectl get svc -n kubesphere-system
```

To get the list of services. The service you should look for is `ks-console`. If you cannot connect to the KubeSphere dashboard from the provided URL, use port forwarding:

```
kubectl port-forward ks-console-xxxx 80:30880 
```

You should now be able to access the dashboard via `127.0.0.1:30880`.

### The Dashboard

Now that we have access to the dashboard, let's take a look around. The dashboard itself takes some getting used to, as everything may not be clear from the outset. To start, let's take a closer look at the different concepts of KubeSphere.

First off, you have clusters, which correspond to the clusters you have with Kubernetes. These clusters contain workspaces, which are described as "isolated logical unit used to organize projects". Projects in this case refer to namespaces. Each project would have everything a namespace typically has, from pods to deployments to PVCs. You can click into any of these items and access the individual Kubernetes resources. Since you are an admin, you also can create new resources from within KubeSphere itself using the interactive wizards that are provided. You also can look at logs, ssh into different pods, all from within the interface being used here.

You now have control over your entire cluster without leaving the dashboard at all. However, you could also push configurations using kubectl from your local machine. We will get into this later. For now, let's move on to the case of access control.

### Access control

The golden rule of access control is that the amount of authorization given to any user should be the minimum amount required to fulfill their role. So it wouldn't make a lot of sense to hand over admin rights to a QA tester who is only interested in seeing the logs of a pod. Kubernetes has [RBAC](../RBAC101/README.md) to handle these situations, and KubeSphere seamlessly integrates with this to provide fine-grained access control. You can specify the level of access each user has for each level, from each cluster to namespace.

Click on the platform icon in the top left corner, and select access control. This will show you a list of workspaces. On the left pane, you will see the options "Users" and "Platform Roles". These two will allow you to define access across the entire cluster. If you were to head to the "Platform Roles", you would see a set of predefined roles with varying levels of access that can be assigned to users. If you can't find a fine-tuned role that matches the user you want to create, you can create one yourself using the interactive wizard. Creating users is also a breeze with the users' tab which allows you to create a user and set the role that the user needs to have.

Since you are setting the users and roles at a platform level, the users created will have access across the entire platform. However, if you need to drill down to a deeper level, you can head into your workspace and either set roles at a workspace level or go down into each workspace and set roles for each project (namespace).

### Add-ons

Now that we've covered the dashboard and access control, let's take a look at another powerful feature KubeSphere provides: add-ons. With an ordinary Kubernetes cluster, you would have to manually set up each different config that you want. However, with KubeSphere, you can get everything up and running with a few lines in YAML. Let's first start by taking a look at this YAML. It is already present in your KubeSphere instance, and you can access it by going to the dashboard > CRDs and searching for "Config". Open up the config that shows up.

A better view of the config can be found [here](https://github.com/kubesphere/ks-installer/blob/master/deploy/cluster-configuration.yaml).