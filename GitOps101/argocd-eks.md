# Deploying ArgoCD with AWS EKS

For the demonstration of this lab, let us now perform continuous deployment with ArgoCD for an EKS cluster with a GitHub repo. 

## Requirements

You need a GitHub repo that has some sample code in it, an EKS cluster (performance and the number of nodes do not matter), and [ArgoCD CLI](https://argo-cd.readthedocs.io/en/stable/cli_installation/) installed.

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