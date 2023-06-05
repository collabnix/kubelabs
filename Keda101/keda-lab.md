# KEDA Lab

## Requirements

To start, you need to have a Kubernetes cluster. [Minikube](https://minikube.sigs.k8s.io/docs/start/) is a quick and easy way to get set up with a single node cluster.

Once you have a cluster up and running, you need to deploy an application to it. This application will then be scaled with KEDA depending on a specific metric. KEDA already provides several sample applications that cover a large number of data sources in their [GitHub repo](https://github.com/kedacore/samples), and we will be using one of these samples in this lab.

In this case, we will be using the [MySQL scaler](https://keda.sh/docs/2.10/scalers/mysql/) and following the sample [here](https://github.com/turbaszek/keda-example). Start by cloning the repo:

```
git clone https://github.com/turbaszek/keda-example.git
```

You now have all the configuration files required to do the deployment. The `Deployment` folder you find inside the repo are all the files you need to deploy. Go ahead and deploy all the resources to the cluster:

```
kubectl apply -f deployment/
```

While the deployment takes place, let's take a look at what we are deploying. First, you will notice that there are two deployments: MySQL and Redis. The [mysql deployment](https://github.com/turbaszek/keda-example/blob/master/deployment/mysql-deployment.yaml) is straightforward. A Service, a PersistentVolumeClaim, and a Deployment. The service opens up a simple port (3306). The PersistentVolumeClaim is a necessary part of any database system since pods are ephemeral. When the pod goes down, any data that it held would disappear, which would be a pretty terrible design for a database that is designed to hold data forever. Therefore, a permanent volume is used to hold data. Finally, you have the deployment, which holds the main part of the resource. This deployment is a simple MySQL image running with 1 replica on port 3306 with the admin password "keda-talk".

If you look at the [redis deployment](https://github.com/turbaszek/keda-example/blob/master/deployment/redis-deployment.yaml), it's basically the same thing, running on the port with 6379.

You also have a [service account resource](https://github.com/turbaszek/keda-example/blob/master/deployment/make-user.yaml) which creates a cluster role that is an admin. This is the unrestricted role that will be used across the cluster.

Next, you have the app and API deployments, which constitute the web application that will be connecting to the Redis and MySQL applications.