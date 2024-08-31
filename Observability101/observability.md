# Kubernetes cluster observability

In this section, we will look at several tools that can help improve your cluster administration and observability. This won't cover monitoring tools like Prometheus and Grafana, which are tools used to read metrics from, but rather tools that allow you to perform actions on your clusters such as [KubeSphere](../KubeSphere/what-is-kubesphere.md). Since we've already discussed in detail about KubeSphere, which is a rather heavy-weight application that has all sorts of features, let's take a look at more light-weight alternatives that focus largely on converting your various kubectl commands to UI-based interface options.

## Lens

Let's start with one of the most popular cluster observability tools: Kube Lens. This is a desktop tool that can be used to perform pretty much anything you would do with the kubectl command line and is very stable and feature-rich. If you are a DevOps engineer working with Kubernetes clusters, Lens is a must. There are two versions of Lens: the one maintained by Mirantis (https://k8slens.dev) and the Open Lens maintained by the community. They both largely have the same features and provide an excellent way to access your cluster without using a host of kubectl commands.

Since Lens is a desktop tool, the setup is fairly simple - assuming you already have the cluster accessible via kubectl. If this is the case, all you have to do is install the desktop application, and your cluster should be in the catalog section of Lens. Once you connect to the cluster, you will be shown a list of resources, all relating to your Kubernetes cluster. This will include workloads (such as pods, and jobs), resources such as nodes, networking objects such as services and ingresses, etc... You should also be able to easily edit each of these resources using the inbuilt editor, as well as exec into pods, nodes, and other resources. You can also select custom resources created by CRDs, and view and edit them.

Another cool feature Lens provides is the ability to port forward any port onto localhost. This is the same functionality provided by the `kubectl port-forward` command but allows you to skip having to write out the command each time. It's generally accepted that Lens is a pretty great tool for any beginners who want to get into Kubernetes without having to belt out an army of commands for everything.

Another notable mention for Kubernetes desktop IDEs is Octant, developed by VMware.

It's also great for developers and QA who aren't necessarily familiar with kubectl, but want to check deployments, container logs, etc... on dev and QA Kubernetes clusters. The problem for these people is having to set up the cluster on their local machines before using it to access Lens. For example, if we were dealing with an EKS cluster, they would have to be given the correct permissions from IAM, get the access key and secret key, download the AWS CLI, set it up on their machines, and run the `AWS update kubeconfig` command to get the cluster available. This might not be an issue for you or anyone in the DevOps team since you would have the cluster ready on your machine anyway, but it's a bunch of extra steps for a non-DevOps person. This is where the web-based dashboards come in.

## Headlamp

[Headlamp](https://headlamp.dev) is an excellent option for a very minimal, no-frills Kubernetes dashboard. This is a React-based project that can be set up both as a desktop application as well as a browser-based app. The browser-based version is probably the most lightweight, yet fully featured dashboard out there, running a single pod that takes around 10MB of memory. This makes it a great option for small clusters, where you don't want the dashboard taking up too many resources. Headlamp allows you to do almost everything you can do with kubectl, such as view, edit, and configure resources. It also allows you to exec into pods, but not nodes (as of right now). One especially cool feature of Headlamp is its extensible plugin system, which allows you to extend the libraries provided by Headlamp to add your own components to the Headlamp dashboard as you see fit. These include things like changing logos, adding items to the sidebar, and title bar, creating your own custom pages, etc... You can see some examples of this functionality in their [plugins page](https://headlamp.dev/docs/latest/development/plugins/functionality).

If you are running as a production cluster, then you need to limit the number of people that can access this cluster. Since the Headlamp dashboard can allow you to do admin-level stuff with your Kubernetes cluster, you must enable authentication. To support this, Headlamp allows all sorts of authentication for your cluster such as Dex, Keycloak, and AWS Cognito. Essentially every type of OIDC authentication is supported. You can get more information on this on their [authentication page](https://headlamp.dev/docs/latest/installation/in-cluster/dex/). We shall discuss using tools like Keycloak with Kubernetes to secure your in-cluster services in a different section. Headlamp is fully open source and does not have an enterprise edition, but its very easy to get support from the great community of Headlamp users.

To install a headlamp on your cluster, all you have to do is:

```
helm repo add headlamp https://headlamp-k8s.github.io/headlamp/
helm install my-headlamp headlamp/headlamp --namespace kube-system
```

You can change the default installation using custom values.yaml.

```
helm install my-headlamp headlamp/headlamp --namespace kube-system -f values.yaml
helm install my-headlamp headlamp/headlamp --namespace kube-system --set replicaCount=2
```

Or you could install everything with a kubectl deployment:

```
kubectl apply -f https://raw.githubusercontent.com/kinvolk/headlamp/main/kubernetes-headlamp.yaml
```

After that, you can expose Headlamp in a couple of ways. If you are on a cloud provider, then edit the headlamp service and change the service type to `LoadBalancer`. This will create an internet-facing LB that you can access. If you already have a VPN setup for your cloud VPC, you could add the annotation `service.beta.kubernetes.io/aws-load-balancer-internal: 'true'` which will make the LB internal (assuming you're on AWS, other providers will have different annotations).

You could also expose it with port forwarding.

```
kubectl port-forward -n kube-system service/headlamp 8080:80
```

This is the easiest option of you are running on something like Minikube. Or, you could [expose Headlamp with an ingress server](https://headlamp.dev/docs/latest/installation/in-cluster/#exposing-headlamp-with-an-ingress-server).

Once that is done, head over to the dashboard, and you will be presented with a login screen. To login, create a service account and get service token:

```
kubectl -n kube-system create serviceaccount headlamp-admin
kubectl create clusterrolebinding headlamp-admin --serviceaccount=kube-system:headlamp-admin --clusterrole=cluster-admin
kubectl create token headlamp-admin -n kube-system
```

Note that this service token is temporary and shouldn't be used as a login mechanism anyway. It's best to setup login properly with OIDC. Once OIDC is setup, you can use the native Kubernetes RBAC roles to decide who gets what access.

Sidenote: Headlamp desktop allows managing multiple clusters but the web version does not.

While Headlamp is a great, lightweight web-based dashboard, it only allows you to observe and perform basic functions on your cluster. If you need a much more heavy-hitting application that gives you observability, but also allows you to cram the entire build & deploy pipeline into a single tool, you can consider a tool like Devtron.

## Devtron

Devtron has all the features of Headlamp & Lens, such as viewing, editing, and logging, but it also includes its own build and deploy stack. If you wanted to have headlamp level of functionality without any of the added stuff, Devtron allows you to easily install just thhe core dashboard without any integrations:

```
helm repo add devtron https://helm.devtron.ai
helm repo update devtron
helm install devtron devtron/devtron-operator \
--create-namespace --namespace devtroncd
```

Exposing this is similar to exposing Headlamp. You could use:

```
kubectl get svc -n devtroncd devtron-service -o jsonpath='{.status.loadBalancer.ingress}'
```

To get the load balancer path. Like Headlamp, Devtron provides easy integration with OIDC providers like Keycloak and Dex. They additionally also provide you with SSO integration for major SSO providers such as Google and Microsoft, as well as support for LDAP. Compared to Headlamp, Devtron has its own UI that allows you to specify access to resources, users, and roles. You can define permission groups, create new users, and then assign those permission groups to users. You can also assign multiple permission groups to a single user, meaning that you can have increasingly permissive groups for each user.

Now that we have covered all the areas that Devtron and Headlamp have in common, let's move to the areas that are different: the application stack. If you installed Devtron without any integrations, you can simple install only the integration without having to reinstall the entire Helm chart by going to the Devtron stack manager in the UI from the left navigation bar. Under INTEGRATIONS, select Discover.

You can create a Devtron application that reads off a repo and builds the application based on your specifications. The image gets pushed to your image repo of choice, and you can then have additional CI/CD pipelines that deploy this image into your cluster. The image can be deployed with regular Kubernetes manifest files, or with Helm charts. This is part of the Build & Deploy integration. One thing you have to keep in mind is that the stack is unique to Devtron. So for example, you can't migrate your Jenkins build pipelines directly into Devtron. You will instead have to set them up as Devtron apps. Once you have set up the Devtron apps, your builds will run on your Kubernetes infrastructure by spinning up pods to run the build processes. Once the builds are finished, the pods will leave, thereby saving resources. Jenkins has a similar master-slave architecture, and you can actually install Jenkins on your cluster and have a similar functionality. However, if your applications are Kubernetes-based, Devtron makes the whole setup easier since you can monitor the entire build, deployment, and run process from the same dashboard.

Another integration Devtron provides is GitOps with ArgoCD. For more information on GitOps, head to the [GitOps](../GitOps101/what-is-gitops.md) section. Since Devtron apps are inherently designed to be compatible with ArgoCD, there is no additional setup to integrate your application into GitOps after you have set up your Devtron apps.

An essential feature Devtron provides is vulnerability scanning using [Clair](https://github.com/quay/clair). As your Devtron apps build your source, they create Docker images. These images can have vulnerabilities, or use base images/packages that have vulnerabilities. Clair will automatically analyze these images as they are built, and provide a vulnerability report. You could additionally set security policies so that when trying to deploy an application that uses vulnerable images, it gets blocked. This is very useful in enterprise situations where security is a major concern. In addition to the threat of attacks, organizations also have certain compliance standards they must meet, such as SOC or ISO compliance. These have certain requirements (such as 0 critical or high-priority vulnerabilities in images), and having your CI/CD tool actively block images that don't meet these standards from being deployed is massively helpful in ensuring that your security audits don't fail.

Another feature Devtron has is alerting. Any events that occur on your build or deployment pipelines can be alerted via email or Slack. This is a fairly basic configuration that you will find in most CI/CD systems such as Jenkins.

The final feature that Devtron has is monitoring with Grafana. Once you have finished deploying your application to your Kubernetes cluster, you can check the application metrics like CPU, Memory utilization, Status 4xx/ 5xx/ 2xx, Throughput, and Latency. This skips all the steps involved in setting up Grafana yourself and installs the full stack for you.

So all in all, Devtron provides much more than just a resource browser that can be used to control the Kubernetes cluster. It also allows you to build images, check them for vulnerabilities, then deploy them. Once the deployment is complete, you also get to monitor the health of these deployments and alert if something goes wrong. So it's the full end-to-end package.

One additional feature Devtron has is multi-cluster management. If your organization has several clusters, you can get access to all of them within the same dashboard. There are two ways to do this, and the easiest is to create a service account in your second cluster that allows Devtron to perform operations on it. To do this, Devtron has provided a straightforward bash script that can be run which does the job for you. First, make sure you are in your second clusters' contexts, then run:

```
curl -O https://raw.githubusercontent.com/devtron-labs/utilities/main/kubeconfig-exporter/kubernetes_export_sa.sh && bash kubernetes_export_sa.sh cd-user  devtroncd
```

Add the server URL and token you get from this command to the Devtron UI and your cluster should start showing up in the resource browser. Full instructions can be found [in the official docs](https://docs.devtron.ai/global-configurations/cluster-and-environments#add-cluster). Another way to add a cluster is using the kubeconfig. Instructions to do this can be found [here](https://docs.devtron.ai/global-configurations/cluster-and-environments#add-clusters-using-kubeconfig). Note that if your cluster is hosted on a cloud provider, you can't just copy and paste the kubeconfig and expect it to work.

Now, let's move on to [portainer](https://www.portainer.io), which provides most features of Devtron, but also gives some additional options your organization might find useful.

## Portainer

Portainer is a container management platform, which means that it dips into the realm of Docker/Docker swarms as well as Kubernetes. It works with basically every containerization platform, cloud service, and even your self hosted platforms.

For starters, it allows users to create, manage, and monitor Docker containers. It also allows operational functions such as starting, stopping, pausing, and restarting containers. You can also view container logs, resource usage, network configurations, and other metrics related to these containers. You also have an in-built image repo that facilitates pulling, pushing, and managing Docker images. This means you can create new containers from images or build images directly from Dockerfiles.

Managing the volumes used in both your Docker containers as well as PVCs used in Kubernetes is another feature available in Portainer, as well as the ability to create custom networks and attach/detach containers from them. When it comes to Kubernetes support, Portainer can manage Kubernetes clusters, making it easier for users to deploy and monitor workloads, services, and configurations within Kubernetes. It also supports Docker Swarm environments. You also have RBAC allowing administrators to define user roles and permissions. It also supports multi-user environments with authentication mechanisms like LDAP, OAuth, and more. Note that most of these features are enterprise grade.

Portainer also has a catalog of templates for commonly used applications, simplifying the deployment process. Users can also deploy multi-container applications using stacks, which are defined using Docker Compose files. Similar to Devtron, you also get CI/CD support, enabling automated deployment and management. Portainer also has the added management functionality of secrets, environments, and custom registries.

You also get real-time monitoring of container performance, including CPU, memory, and network usage simliar to what you would get out of Grafana and Prometheus. You also have logging capabilities similar to the other tools on this list which provides access to container logs for debugging and auditing purposes.

When it comes to deployments, there are several ways to do it depending on which environment you are using. It is containerized so it can run on your Docker environments just fine (both Docker standalone & Docker swarm). On Kubernetes, you use Helm like so:

```
helm repo add portainer https://portainer.github.io/k8s/
helm repo update
helm upgrade --install --create-namespace -n portainer portainer portainer/portainer \
    --set tls.force=true \
    --set image.tag=2.21.0
```

Or you could use plain kubectl:

```
kubectl apply -n portainer -f https://downloads.portainer.io/ce2-21/portainer.yaml
```

If you want to expose the service via LoadBalancer instead of NodePort:

```
kubectl apply -n portainer -f https://downloads.portainer.io/ce2-21/portainer-lb.yaml
```

Once you do this, you should be able to access the Portainer UI via localhost or the load balancer URL. From here on, all you need to do is create an initial admin user, then connect Portainer to your environments.

Overall, Portainer is a powerful tool for simplifying container and cluster management, making it accessible to a broader audience, including developers, sysadmins, and DevOps teams.

## Octant

Next, let's look at Octant by VMware. Octant toes the line between being a desktop application and a web interface, in that you install it locally on your desktop, and it launches a server that gives you access to your cluster using your web browser. It uses your local kubeconfig to provide access to your clusters. Hence, there is no additional configuration required, and you can set up the kubeconfig in a server and have Octant installed on it, then serve it using a simple Nginx server. However, it is impossible to restrict access based on roles since the application was not designed for it. Specifically, Octant is designed to manage Tanzu Kubernetes Clusters, which are preconfigured enterprise-grade clusters provided by VMware.

Octant provides all the features of tools such as Headlamp & Lens, except this has a high focus on development. While the other tools are mainly designed to be used by DevOps teams, Octant comes with inbuilt support for debugging and plug-ins over gRPC which are designed to be used by development teams testing out their software in Kubernetes clusters. So it makes sense that the tool would be run locally on your machine similar to an IDE used to debug application code instead of a web interface shared by many people. So depending on your use case, this might not fit your needs.

## ArgoCD

ArgoCD is not a cluster observability/operations tool, but rather a GitOps tool used to automate CI/CD processes. However, it deserves an honorable mention since it gives observability/operations access to all parts of a Kubernetes cluster other than the nodes. ArgoCD allows you to deploy new application revisions and then lays out a resource map of all the resources that come up when the deployment is performed. You can then edit/delete these resources from the same dashboard and it will get updated in real-time. ArgoCD also allows you to view the logs & events of a pod, and with a little configuration, you should be able to shell into a pod from within ArgoCD as well.