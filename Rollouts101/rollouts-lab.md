# Rollouts lab

As always, you need to have a Kubernetes cluster ready for use. Any cluster is fine since we are only interested in deployments today. Additionally, you will also need to install the below resources:

- ArgoCD: [Installation guide](../GitOps101/argocd.md#deploying-argocd)
- Linkerd: [Installation guide](../ServiceMesh101/what-is-linkerd.md#setting-up-linkerd)

We will be using ArgoCD for header-based traffic routing and LinkerD for both header-based and traffic split-based routing. So, once the above two items are in place, let's get started.

## Header based splitting

For both cases, we will use an application designed for canary deployments. Run the below commands:

```
kubectl create ns test --dry-run=client -o yaml \
 | linkerd inject - \
 | kubectl apply -f -

helm repo add podinfo https://stefanprodan.github.io/podinfo
helm install backend-a -n test \
 --set ui.message='A backend' podinfo/podinfo
helm install backend-b -n test \
 --set ui.message='B backend' podinfo/podinfo

helm install frontend -n test \
 --set backend=http://backend-a-podinfo:9898/env podinfo/podinfo

kubectl -n test port-forward svc/frontend-podinfo 9898 &
```

This injects linkerd to a new namespace "test" which will be used for both types of routing, then installs an application on it. This application will be a simple application with 2 backends. We will be splitting the traffic to either of the backends depending on our configuration. For now, test the application with curl:

```
$ curl -sX POST localhost:9898/echo \
 | grep -o 'PODINFO_UI_MESSAGE=. backend'

PODINFO_UI_MESSAGE=A backend
```

Since we haven't introduced any traffic splitting the message will always show the response as "A".