# Kubernetes cluster observability

In this section, we will look at several tools that can help improve your cluster administration and observability. This won't cover monitoring tools like Prometheus and Grafana, which are tools used to read metrics from, but rather tools that allow you to perform actions on your clusters such as [KubeSphere](../KubeSphere/what-is-kubesphere.md). Since we've already discussed in detail about KubeSphere, which is a rather heavy-weight application that has all sorts of features, let's take a look at more light-weight alternatives that focus largely on converting your various kubectl commands to UI-based interface options.

## Lens

Let's start with one of the most popular cluster observability tools out there: Kube Lens. This is a desktop tool that can be used to perform pretty much anything you would do with the kubectl command line and is very stable and feature-rich. If you are a DevOps engineer working with Kubernetes clusters, Lens is a must.