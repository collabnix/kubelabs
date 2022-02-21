# How to get Started with ArgoCD on Docker Desktop for Mac

<img width="799" alt="image" src="https://user-images.githubusercontent.com/313480/153880288-6ff2c6ee-97f7-41f0-87d8-fc08a123ca30.png">


## Pre-requisite:
- Install Docker Desktop
- Enable Kubernetes


## Getting Started

## Step 1. Create a new namespace

Create a namespace argocd where all ArgoCD resources will be installed

```
kubectl create namespace argocd
```

## Step 2. Install ArgoCD resources 


```
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

```
kubectl get po -n argocd
NAME                                  READY   STATUS              RESTARTS   AGE
argocd-application-controller-0       0/1     ContainerCreating   0          3m9s
argocd-dex-server-65bf5f4fc7-5kjg6    0/1     Init:0/1            0          3m13s
argocd-redis-d486999b7-929q9          0/1     ContainerCreating   0          3m13s
argocd-repo-server-8465d84869-rpr9n   0/1     Init:0/1            0          3m12s
argocd-server-87b47d787-gxwlb         0/1     ContainerCreating   0          3m11s
```

## Step 3. Ensure that all Pods are up and running

```
kubectl get po -n argocd
NAME                                  READY   STATUS    RESTARTS   AGE
argocd-application-controller-0       1/1     Running   0          5m25s
argocd-dex-server-65bf5f4fc7-5kjg6    1/1     Running   0          5m29s
argocd-redis-d486999b7-929q9          1/1     Running   0          5m29s
argocd-repo-server-8465d84869-rpr9n   1/1     Running   0          5m28s
argocd-server-87b47d787-gxwlb         1/1     Running   0          5m27s
```

## Step 4. Configuring Port Forwarding for Dashboard Access

```
kubectl port-forward svc/argocd-server -n argocd 8080:443
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
```

<img width="1387" alt="image" src="https://user-images.githubusercontent.com/313480/153880395-5295ba73-aae1-459c-8cde-c587e8688e07.png">


## Step 5. Logging in 


```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

HcD1I0XXXXXQVrq-
```

<img width="1776" alt="image" src="https://user-images.githubusercontent.com/313480/153880622-48f716bd-b807-41c5-bcc4-cc0fb57d365e.png">



## Step 6. Install argoCD CLI on Mac using Homebrew

```
brew install argocd
```

## Step 7. Access The Argo CD API Server

By default, the Argo CD API server is not exposed with an external IP. To access the API server, choose one of the following techniques to expose the Argo CD API server:


```
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
service/argocd-server patched
```


## Step 8. Login to ArgoCD

```
argocd login localhost      
WARNING: server certificate had error: x509: certificate signed by unknown authority. Proceed insecurely (y/n)? y
Username: admin
Password: 
'admin:login' logged in successfully
Context 'localhost' updated

```


## Step 9. Update the password


```

ajeetraina@Ajeets-MacBook-Pro ~ % argocd account update-password
*** Enter password of currently logged in user (admin):                       
*** Enter new password for user admin: 
*** Confirm new password for user admin: 
Password updated
Context 'localhost' updated
ajeetraina@Ajeets-MacBook-Pro ~ % 
```

## Step 10. Register A Cluster To Deploy Apps To

As we are running it on Docker Desktop, we will add it accordingly.

```
argocd cluster add docker-desktop
WARNING: This will create a service account `argocd-manager` on the cluster referenced by context `docker-desktop` with full cluster level admin privileges. Do you want to continue [y/N]? y
INFO[0002] ServiceAccount "argocd-manager" created in namespace "kube-system" 
INFO[0002] ClusterRole "argocd-manager-role" created    
INFO[0002] ClusterRoleBinding "argocd-manager-role-binding" created 
Cluster 'https://kubernetes.docker.internal:6443' added

```
