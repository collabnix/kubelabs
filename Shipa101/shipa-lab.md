# Lab

## Installing Shipa

As always, you need a cluster before you start. For this, you can either use any cluster that you have (on a Linux VM, on the cloud, etc...), or you can use [Minikube](https://minikube.sigs.k8s.io/docs/start/) to start a single node cluster on your local machine.

Next, we will be using [Helm](../Helm101/what-is-helm.md) to install Shipa. Helm allows you to install multiple resources that are packaged together as a chart, which is a lot faster than creating all the resources one by one manually. If you need a refresher on Helm, head over to the [Helm section](../Helm101/what-is-helm.md).

To start, add the ```shipa-charts``` helm repo:

```
helm repo add shipa-charts https://shipa-charts.storage.googleapis.com

helm repo update
```

Next, install the helm chart: 

```
helm upgrade --install shipa shipa-charts/shipa \
--create-namespace --namespace shipa-system \
--timeout=15m \
--set=auth.adminUser=admin@acme.com \
--set=auth.adminPassword=this-is-a-secret \
--set=shipaCluster.ingress.serviceType=ClusterIP \
--set=shipaCluster.ingress.clusterIp=10.100.10.10
```

If you are using Minikube, you also need to add routes to the nginx ingress:

```
sudo route -n add -host -net 10.100.10.10/32 $(minikube ip )
```

You also need to get the Shipa CLI so that you can execute Shipa commands using the command line. To do that, use curl:

```
curl -s https://storage.googleapis.com/shipa-client/install.sh | bash
```

You can also use brew:

```
brew tap shipa-corp/CLI

brew install shipa-cli
```

If you are using Minkube, also change the local Shipa instance so that it points at your Shipa CLI:

```
shipa target add -s shipa-minikube 10.100.10.10
```

Now you essentially have Shipa fully installed. As the last step, let's bring up the Shipa dashboard. To do that, first login (using the dummy credentials your specified), and then list the Shipa instances:

```
shipa login

shipa app list
```

This should output the list of instances, which should also show a link in the ```Address``` column. Use this to open the dashboard. If you have any trouble accessing this link, you may need to use port forwarding. Use:

```
kubectl get svc -n shipa-system
```

You will get a list of ports that are exposed using ClusterIP. You need to choose the one called ```dashboard-web-1``` running on port 8888. ClusterIP is an internal network port and doesn't allow external connections, so we will forward the port:

```
kubectl port-forward -n shipa-system svc/dashboard-web-1 8888
```

You can then open up the page on localhost (port 8888) and follow the three steps to gain access to the Shipa dashboard. Once you're in, the installation part of Shipa is complete.

## Separating the teams

Since you're an admin in the Shipa dashboard, you can use the UI to create users. Simply select the user's section from the left-hand pane, and create Users. Once that has been done, you can use the Teams left-hand pane to create a new team. Now that both of these things are done, you have to add the users to the team.

To do this, we will be heading back to the CLI which has been already set up with Shipa.

```
shipa user-list
```

This should show you the list of users.

Let's first create a role called "developer":

```
shipa role add developer team
```

Then we can set permissions for each of these roles:

```
shipa role-permission-add developer app cluster.read framework.read framework.update
```

This assigns several permissions to your role. Finally, assign the role to the user you just created:

```
shipa role-assign developer <email> shipa-dev-team
```

The entire team can then be assigned roles, permissions, and granted/removed access. This means that when a new user joins the team, they automatically get the same level of access that the rest of the team has, and you don't have to manually assign the roles to each one of them. Note that while we have created a team and added a user to it, we haven't created any access rules or permissions for that team. These rules and permissions are defined within what is called a Shipa framework. Creating a framework can be done using the UI in the same way as creating a user, so let's head over to the browser.

On the left pane, find the section called frameworks, and add a framework. First, set the name and the namespace to which the framework will apply, then set the security settings. In the input box labelled "Grant access to teams", you can select the shipa-dev-team you just created. The namespace you specified will be the **only** namespace this framework will apply to. Now, you need to create another cluster and [connect it](https://learn.shipa.io/docs/connecting-clusters#cluster-configuration) to Shipa as the development cluster before you can assume the role of a developer and test it out.

To log in as a developer, you would run the same ```shipa login``` command as before, except this time you would use the developer email you used when creating the user initially. As a developer, if you want to deploy your application, you could either:

- Deploy the code directly using ```shipa app deploy <artifact>```
- Deploy a Docker image using ```shipa app deploy <registry>```

Or, to make things even simpler, just do not do any of that and instead commit your code to a branch in your existing repo. That way, developers don't even have to have the Shipa CLI installed. So how does that work?