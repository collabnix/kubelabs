# ArgoCD

ArgoCD is a tool that helps integrate GitOps into your pipeline. The first thing to note is that ArgoCD does not replace your entire release pipeline and only part of it. For you to efficiently use ArgoCD, you will need to have a pipeline set up that allows your pull request to be merged, after which there will be available configuration files that can get applied to a cluster. It is at this point that ArgoCD steps in to apply your configuration to the cluster. Before we get into that, let's dive a little deeper into the deployment models, and discuss the reasons for using ArgoCD.

## Push deployment vs Pull deployment

We discussed these two deployment strategies briefly in the previous section. A push deployment strategy will require you to have a pipeline that builds your images and prepares your configurations, but would also go that additional step of deploying your IaaC files into your Kubernetes cluster. The main advantage of this strategy is that everything is placed in one pipeline, and is therefore easy to understand. However, the fact that your pipeline is a different entity from your cluster will bring forward several problems.

Let's imagine you have implemented your pipeline in Jenkins. First of all, your Jenkins machine needs to have some way of deploying your yaml files into a cluster, and therefore needs to have the necessary tools (such as kubectl) installed. Secondly, the Jenkins machine needs to be given access to the cluster, which means giving it access to the kubeconfig file. This poses a security risk, which is made worse if you are hosting your cluster on a cloud provider such as AKS or EKS since you also have to give your Jenkins machine access to these clusters. The final problem lies in the fact that there is no transparency on what happens after you apply your changes into the cluster. The best you can do is to continuously poll the cluster to see if the resource is up and running, which is not a perfect solution.

Instead, the pull deployment model is more suitable for applying changes to your cluster. Your pipeline places the resource in a state that it is ready to be deployed, and then its work ends. At that point, a service (such as ArgoCD) running in your cluster will compare the state of the current cluster with the desired state that the cluster should be in. Once it notices a parity, your changes will be applied to the cluster. In summary, the changes are pulled in from within the cluster, which is why the model is called a pull deployment model.

## How does ArgoCD work?

In the previous lesson, we spoke of how it is essential to maintain a separate Git repo for your infrastructure as code. If you have that sort of repo, then you can install ArgoCD in your cluster and have it monitor your repo for any changes. Once the master branch of the repo receives configuration file changes, ArgoCD will be automatically updated. ArgoCD can identify any Kubernetes Yaml files, as well as any files that eventually generate Kubernetes Yaml files such as Helm charts and Kustomize files.

This helps split the work between development and operations teams, where the pipeline that integrates changes to master is the responsibility of the development team, and the continuous delivery part that is handled by ArgoCD is handled by the operations team. 

An important point to note is that ArgoCD looks for desynchronizations between the Git repo and the cluster, meaning that if a change is done to the cluster directly, this will count as a desynchronization, which will then prompt ArgoCD to update itself from Git and undo any changes done directly to the cluster. This helps maintain the GitOps principle that we discussed earlier that there should be a single source of truth. In this case, it is the Git repo. You should be able to consider the files inside the repo and be assured that what you see there is what's running in your cluster. You could, however, configure ArgoCD to prevent this sync from happening although it would break the principle.

Keeping such a tight grip on version control comes with all the benefits of git, such as the git history, git diffs, the ability to revert and reset changes, tag release commits, and basically anything that git allows you to do. Since your cluster can only be changed via Git, this improves cluster security without you having to use RBAC, create cluster roles, assign those roles, etc... This includes cluster roles you may have had to create for service accounts such as Jenkins. ArgoCD integrates right into your cluster and uses existing k8 resources to look for changes. This means it has full visibility into your cluster and won't miss anything.

## Deploying ArgoCD

If you are setting up ArgoCD, then you need some essentials. You need a Kubernetes cluster, a Git repo, and a pipeline. To add ArgoCD to your existing cluster, you only have to create a namespace and apply the ArgoCD deployment YAML.

```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Once you install ArgoCD, it should sping up a service that you can connect to. It's recommended to use Kubernetes port forwarding to forward requests (such as from localhost:8080) to this service. Once you do that, you should be able to go to the localhost page and see the ArgoCD dashboard. The [ArgoCD documentation](https://argo-cd.readthedocs.io/en/stable/getting_started/) is a great guide to getting started.

ArgoCD uses custom resource definitions to extend the Kubernets API, and therefore requires the resources to  be defined as a k8 yaml file of ```kind: Application```. This is what a simple ArgoCD application definition looks like (taken from the ArgoCD [documentation](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/)):

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD
    path: guestbook
  destination:
    server: https://kubernetes.default.svc
    namespace: guestbook
  
  syncPolicy: 
    syncOptions: 
    - CreateNamespace=true
```

The YAML is rather self-explanatory, and it contains two main parts. The part under ```source``` and the part under ```destination```. The source represents the Git source that resembles the desired state your cluster should be in, and the destination represents the cluster you are aiming at. Under ```source```, you set the ```repoUrl```, which points to the repository you want to sync with your cluster, followed by the ```targetRevision```, which points to the commit you want to target. Setting ```HEAD``` points at the latest commit, which is what you usually want, by you can set it to a different commit hash depending on your needs. The last option ```path``` points to the folder within the repository that you want to track. This is useful if you want to use a single repo to control multiple clusters where you can point the source at various paths in the repo.

Considering the ```destination```, the first variable is the ```server``` variable, where you need to set the location of your Kubernetes cluster. In the above example, we are assuming that you are running ArgoCD in that same server that your cluster is available in, which means that you can use ```https://kubernetes.default.svc``` to point at it. However, if you are using a cluster elsewhere, this needs to point there. The second variable is ```namespace```, which specifies the namespace where you want the deployments to happen.

Another important option is the ```syncOptions```, which allows you to have better control over how ArgoCD syncs with your cluster. In the above case, an option has been added to create the namespace if it doesn't exist. A comprehensive list of available options can be found in the [official documenatation](https://argo-cd.readthedocs.io/en/stable/user-guide/sync-options/). Another sync policy that is important to look at is the [automated syncpolicy](https://argo-cd.readthedocs.io/en/stable/user-guide/auto_sync/), which gives you options such as allowing the application to self-heal, sync, and many other options that you would need to fine-tune when running ArgoCD with a commercial grade cluster.

While this simple exmaple is good for a small cluster, you probably want something a little more complex for commercial clusters since large clusters that have various microservices that are managed by different teams would have trouble using a single Git repo for everything. As such, you can define different yaml files for individual microservices and have them bound to different Git repos. Still, this is not a perfect solution since a different Git repo for each microservice would be infeasible, which is where Application Sets come in. 

A single resource is called an application, so it's easy to summarize that an application set is a bunch of application. That is to say, a group of resources in the cluster that are grouped together. Manually creating applications for similar resources makes little sense, so you could use a resource of ```kind: ApplicationSet``` to generate these application for you. Consider the below sample ApplicationSet, which is an extension of the single application from above:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: guestbook
spec:
  generators:
  - list:
      elements:
      - cluster: engineering-dev
        url: https://1.2.3.4
      - cluster: engineering-prod
        url: https://2.4.6.8
      - cluster: finance-preprod
        url: https://9.8.7.6
  template:
    metadata:
      name: '{{cluster}}-guestbook'
    spec:
      project: default
      source:
        repoURL: https://github.com/argoproj/argo-cd.git
        targetRevision: HEAD
        path: applicationset/examples/list-generator/guestbook/{{cluster}}
      destination:
        server: '{{url}}'
        namespace: guestbook
```

Once again, the source and the destination sections are the most important, and you will notice that a single source repo is now pointing to multiple clusters (which can be set by changing the ```{{url}}``` part of the yaml).

## ArgoCD with multiple clusters

If you were to have the same cluster hosted multiple times (for instance, across multiple regions), then you probably want to update all those clusters at once. ArgoCD allows you to configure multiple destination clusters so that with a single push of your Git repository, the configuration changes get applied to all the clusters at once.

Another place where this might be useful is when you have multiple clusters in your release process which you use for testing before your release. For example, you might have a dev environment where you first apply the cluster, after which testing is performed. If the testing passes, then the cluster should be applied to a prod env, and so on. You are applying the same configuration to different clusters, but not all at once, and this is also something that ArgoCD supports without you having to use separate branches for each cluster. For this, you should use Kustomize overlays.

Kustomize is a CLI tool that is integrated with kubectl which helps you create overlays from source control for different situations. As you can imagine, this is great for handling different clusters that are similar in nature but serve different purposes. You could have on Kustomization for dev, another for prod, and have them applied so that the configuration changes are applied only when you need them to be.