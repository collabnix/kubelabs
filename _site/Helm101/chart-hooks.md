# Chart hooks

Chart hooks allow you to have flexibility over what happen during the various stages of a release lifecycle.

### What is a release lifecycle?

A Helm release refers to a single instance of a chart that is applied on a cluster. So it follows that a release lifecycle is the lifecycle of this instance. This includes the installation, upgrade, deletion, etc... of charts, and chart hooks allow you to do various things in these stages.

### What kind of things?

A 'hook' would have a resource delcared in it. For instance, if the resource is a pod, then this pod will spin up at the specified time. If it is a job, then the job will run.

### What are hook weights?

If you want to run 2 (or more) hooks, then there should be a way for you to specify which hook should run when. You could have a hook that builds on work done by a previous hook, and it wouldn't work well if hooks started executing randomly. This is what hook weights are for. By specifying a number (as a string in the actual yaml). If you were to set a hook with weight -5, that would run before a hook with a weight of -4.

### Chart hook examples

A full list of possible chart hooks can be found in the Helm [official documentation](https://helm.sh/docs/topics/charts_hooks/#the-available-hooks). In this case, we can consider the process of what happens when a Helm chart is installed. Helm has two possible hooks for use in this case, ```pre-install``` and ```post-install```. Pre-install executes after any templates are rendered and before any resources are loaded into Kubernetes. Post-install runs after everything is in place.

If you were to use a pre-install hook, the normal install process would go on until the templates are rendered. At that point, Helm starts loading your hooks and waits until they are ready before loading resourecs into Kubernetes. Going back to our example where the hook has a pod declared in it, the pod will spin up at this point, run to completion, and then finish.

If a post-install hook was also in place, this would come into effect after resoureces have finished loading. The post-install hooks would run and Helm would wait until these hooks are ready before continuing. Something you should note is that Helm expect the process declared in the hook to finish, and will halt everything until that point is reached. If there is an error here, the operation will fail.

## Creating a hook

Ok, you now know what a hook is and what it does. So how do you write one? The most important thing to note here is that a chart hook is a template file. If you know how to create Helm templates, then you're well on your way to creating chart hooks. Since each hook run a Kubernetes resource to completion (such as a job or a pod), you will essentially be defining a Kubernetes resource as a hook. So you can go ahead and take some simple yaml that spins up a pod, then add a couple of lines to make it a hook. 

These lines should be added under the **annotations** section of the yaml and should include the point at which the hook should jump in, the weight of a hook, and the delete policy for that hook. As you may notice from the example below, a single resource can have multiple hooks. This applies to hook deletion policies.

```yaml
...
annotations:
    # This is what defines this resource as a hook. Without this line, the
    # job is considered part of the release.
    "helm.sh/hook": post-install,post-upgrade
    "helm.sh/hook-weight": "-5"
    "helm.sh/hook-delete-policy": hook-succeeded
...
```

Next, let's move to chart testing.

[Next: Chart Testing](test-charts.md)