# Running Portainer on 5-Node Kubernetes Cluster

## What is Portainer?

![logo](https://www.portainer.io/hubfs/portainer-logo-black.svg)
Portainer is a one-stop shop for managing your containerized environments, providing a massive amount of functionality in both our Community and Business Editions. We often hear from our users, “Wow, I didn’t know Portainer could do that!” So here’s a list of what you can do with Portainer.

## Pre-requisites:

- Play with Kubernetes Platform
- Set up 5 Node Kubernetes Cluster

## Run the below command:

```
kubectl apply -f https://raw.githubusercontent.com/portainer/portainer-k8s/master/portainer-nodeport.yaml
```

## Verify

```
[node1 kubelabs]$ kubectl get po,svc,deploy -n portainer
NAME                             READY   STATUS    RESTARTS   AGE
pod/portainer-58767884bc-jqfnn   1/1     Running   2          13m

NAME                TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)                         AGE
service/portainer   NodePort   10.111.121.188   <none>        9000:30777/TCP,8000:30776/TCP   13m

NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/portainer   1/1     1            1           13m
[node1 kubelabs]$
```

## Opening up Browser

Go to browser and add the port in the following manner:

```
https://ip172-18-0-7-bs6kb2bmjflg00fa5g4g-<ADD 30777 HERE>.direct.labs.play-with-k8s.com/
```






