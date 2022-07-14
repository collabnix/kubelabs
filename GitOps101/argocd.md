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

Keeping such a tight grip on version control comes with all the benefits of git, such as the git history, git diffs, the ability to revert and reset changes, tag release commits, and basically anything that git allows you to do. Since your cluster can only be changed via Git, this improves cluster security without you having to use RBAC, create cluster roles, assign those roles, etc... This includes cluster roles you may have had to create for service accounts such as Jenkins.

## ArgoCD and your cluster

ArgoCD integrates right into your cluster and uses existing k8 resources to look for changes. This means it has full visibility into your cluster and won't miss anything.