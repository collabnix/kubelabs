## Setting up Mongo Express

Now that we have MongoDB set up, we need to get a UI to interface with MongoDB. For this, we will be using [Mongo Express](https://github.com/mongo-express/mongo-express). Mongo Express consists of 1 pod and 1 service, so using a Helm chart is not needed here. Simply create a deployment and service that use the mongo-express image, and gets exposed in port 8081. An example of this can be found [here](https://gitlab.com/nanuchi/youtube-tutorial-series/-/blob/master/linode-kubernetes-engine-demo/test-mongo-express.yaml). Make sure you replace the necessary variables with the values as described in the [mongo-express image page](https://hub.docker.com/_/mongo-express/). The service is an internal service, so you should deploy the resources. However, you will not be able to see the actual UI due to the fact that the service is internal. To expose it to the outside world, you need to introduce and Ingress. If you want a refresher on Ingress, be sure to check out [the Ingress101 section](./../Ingress101/README.md).

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