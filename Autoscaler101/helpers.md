# Autoscaling helpers

We have now discussed HPA's, VPA's, and you might have even read the section on [KEDA](../Keda101/what-is-keda.md) to learn about advanced scaling. Now that you know all there is to about scaling, let's take a step back and look at a few important things to consider when it comes to scaling. In this section, we will discuss:

- Readiness/liveness/startup probes
- Graceful shutdowns
- Annotations that help with scaling.

You may have already come across these concepts before, and just about every Kubernetes-based tool uses them to ensure stability. We will discuss each of the above points and follow up with a lab where we test out the above concepts using a simple Nginx server.

# Probes

What are readiness/liveness/startup probes and why are they useful for autoscaling? Let's break down each type of probe.

- Readiness probe: As the name suggests, this probe checks to ensure that your container is ready.

In order to do this, you could implement several methods. The simplest and most frequently used is the http get method. You simply point the readiness probe at your containers' endpoint, then have the probe ping it. If the response to the ping is 200 OK, your pod is ready to start receiving traffic. This is incredibly useful since it's rare that your application is ready to go immediately after starting up. Usually, the application needs to establish connections with databases, contact other microservices to get some starting information, or even run entire startup scripts to prepare the application. So it may take a couple of seconds to a couple of minutes for your application to be ready to take traffic. If any requests come in within this period, they will be dropped. With the readiness probe, you can be assured that this won't happen.

Apart from a simple HTTP get requests, you could also run TCP commands to see if ports are up, or even run a whole bash script that executes all commands to determine whether your pod is ready. However, this probe only continually checks to see if your app is ready to take requests. It blocks off any traffic if it starts to notice that the probe is failing. If you only have a readiness probe in place, even if your app has gone into an error state, Kubernetes will only prevent traffic from entering that pod until the probe starts to pass. It will not restart the failed application for you. This is where liveness probes come in.

- Liveness probe: Check if your application is alive.

A liveness and readiness probe do almost the same thing, except a liveness probe restarts the pod if it starts failing, unlike the readiness probe which only stops traffic to the pod until the probe starts succeeding. This means that the liveness probe should come after the readiness probe. You could say something like: if my container's port 8080 isn't being reached, stop sending traffic (readiness probe). If it is still unreachable after 1 minute, fail the liveness probe and restart the pod since the container has likely crashed, gone OOM, or is meeting some other pod or node constraints.

- Startup probe: A probe similar to the other two, but only runs on startup.

If your pod takes a while to initialize, it's best to use startup probes. Startup probes ensure that your pod started correctly. You can even use the same endpoint as the liveness probe but with a less strict wait time. When your pod is already running, you don't expect the endpoint to go down for more than a few seconds if at all. However, when starting up, you can expect it to be down until your application finishes initializing. This is why there is a separate startup probe instead of re-using the existing liveness probe.

So how do these probes help with autoscaling? In the case where replicas of pods increase and decrease meaning that instances of your application are provisioned and de-provisioned, you need to make sure there is no downtime. This is where all the above probes come into play. When the load into your application increases and replicas of your pods show up, you don't want any traffic served until they are ready. If they have issues getting prepared and don't start after a while, you want them to restart and try to auto-recover. Finally, if a pod fails after running for a while, you want traffic to be blocked off and that pod restarted. This is why these probes are necessary for autoscaling.

## Graceful shutdowns

Now let's take a look at graceful shutdowns. If you were running a website that had high traffic and your pods scaled up during high traffic, they must scale back down after a while to make sure that your infrastructure costs are kept as efficient as possible. However, if your Kubernetes configuration was to immediately kill the pod off while the traffic was being served, that might result in a few requests being dropped. This is where graceful shutdowns are needed.

Depending on the type of web application you are running, you may not need to configure graceful shutdowns from the Kubernetes configuration. Instead, the application framework itself might be able to intercept the shutdown signal Kubernetes sends and automatically prevent the application from receiving any new traffic. For example, in SpringBoot, you can enable graceful shutdowns simply by adding the config `server.shutdown=graceful` into your application config. However, if your application framework doesn't support something like this, or you prefer to keep your Kubernetes and application configurations separate, you might consider creating a `shutdown` endpoint. We will do this during the lab.

While microservices generally take in traffic through their endpoints, your application might differ. Your application might do batch processing by reading messages off RabbitMQ, or it might occasionally read a database and transform the data within it. In cases like this, having the pod or job terminated for scaling considerations might leave your database table in an unstable state, or it might mean that the message your pod was processing never ends up finishing. In any of these cases, graceful shutdowns can keep the pod from terminating long enough for your pod to either finish what it started or ensure a different pod can pick up where it left off.

If the jobs you are running are mission-critical, and each of your jobs must run to completion, then even graceful shutdowns might not be enough. In this case, you can turn to annotations to help you out.

## Annotations

Annotations are a very powerful tool that you can use in your Kubernetes environments to fine-tune various aspects of how Kubernetes works. If, as mentioned above, you need to make sure that your critical job  runs to completion regardless of the node cost, then you might want to make sure that the node that is running your job does not de-provision while the job is still running on it. You can do this by adding the below annotation:

```
annotations:
 "cluster-autoscaler.kubernetes.io/safe-to-evict": "false"
```

This will ensure that your node stays up even if there is only 1 job running on it. This will certainly increase the cost of your infrastructure since normally, Kubernetes would relocate jobs and de-provision nodes to increase resource efficiency. It will only shut down the node once no jobs are running that have this annotation left. However, if you don't want the nodes to shut at all, you can add a different annotation that ensures that your nodes never scale down:

```
cluster-autoscaler.kubernetes.io/scale-down-disabled
```

This annotation should be applied directly to a node like so:

```
kubectl annotate node my-node cluster-autoscaler.kubernetes.io/scale-down-disabled=true
```

Obviously, this is not a recommended option unless you have no other choice regarding the severity of your application. Ideally, your jobs should be able to handle shutdowns gracefully, and any jobs that start in place of the old ones should be able to complete what the previous job was doing.

Another annotation that help with autoscaling is the `autoscaling.alpha.kubernetes.io/metrics` annotation which allows you to specify custom metrics for autoscaling, like so:

```yaml
metadata:
  annotations:
    autoscaling.alpha.kubernetes.io/metrics: '[{"type": "Resource", "resource": {"name": "cpu", "targetAverageUtilization": 80}}]'
```

### Cluster Autoscaler

1. **Pod Priority**:
   - Influence the Cluster Autoscaler by specifying pod priority, ensuring critical pods get scheduled first.
     ```yaml
     spec:
       priorityClassName: high-priority
     ```

2. **Pod Disruption Budget (PDB)**:
   - Define a PDB to control the number of pods that can be disrupted during scaling activities.
     ```yaml
     apiVersion: policy/v1
     kind: PodDisruptionBudget
     metadata:
       name: myapp-pdb
     spec:
       minAvailable: 80%
       selector:
         matchLabels:
           app: myapp
     ```

3. **Autoscaler Behavior**:
   - Use annotations to modify the behavior of the Cluster Autoscaler for specific node groups.
     ```yaml
     metadata:
       annotations:
         cluster-autoscaler.kubernetes.io/safe-to-evict: "false"
     ```

4. **Scale-down Disabled**:
   - Prevent the Cluster Autoscaler from scaling down specific nodes or node groups.
     ```yaml
     metadata:
       annotations:
         cluster-autoscaler.kubernetes.io/scale-down-disabled: "true"
     ```

### Node Autoscaling

1. **Taints and Tolerations**:
   - Use taints and tolerations to influence scheduling and scaling behaviors, ensuring only appropriate pods are scheduled on specific nodes.
     ```yaml
     spec:
       taints:
       - key: dedicated
         value: myapp
         effect: NoSchedule
     ```

2. **Node Affinity**:
   - Define node affinity rules to influence where pods are scheduled, which indirectly affects autoscaling decisions.
     ```yaml
     spec:
       affinity:
         nodeAffinity:
           requiredDuringSchedulingIgnoredDuringExecution:
             nodeSelectorTerms:
             - matchExpressions:
               - key: kubernetes.io/e2e-az-name
                 operator: In
                 values:
                 - e2e-az1
                 - e2e-az2
     ```

3. **Karpenter Specific Annotations**:
   - For users of Karpenter, specific annotations can control aspects of autoscaling behavior.
     ```yaml
     metadata:
       annotations:
         karpenter.sh/capacity-type: "spot"
         karpenter.sh/instance-profile: "my-instance-profile"
     ```

These annotations and configurations can significantly impact the autoscaling behavior of your Kubernetes cluster, allowing for more fine-grained control over resource allocation and scaling policies.