# Rollouts lab

As always, you need to have a Kubernetes cluster ready for use. Any cluster is fine since we are only interested in deployments today. Additionally, you will also need to install the below resources:

- ArgoCD: [Installation guide](../GitOps101/argocd.md#deploying-argocd)
- Linkerd: [Installation guide](../ServiceMesh101/what-is-linkerd.md#setting-up-linkerd)

We will be using ArgoCD for header-based traffic routing and LinkerD for both header-based and traffic split-based routing. So, once the above two items are in place, let's get started.

## Header based splitting