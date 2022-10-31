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

The next is `create`. `kubectl create` is a powerful command that can be used to create all sorts of resources inside a cluster. It can also be used in combination with the above flags to perform various operations. The opposite command is `kubectl delete`, which gets rid of created resources.

An important part of running Kubernetes is getting detailed information about resources that are running. For that, we use `kubectl describe`. This command can be used to describe details of various resources and provide you a lot of insights about the status of your resources when used with the above flags.

## Kubernetes resources

Now that the flags and actions have been discussed, let's move on to the resources. There are all sorts of resources in kubectl and it wouldn't make sense to remember most of those. Instead, let's start with the short forms you can use to refer most common resources.

The main component of Kubernetes is its pods who have `po` as shorthand. You can use this for pods and use it with actions and flags listed above, such as:

```
kubectl get po -A
```

Use the above command with the -o flag to get detailed information about the pods:

```
kubectl get pods -o wide
```

Next is namespaces, which has the shorthand `ns`.

If you have multiple namespaces, you can use:

```
kubectl get ns
```

to list them all out. Then comes the services, which has a shorthand `svc`

```
kubectl get svc
```

Other common resources you can use `get` on are `pv`, `configmap`, `secret`, `node`, `event`, as so on.

Deployments are commonly used to deploy multiple pods in a single "deployment". The shorthand for this is `deploy`. A couple of other shorthand resources are `pv` for persistent volumes and `pvc` for persistent volume claims ([more info](../StatefulSets101/README.md)).

You could use many different combinations of the resources, actions, and flags above to do all sorts of things, and covers a large number of the commands you would use in your day-to-day life with Kubernetes. Now, we will combine everything we looked at above and talk about some commonly used commands.

## Configuration

Before you start using kubectl, you need to make sure you are using the correct kubeconfig that points to the cluster that you will be dealing with, as well as the correct context.

```
kubectl config view
```

The above command returns information about the config you are using. Remember that you can use the flags we discussed in here, such as the `-o` flag. For example, a command such as:

```
kubectl config view -o jsonpath='{.users[*].name}'
```

will get you the list of all users in the config.

Setting the config is to be done by setting the `KUBECONFIG` variable. You can set multiple kuebconfigs:

```
KUBECONFIG=~/.kube/config:~/.kube/kubconfig2
```

Then you can switch between contexts;

```
kubectl config use-context my-cluster-name   
```

Before you switch between the contexts, you will need to get all the contexts to see which options you have, which can be done with:

```
kubectl config get-contexts
```

## Resources application

We discussed the `kubectl apply` action before. Since applying resources is something that you will have to do regularly, let's look into it in more detail.

You saw the syntax for applying a single file above. In the same way, you can apply all the files in a directory by specifying the directory instead of the file:

```
kubectl apply -f <dir>
```

You could also select specific files and apply them by chaining the `-f` flag:

```
kubectl apply -f <file1> -f <file2>
```

You can also substitute the files on your local drive to files online by sending the url instead of the file:

```
kubectl apply -f https://git.io/vPieo 
```

## Resource creation

Now let's go to resource creation. `create` can be used to create new resources and is similar to `apply`, in the sense that you can create resources from a file. However, unlike `apply`, it will throw an error if the resource already exists, meaning that creating resources from files is best left to `apply`. `create` has a different usage, which is that it allows the creation of resources on the CLI itself instead of having the resource defined in a file. For example:

```
kubectl create job hello --image=busybox:1.28 -- echo "Hello World"
```

The above command will create a job called hello with the specified image, all without having to create a separate yaml for it.

## Resource update

Now that we know how to create resources, let's take a look at the `rollout` action which allows you to change the resources you created. You can use the `history` keyword:

```
kubectl rollout history deployment/frontend
```

Which will give you the history and revision of the deployment. You can change back to the last revision with:

```
kubectl rollout undo deployment/frontend         
```

Or you can append the revision number at the end of the command to specify which version you should roll back to with `--to-revision=2`. Once a rollout is underway, you can use the `status` keyword to monitor the status of the deployment, and use `restart` to restart it. The important thing to note is that `rollout` handles whatever task it has been assigned smoothly, and ensures that there are no service outages by performing the action in a controlled manner. However, if you wanted to do an abrupt change and don't mind a service outage, you can consider using the `replace` keyword, which deletes and recreates the resource:

```
kubectl replace --force -f ./pod.json
```

You can also set deployments to autoscale while they are currently deployed:

```
kubectl autoscale deployment foo --min=2 --max=10 
```

Another part of updating resources is patching them, which is accomplished via the `kubectl patch` command. Note that this command can be used with the previously mentioned resources and flags as well. We will start by taking a look at the commonly used `patch` commands.