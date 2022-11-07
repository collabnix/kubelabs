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

As you know, resources are written in yaml. This means that the behaviour of these resources can be changed by manipulating the yaml, even if the resource in question is actively running. This is what the `patch` command does. For example, you can update a node by changing its `spec` like so:

```
kubectl patch node k8s-node-1 -p '{"spec":{"unschedulable":true}}'
```

You can do the same with pods by changing their `spec`. In the below case, we are patching out the image with another one:

```
kubectl patch pod valid-pod --type='json' -p='[{"op": "replace", "path": "/spec/containers/0/image", "value":"new image"}]'
```

You could also use patch with other resources such as service accounts and deployments:

```
kubectl patch deployment nginx-deployment --subresource='scale' --type='merge' -p '{"spec":{"replicas":2}}'
```

## Changing running resources

But you don't always have to patch the `spec` of deployment to do something as common as scaling the number of replicas of a resource. For that, you have `scale`:

```
kubectl scale --replicas=3 -f foo.yaml 
```

Note that you can specify resources using the file flag, or the resources themselves directly. Changing resources isn't the only thing that you can do while the pods are running because extracting logs from them is another significant part of maintaining your Kubernetes cluster.

The simple syntax for getting logs from a pod is:

```
kubectl logs <pod-name>
```

If you have grouped together your pods using labels, you might want to output the logs of all these pods together using:

```
kubectl logs -l name=<pod label>
```

If you are using init containers, you might be interested in getting the logs from these containers, which you can do with the `-c` flag:

```
kubectl logs <pod> -c <container>
```

In addition to logging, you can also get metrics for the pods:

```
kubectl top pod <pod name> --sort-by=cpu
```

Pods aren't the only things you can get logs for. You can use the same syntax to get logs for deployments:

```
kubectl logs deploy/my-deployment
```

As well as execute commands in running pods, using the `exec` keyword.

```
kubectl exec <pod> -- ls / 
```

In the above case, the command `ls /` is run and would show the content of the root directory of the pod. You can use this method to gain interactive access to the pod as well, using:

```
kubectl exec --stdin --tty <pod> -- /bin/sh
```

You can also copy files that are on your local drive to your running pods using `cp`:

``` 
kubectl cp /path/to/dir my-pod:/path/to/dir
```

Note that you can also copy files and directories to pod containers using the `-c` flag as we did above. You could also specify exactly which pod you need to copy your files into by specifying the namespace:

```
kubectl cp /tmp/foo my-namespace/my-pod:/tmp/bar    
```

You can also copy backward, from the pod into your file system:

```
kubectl cp my-namespace/my-pod:/tmp/foo /tmp/bar
```

## Managing nodes and clusters

If you casually use Kubernetes to maintain your cluster, then you most likely have not used commands that managed nodes and clusters. There are a couple of these commands such as `cordon` and `drain` that can be used here, and we will look into the use cases.

If you want to ensure that a node doesn't get any resources running on it for any reason, you can use the `cordon` keyword. This keyword will make the node unschedulable:

```
kubectl cordon my-node
```

To allow scheduling, use `uncordon`:

```
kubectl uncordon my-node 
```

If you wanted to get rid of a node, you can use:

```
kubectl drain my-node 
```

To safely drain a node before deletion. If you are planning on using this command, make sure you also read the official Kubernetes guide on [safely draining a pod](https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/).

You can also use the `top` command to get the metrics of a node in the same way you used it to get the metrics of a pod. [Taints and tolerations](../Scheduler101/README.md) which allow you to decide which nodes a pod should be scheduled on can be done with:

```
kubectl taint nodes foo
```

Moving on to clusters, you can use `kubectl cluster-info` to get the addresses of the services on a cluster. You can use the `dump` keyword (`kubectl cluster-info dump`) to print out the current state of the cluster to the CLI.

## Output formatting

Before we finish the section on practical Kubernetes, let's look at the ways we can format the output of commands so that they are more human-readable. We already touched on the `-o` flag which is used to signify that we are going to change the way the output is formatted, and we have also briefly discussed a couple of ways we can do this formatting. Since almost all commands that have output can be formatted in this manner, knowing the core concepts of how output formatting works will allow you to use kubectl like a pro. So let's dive deeper into this topic.

### Custom columns

It's well known that tables are one of the best ways to represent data. This is why the `custom-columns` keyword which allows the `-o` flag to format the output into a table that is easy to read. If you were to dump all the data you get from the output into a table, the table would be confusing and unintuitive. This is why the command is called `custom-columns`, meaning that you specify which parts of the data need to be visualized as a column.

Let's imagine that we want to display some information about a couple of pods. In this case, let's get information such as the name and the pod version. To do this we will use a combination of the actions and flag from before, as well as the `custom-columns` action:

```
kubectl get pods <pod-name> -o custom-columns=NAME:.metadata.name,RSRC:.metadata.resourceVersion
```

This will create a table with 2 columns. Name, and RSRC. The values will be displayed accordingly. However, you might notice that this has made the command quite long. If you wanted to get a whole bunch of values, your command would end up being unreadably long, very difficult to understand, and problematic if you needed to fix something with the command. In that case, you can move this string to a file and reference this file from the command. You could declare a `template.txt` file:

```
NAME          RSRC
metadata.name metadata.resourceVersion
```

and send this file to the command:

```
kubectl get pods <pod-name> -o custom-columns-file=template.txt
```

This isn't something limited to `custom-column`. You can also use the template on commands such as `-o=jsonpath-file=<filename>`, which is an extension to the `-o=json` flag we looked at earlier.

One final output format you can keep in mind is `-o=yaml`, which formats the output to resemble yaml.

Next, let's look at another extension to `-o`, which is `-v`. `-v` is used to specify verboseness in the output. The level of verboseness is identified based on an incrementing number starting from 0 and going up to 9, with 0 giving the lowest level of output and 9 giving the most. A list of what each verboseness level shows can be found in the [official documentation](https://kubernetes.io/docs/reference/kubectl/cheatsheet/#kubectl-output-verbosity-and-debugging).

## Conclusion

This brings us to the end of the guide to practical Kubernetes. The flags, actions, and resources you learned here can be used in everyday situation where you have to interact with Kubernetes clusters. There are many more commands and actions that advanced users of Kubernetes will have to use, but this guide is sufficient for anyone looking to jump into Kubernetes and use the kubectl command line like a pro.