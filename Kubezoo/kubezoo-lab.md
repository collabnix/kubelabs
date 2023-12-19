# Kubezoo Lab

Now that we have covered what Kubezoo is, let's take a look at how we can set it up in a standard cluster. You could go ahead and use [Minikube](https://minikube.sigs.k8s.io/docs/start/), or you could create a cluster using [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation). You can also use any Kubernetes cluster you have at the ready. Let's start by cloning the [KubeZoo repo](https://github.com/kubewharf/kubezoo.git):

```
git clone https://github.com/kubewharf/kubezoo.git
```

Now, go to the root of the repo you just cloned, and run the `make` command:

```
make local-up
```

This will get Kubezoo up and running on port 6443 as long as the port is free. Check to see if the API resources are up and running:

```
kubectl api-resources --context zoo
```