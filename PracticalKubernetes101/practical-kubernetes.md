# Practical Kubernetes

We now know quite a bit about Kubernetes and other related technologies. So let's start focusing on the more practical aspects of using Kubernetes on a day-to-day basis as a DevOps engineer. Before we start, it's essential to know where you can get answers if you get stuck, and the best place for that is the [Kubernetes documentation](https://kubernetes.io/docs/home/). However, you may want to keep a couple of kubectl commands memorized since you would use them frequently, and that is what we would touch on first.

## Useful kubectl flags

kubectl uses flags that apply to many different types of resources, and mastering them will allow you to easily use them with other Kubernetes commands. A full list of flags can be found in the [official documentation](https://kubernetes.io/docs/reference/kubectl/kubectl/). Let's take a look at some of the most used ones here:

```
-A
```

`-A` stands for "all namespaces" (`--all-namespaces`) and is used to look for resources across all namespaces. So, commands such as 

```
kubectl get po -A
```

will return the pods across all namespaces.

```
-f
```

This is used to specify a file. A command such as

```
kubectl apply -f <file_path>
```

will apply the resources in the file provided in the path.

```
-n
```

This is used to specify the namespace, and is short for `--namespace`.

```
-o
```

shorthand for `--output`, which formats the output displayed. `-o wide` is a common notation used to display additional details. So if you wanted the output to be in JSON format, use

```
kubectl ... -o json
```

```
--all
```

This signifies all the resources. So something like:

```
kubectl -n my-ns delete pod,svc --all
```

Will delete all pods and services in the `my-ns` namespace.

```
-ti
```

Users of Docker might be familiar with the above command, as it lets you log into pods using `kubectl exec`:

```
kubectl exec -ti [pod-name] -- /bin/bash
```

The above flags should cover a good percentage of the flags you will use in day-to-day Kubernetes. Now, let's move on to the Kubernetes resources.

## Kubernetes actions

There are a couple of common keywords that act as commands when used with kubectl. One of the most common is `get`. You can use `kubectl get` to retrieve anything from pods to namespaces to the very nodes the cluster is running on. We discussed the `-o wide` flag previously, and you can use this flag in conjunction with the `get` command to output more information from whatever you are getting.

The next is `create`. `kubectl create` is a powerful command that can be used to create all sorts of resources inside a cluster. It can also be used in combination with the above flags to perform various operations.

An important part of running Kubernetes is getting detailed information about resources that are running. For that, we use `kubectl describe`. This command can be used to describe details of various resources and provide you a lot of insights about the status of your resources when used with the above flags.

## Kubernetes resources

The main component of Kubernetes is its pods, so let's start by taking a look at the pod commands. Note that you can use `po` as shorthand:

```
kubectl get po -A
```

Use the above command with the -o flag to get detailed information about the pods:

```
kubectl get pods -o wide
```

If you have multiple namespaces, you can use:

```
kubectl get namespaces
```

to list them all out.

```
kubectl get services
```

You could use 