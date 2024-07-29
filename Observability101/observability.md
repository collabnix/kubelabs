# Kubernetes cluster observability

In this section, we will look at several tools that can help improve your cluster administration and observability. This won't cover monitoring tools like Prometheus and Grafana, which are tools used to read metrics from, but rather tools that allow you to perform actions on your clusters such as [KubeSphere](../KubeSphere/what-is-kubesphere.md). Since we've already discussed in detail about KubeSphere, which is a rather heavy-weight application that has all sorts of features, let's take a look at more light-weight alternatives that focus largely on converting your various kubectl commands to UI-based interface options.

## Lens

Let's start with one of the most popular cluster observability tools: Kube Lens. This is a desktop tool that can be used to perform pretty much anything you would do with the kubectl command line and is very stable and feature-rich. If you are a DevOps engineer working with Kubernetes clusters, Lens is a must. There are two versions of Lens: the one maintained by Mirantis (https://k8slens.dev) and the Open Lens maintained by the community. They both largely have the same features and provide an excellent way to access your cluster without using a host of kubectl commands.

### Setup

Since Lens is a desktop tool, the setup is fairly simple - assuming you already have the cluster accessible via kubectl. If this is the case, all you have to do is install the desktop application, and your cluster should be in the catalog section of Lens. Once you connect to the cluster, you will be shown a list of resources, all relating to your Kubernetes cluster. This will include workloads (such as pods, and jobs), resources such as nodes, networking objects such as services and ingresses, etc... You should also be able to easily edit each of these resources using the inbuilt editor, as well as exec into pods, nodes, and other resources. You can also select custom resources that are created by CRDs.