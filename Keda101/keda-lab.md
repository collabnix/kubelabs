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

While the deployment takes place, let's take a look at what we are deploying.