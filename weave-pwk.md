# Setting up WeaveScope for visualizing Kubernetes Pods, Services, Containers & Hosts

[Weave Scope](https://www.weave.works/oss/scope/) is a visualization and monitoring tool for Docker and Kubernetes. It provides a top down view into your app as well as your entire infrastructure, and allows you to diagnose any problems with your distributed containerized app, in real time, as it is being deployed to a cloud provider.

## Pre-requisite

- Docker Desktop for Mac OR
- 5 Node Play with Kubernetes Cluster


## Installing WeaveScope

```
kubectl apply -f "https://cloud.weave.works/k8s/scope.yaml?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```

This downloads a recent Scope image from Dockerhub and launches a probe onto every node as well as a single Scope app. 
Once launched, Scope doesn’t require any other configuration.

Allowable parameters for the launcher URL:

```
v - Weave Scope version or tag, e.g. latest current release is the default
k8s-service-type - Kubernetes service type (for running Scope in Standalone mode), can be either LoadBalancer or NodePort, by default this is unspecified (only internal access)
Since we are trying to access it via play with kubernetes or Katakoda platform we need to change the service from ClusterIp to NodePort for that run the following command.
```

```
kubectl get svc -n weave -o yaml > svc.yaml && sed -i "s/ClusterIP/NodePort/g" svc.yaml && kubectl replace -f svc.yaml
```

## Open Scope in Your Browser


From the `kubectl get svc -n weave` take the Nodeport and hit open PWK on that port 


![My Image](https://raw.githubusercontent.com/collabnix/dockerlabs/master/kubernetes/workshop/weave-service.png)


Access Weavescope using NodePort(31741 in this case).

![My Image](https://raw.githubusercontent.com/collabnix/dockerlabs/master/kubernetes/workshop/Weave-UI.png)

[Next >>](https://collabnix.github.io/kubelabs/gke-setup.html)

