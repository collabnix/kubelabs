# Linode Kubernetes Engine

Linode is a fully featured cloud service provider, and LKE is its Kubernetes engine (similar to AKS or GKE). As with other Kubernetes engines, the aim of LKE is to abstract away the master nodes so that you only have to worry about your Kubernetes worker nodes. There are a lot of things that need to be considered when setting up Kubernetes, especially for large organizations that handle sensitive data. Security, privacy, and robustness are needed to ensure that your customers don't have their information compromised, as well as ensure that they don't face any downtime. Setting up and maintaining such systems can get complicated, which is why LKE does that job for you. In addition to completely handling your master node, LKE also gives you the luxury of taking and setting up your own worker nodes from within the Linode stack. This means that you can maintain your entire architecture within the Linode cloud.

This means that features such as guaranteed uptime and security will also extend to your worker nodes, and thereby the entire Kubernetes stack. Maintaining your own server is a costly business since you need to fix any issues that come up with them, as well as invest heavily in the actual machines, whose processing power is something you may not even fully end up using. Cloud services, on the other hand, manage the servers for you, and allow you to only pay for the resources that you use. Linode is no exception, so let's dive in!

## Setting up

To get started, you need to create an account with Linode, which comes with $50 of credit. You also need kubectl which you will be using to run the various Kubernetes commands. If you have installed Minikube or an equivalent in the past, you likely already have kubectl. If not, you can [follow the official guide](https://kubernetes.io/docs/tasks/tools/#install-kubectl-on-windows) to get the latest version of kubectl installed. This is all you have to do to get up and running with Linode.

## Creating a cluster

To create a cluster, you can use the [cloud manager](https://cloud.linode.com/) which gives you an intuitive interface that you can use to create resources. Simply click on the dropdown in the right-hand corner and select "Create a Kubernetes cluster". Once you do that, there is a handful of information you need to fill in, such as the name, region, and version. Once you do this, your fully managed Linode cluster is up and running. The second step is to create a bunch of worker nodes. The master node, which will be managed by Linode, will communicate with these worker nodes to run your application. This page is self-explanatory, and you can choose between their 2GB plan, the way to their 192GB plan which comes with 192GB of RAM, 32 CPUs, and 3TB of storage. All that will only cost you $1.44 an hour. This is something you will also see across other competing cloud platforms, and this cost-effective computing power is why many large organizations have moved to cloud-based systems.

After you set the nodes that you want to use, you can still edit your configuration later to add or remove worker nodes. All the information relating to your nodes is available at a single glance on the right-hand side of the cloud manager. Now that your cluster is active, it's time to start using it. As with all Kubernetes clusters, you need to use the kubeconfig file to access the cluster, and the config file for your LKE cluster can be found in the Kubernetes section of the cloud manager. Your clusters should be listed there, and you can download the kubeconfig from here. Place your kubeconfig in its prescribed place, or use terminal commands to set the kubeconfig:

```
export KUBECONFIG=path/to/kubeconfig.yaml
```

Now you should be able to run kubectl commands on your terminal and access your cluster. If the cluster access works fine, then you have successfully set up your cluster.

## Cluster autoscaling

One major advantage of using Kubernetes on the cloud as opposed to hosting your cluster on an on-premise server is the autoscaling abilities that come with it. Unlike an on-premise server that has a fixed set of resources that cannot change unless you scale vertically by adding more servers, LKE can dynamically add and remove nodes to meet demand. This way, you don't have unused nodes that idle, thereby costing you money, and you don't have to worry about seeing a sudden surge in traffic that you can't account for. You need to start by heading over to the [cluster details page](https://www.linode.com/docs/kubernetes/deploy-and-manage-a-cluster-with-linode-kubernetes-engine-a-tutorial/#access-your-clusters-details-page) and using the Autoscale Pool option. You then need to set the minimum and the maximum number of nodes, so that the autoscaler knows how much it needs to scale your system to meet demand. However, note that LKE will not forcibly scale down or up to meet the maximum or the minimum number of set nodes. This is because doing so could lead to possible disruptions to your system if, for example, 5 nodes suddenly had to handle the work of 10.

## High availability

If you are running, for instance, an e-commerce site, then it is vital that the service does not go down. This is because your website going down directly relates to lost profits. For these kinds of situations, most cloud Kubernetes providers, including Linode, have introduced high availability clusters. These clusters guarantee a close-to-100-per cent up time and have no single points of failure, which means that one thing going wrong won't end up with your whole cluster failing. The clusters also have duplicates, meaning that even if the cluster was to go down, another would quickly step in to take its place and the loss of profits would be minimal. A full description of how Linode manages to keep its highly available clusters highly available can be found [here](https://www.linode.com/docs/guides/introduction-to-high-availability/).

High availability clusters are separate from the normal clusters you create, and it is possible to switch from a normal cluster to a high availability cluster. However, since the two cluster types are mutually exclusive, this would involved stopping and deleting you existing nodes before starting new ones in the HA cluster. You also cannot downgrade from a high availability cluster to a normal cluster. To get into more technical terms, a high availability cluster will increase the replicas of the control plane components, and all these components will always be placed in different physical infrastructure. This means that you can be guaranteed 99.99% uptime, as the replicas can take over if the current control plane/worker nodes were to stop working.

To actiavate a high availability cluster, you only need to check the "Enable HA control plane" option when creating a cluster as usual. Note that enabling this option will immediately increase cluster costs greatly. To upgrade an already existing cluster to a HA cluster, go to the cluster instance in cloud manager, and click on the "upgrade to HA option".

## Lab

Now that you have created you cluster, and know the full extent of LKE's HA cluster abilities, it's time to start creating a cluster yourself. Use the above instructions to set up your account as well as your cluster. Make sure you don't create a high availability cluster to prevent your free credit from drying up. Load up the kubeconfig file so that your are ready to go. We will try out the features of LKE by deploying a MongoDB database. For this, we will be using Helm. If you needs a refresher on Helm, be sure to check out the [Helm101 section](../Helm101/what-is-helm.md). MongoDb has a fair bit different parts that go into creating it. Since this is a database that needs to maintain it's state, MongoDb comes in the form of a StatefulSet. If you need to catch up on StatefulSets, the [StatefulSet101 section](../StatefulSets101/README.md) is where you need to be. In addition to the stateful set config file, you will also need several Service resources that you need to manually install, as well as other configurations. However, using Helm, you can avoid having to do any of this. The Helm chart for MongoDB has all this bundled into one neat package that you can install very easily, and that is the option we will be going for. With the kubeconfig set, install Helm (see Helm section for more), and add the Helm repository:

```
$ helm repo add bitnami https://charts.bitnami.com/bitnami
```

Now, let's explore the Mongo Helm chart a bit. A detailed explanation of the chart, how it can be installed, its architecture, and the parameters you can use can be found in the official [git repo](https://github.com/bitnami/charts/tree/master/bitnami/mongodb). Most importantly, take a look at the [parameters section](https://github.com/bitnami/charts/tree/master/bitnami/mongodb#mongodb-parameters) which will hold a list of parameters within the Helm chart that you can change. Consider setting the ```rootPassword``` parameter to something that you can use to prevent the root password from being set to a random value. To look at the charts within the repo you just installed, use:

```
helm search repo bitnami/mongo
```

The setup would be good enough if you were in a development environment where you would be running everything on-premise. But since we are going to be using LKE, we need to change the StorageClass so that it uses Linode's cloud storage. We do this by changing the ```architecture``` parameter. Additionally, we need to have multiple replicas of the database for fault tolerance. Since MongoDB here is a stateful set, we should change the [parameters respective](https://github.com/bitnami/charts/tree/master/bitnami/mongodb#mongodb-statefulset-parameters) to the stateful set. To do this, we need to override the default Helm set up using a ```values.yaml```. Create a YAML file and set the architecture as a replica set. Set a replica count (such as 3), point the storage class to Linode block storage, and set the root password to values of your preference. An example of how all this can be set can be found [here](https://gitlab.com/nanuchi/youtube-tutorial-series/-/blob/master/linode-kubernetes-engine-demo/test-mongodb-values.yaml).

Once you have the yaml file ready, go ahead and install the helm chart:

```
helm install mongodb --values test-mongodb-values.yaml bitnami/mongodb
```

This command installs MongoDB with the custom chart values overriding the default values provided. Running this should install the MongoDB pods and other resources needed to get the database up and running on your Linode cluster. You can use ```kubectl get pod``` to see the status of the pods as they get created and start-up. Since we set the replica count to 3, you should be able to see three pods startup. You should also be able to see that several services, as well as statefulsets, have come up using:

```
kubectl get all
``` 

The root password you specified will also be included in a secret, which you can see with:

```
kubectl get secret
```

Great! Now you have MongoDB setup, and that took barely any configuration. You can now head over to the LKE cloud manager and into the [volumes page](https://cloud.linode.com/volumes) to see that three new pvc's have shown up. If you look at the File System Path column, you should be able to see that these are in fact linked to three physical disks. This means that your 3 replicas of pods had three pvc's created, all of which are linked to three separate disks. If one of your pods were to go down, the other two disks would still be running, thereby giving your application fault tolerance.

Now that we have MongoDB set up, we need to get a UI to interface with the database. For this, we will be using [Mongo Express](https://github.com/mongo-express/mongo-express). 

## Setting up Mongo Express

Mongo Express consists of 1 pod and 1 service, so using a Helm chart is not needed here. Simply create a deployment and service that use the mongo-express image, and gets exposed in port 8081. An example of this can be found [here](https://gitlab.com/nanuchi/youtube-tutorial-series/-/blob/master/linode-kubernetes-engine-demo/test-mongo-express.yaml). Make sure you replace the necessary variables with the values as described in the [mongo-express image page](https://hub.docker.com/_/mongo-express/). The service is an internal service, so you should deploy the resources. However, you will not be able to see the actual UI due to the fact that the service is internal. To expose it to the outside world, you need to introduce and Ingress. If you want a refresher on Ingress, be sure to check out [the Ingress101 section](./../Ingress101/README.md).

## Setting up Ingress

Similar to MongoDB, ingress has a lot of different parts, and requires you to either install all of them manually or use a Helm chart to install everything at once. We will be using Helm here, so we need to start off by adding the Ingress repo: 

```
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm install nginx-ingress:stable/nginx-ingress --set controller.publishService.enabled=true
kubectl get pods
```

Check if the ingress pod is working. There should be two pods running, one for the default backend and one for the ingress controller. You should also see a service has been created (```kubectl get svc```), where you will see a bunch of services of type ClusterIP, and one service of type LoadBalancer. As you may well know, ClusterIP is not externally accessible, so the LoadBalancer is what will act as the entry point into your cluster. Therefore, this LoadBalancer has an external IP that you can find next to the port type. If you were to head to the [NodeBalancer section](https://cloud.linode.com/nodebalancers) of cloudmanager, you should see a NodeBalancer active. If you look at the IP of this NodeBalancer, you will see that it matches the IP of the ingress. This means that the node balancer acts as the entry point to your cluster, and therefore, you can do all sorts of monitoring from here. In fact, if you were to click on this NodeBalancer, you should be able to see various graphs depicting metrics about the connections that were maintained on that Ingress. You will also notice the ports that are listed, which correspond to the ports that should be used to access your system.

Now you need to create an ingress rule, which defines what hosts and ports have access to your LKE cluster. You can get the host you should use from within the NodeBalancer page, under "Host Name". And Ingress rule is a resource similar to other Kubernetes resources, which you can create as normal. You can use [this resource file](https://gitlab.com/nanuchi/youtube-tutorial-series/-/blob/master/linode-kubernetes-engine-demo/test-ingress.yaml) for reference. Make sure to replace the host with your LKE host, the service name with the name of the service we created in the previous step, and the port with the corresponding port number. Apply the file to your cluster:

```
kubectl apply -f test-ingress.yaml
```

You should now be able to go to your hostname (taken from your LKE cluster), and it should redirect you to the Mongo express landing page. The NodeBalancer, which is now properly configured with an ingress rule, would now resolve it and forward the request to the internal service that is used by Mongo Express.

## Finishing up

Now, you need to attach the pods to the existing volumes. For this, stop the pods and reattach them by scaling down the number of replicas to zero, then setting them back to 3:

```
kubectl scale --replicas=3 statefulset/mongodb
```

You can then go to the [volumes page](https://cloud.linode.com/volumes) of cloud manager and see the volumes getting reattached to the pods.

And that's it! You now have a fully working cluster that supports MongoDB + MongoExpress running on LKE. You can extend this to support other frontend/backend services to build your entire application on the cloud.

## Removing resources

Once you are done with this tutorial, you can go ahead and start removing the resources you have deployed. Removing MongoDB is simply a matter of uninstalling the Helm chart:

```
helm uninstall mongodb
```

This will stop and remove all resources related to MongoDB in one go. The volumes would get detached since those pods no longer exist, but will not be removed. Since the volumes have data in them, automatically deleting them might become a problem since you can lose your data by accident. However, if you really no longer need these volumes around, go ahead and delete them manually from cloud manager.