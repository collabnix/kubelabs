# KEDA Lab

## Requirements

To start, you need to have a Kubernetes cluster. [Minikube](https://minikube.sigs.k8s.io/docs/start/) is a quick and easy way to get set up with a single node cluster.

Once you have a cluster up and running, you need to deploy an application to it. This application will then be scaled with KEDA depending on a specific metric. KEDA already provides several sample applications that cover a large number of data sources in their [GitHub repo](https://github.com/kedacore/samples), and we will be using one of these samples in this lab.

In this case, we will be using the [MySQL scaler](https://keda.sh/docs/2.10/scalers/mysql/) and following the sample [here](https://github.com/turbaszek/keda-example). Start by cloning the repo:

```
git clone https://github.com/turbaszek/keda-example.git
```

Since the web application and API are both avialble in the repo and will be hosted locally, you need to first run:

```
docker build
```

which will create a Golang application.

You now have all the configuration files required to do the deployment. The `Deployment` folder you find inside the repo are all the files you need to deploy. Go ahead and deploy all the resources to the cluster:

```
kubectl apply -f deployment/
```

While the deployment takes place, let's take a look at what we are deploying. First, you will notice that there are two deployments: MySQL and Redis. The [mysql deployment](https://github.com/turbaszek/keda-example/blob/master/deployment/mysql-deployment.yaml) is straightforward. A Service, a PersistentVolumeClaim, and a Deployment. The service opens up a simple port (3306). The PersistentVolumeClaim is a necessary part of any database system since pods are ephemeral. When the pod goes down, any data that it held would disappear, which would be a pretty terrible design for a database that is designed to hold data forever. Therefore, a permanent volume is used to hold data. Finally, you have the deployment, which holds the main part of the resource. This deployment is a simple MySQL image running with 1 replica on port 3306 with the admin password "keda-talk".

If you look at the [redis deployment](https://github.com/turbaszek/keda-example/blob/master/deployment/redis-deployment.yaml), it's basically the same thing, running on the port with 6379. We will be scaling based on MySQL, so there is no need to look deeply into the redis deployment. You can avoid deploying it altogether if you prefer.

You also have a [service account resource](https://github.com/turbaszek/keda-example/blob/master/deployment/make-user.yaml) which creates a cluster role that is an admin. This is the unrestricted role that will be used across the cluster.

Next, you have the app and API deployments, which constitute the web application that will be connecting to the Redis and MySQL applications. The [API deployment](https://github.com/turbaszek/keda-example/blob/master/deployment/api-deployment.yaml) creates a service with port 3232 that runs with a load balancer. The image that will be used is the image that you previously built with `docker build`. The [App deployment](https://github.com/turbaszek/keda-example/blob/master/deployment/app-deployment.yaml) is the same thing, except it handles the application and not the API.

You probably can see where KEDA is going to fit in now. You have the API and the application, as well as the database. When the number of requests that come into the database increase, the number of pods for the API and application will also increment to handle the extra traffic. In the same way, when the number of requests decreases, the number of pods will go down to save costs.

Now that the cluster and the application are ready, install KEDA. It is recommended you use Helm for this, as Helm will largely take care of the setup for you.

Add the repo:

```
helm repo add kedacore https://kedacore.github.io/charts
```

Update it:

```
helm repo update
```

Then install KEDA in the correct namespace:

```
kubectl create namespace keda
helm install keda kedacore/keda --namespace keda
```

You can then see that the KEDA resources have been set up in the keda namespace:

```
kubectl get po -n keda
```

Before you start scaling anything, look at the initial state of the pods. Open up a new terminal instance and use:

```
kubectl get po --watch
```

Make sure you set the namespace with `-n` if you deployed the API in a specific namespace. You now have an auto-updating view of the pods and their replicas.

Now, deploy the `mysql-hpa.yaml` found in the keda folder:

```
kubectl apply -f keda/mysql-hpa.yaml
```

This is where the dummy deployment we saw earlier comes into place. The dummy pod will now be scaled up and down by KEDA depending on the MySQL row count. Insert some items into the MySQL database:

```
kubectl exec $(kubectl get pods | grep "server" | cut -f 1 -d " ") -- keda-talk mysql insert
```

If you look at the watch window that you opened up earlier, you should see additional replicas of the pods getting created.

Now let's look at scaling down. Delete items from the MySQL pod:

```
kubectl exec $(kubectl get pods | grep "server" | cut -f 1 -d " ") -- keda-talk mysql delete
```

Go back to the watch window, and you should see the number of pods decreasing.

## Conclusion

This wraps up the lesson on KEDA. What we tried out was a simple demonstration of a MySQL scaler, but it is a good representation of what you can expect with other data sources. If you want to try out other scalers, make sure you check out the [official samples page](https://github.com/kedacore/samples).