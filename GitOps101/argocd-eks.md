# Deploying ArgoCD with AWS EKS

For the demonstration of this lab, let us now perform continuous deployment with ArgoCD for an EKS cluster with a GitHub repo. 

## Requirements

You need a GitHub repo that has some sample code in it (optional since ArgoCD provides a sample), an EKS cluster (performance and the number of nodes do not matter), and [ArgoCD CLI](https://argo-cd.readthedocs.io/en/stable/cli_installation/) installed.

To start, make sure that your kubeconfig is pointing to the correct Kubernetes cluster, and let's start by creating a namespace for argocd:

```
kubectl create ns argocd
```

Followed by the ArgoCD deployment:

```
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

This is the same set of commands run in the previous general ArgoCD setup lab and would install several Kubernetes resources into your cluster.

Ensure that all the pods are running properly:

```
kubectl get po -n argocd
kubectl get svc -n argocd
```

You will see that there is a service that runs for ArgoCD. However, this service is only accessible from within the cluster. We will be using ALBs to make the location generally available in the future but for now, let's use port forwarding to access the dashboard.

```
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

You can now access the ArgoCD dashboard via localhost:8080. The initial username is admin, and the initial password can be found by running:

```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"
```

Note that this is a base64 value, and therefore needs to be decoded to get the actual password. You should then be good to log in to ArgoCD.

You can play around with the ArgoCD dashboard a bit, but we will get into that later. For now, open up a new terminal instance, and type:

```
argocd login localhost:8080
```

Now, you will need to provide the login credentials in the same way that you did with the dashboard. With that, you would have logged in to ArgoCD from the CLI. This is important since the ArgoCD docs mostly provide you with information on how to use Argo via CLI with CLI commands. To start, we will be setting up a project using the sample ArgoCD [helm-guestbook](https://github.com/argoproj/argocd-example-apps/tree/master/helm-guestbook):

```
argocd app create helm-guestbook --repo https://github.com/argoproj/argocd-example-apps.git --path helm-guestbook --dest-server https://kubernetes.default.svc --dest-namespace default
```

The above command creates a project called `helm-guestbook` from the `argocd-example-apps` repo. In the `path` argument, you specify which folder within the repo has the files ArgoCD needs to be concerned with. This is useful for a large project that has application code residing alongside the CI/CD code. Once the command is run, the repo will show up in ArgoCD, but a connection will not be made. You can use:

```
argocd app get helm-guestbook
```

You will see that the repo is out of sync. To get it to sync, use:

```
argocd app sync helm-guestbook
```

This will take a couple of minutes, but once it is complete, you should see that the application is in sync and healthy. Note that all this wasn't just a visual input. Rather, the application actually synchronized the Helm chart provided in the `helm-guestbook` folder and deployed it to your Kubernetes cluster. If you were to run:

```
kubectl get pods
```

you would see that a pod by the name of `helm-guestbook` is not running. In fact, you can access this application by first port forwarding:

```
kubectl port-forward svc/helm-guestbook 9090:80
```

And then go to http://localhost:9090. You should see a web application.

And that's it! Notice you didn't deploy any files yourself. You didn't add the repo with Helm, or install it. In fact, you didn't even clone the repo. All this was handled by ArgoCD. If there is a push to the repo, ArgoCD will automatically deploy the change to your cluster without any intervention from you.

## Conclusion

In this lab, we have seen how you can use ArgoCD to automate deployments to your EKS cluster with no intervention from yourself. This is roughly the same method you use when using ArgoCD with other cloud Kubernetes engines, as well as self-managed Kubernetes clusters.