# Autoscaling helpers

We have now discussed HPA's, VPA's, and you might have even read the section on [KEDA](../Keda101/what-is-keda.md) to learn about advanced scaling. Now that you know all there is to about scaling, let's take a step back and look at a few important things to consider when it comes to scaling. In this section, we will discuss:

- Readiness/liveness/startup probes
- Graceful shutdowns
- Annotations that help with scaling.
- Pod priority/disruption

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

Another annotation that helps with autoscaling is the `autoscaling.alpha.kubernetes.io/metrics` annotation which allows you to specify custom metrics for autoscaling, like so:

```yaml
metadata:
  annotations:
    autoscaling.alpha.kubernetes.io/metrics: '[{"type": "Resource", "resource": {"name": "cpu", "targetAverageUtilization": 80}}]'
```

Now that we have looked at annotations, let's look at how pod priority and disruptions budgets can help you with scaling.

**Pod Priority**:

You can influence the Cluster Autoscaler by specifying pod priority, and ensuring critical pods get scheduled first.

 ```yaml
  spec:
    priorityClassName: high-priority
 ```

If you have an application that handles all incoming traffic and then routes it to a second application, you would want the pods of the external-facing application that handles traffic to have more priority when scheduling. If you have jobs that run batch workloads, they might take lesser priority compared to pods that handle your active users.

Earlier, we discussed using annotations to prevent disruptions due to scaling. However, those methods were somewhat extreme, making the node stay up even if 1 pod was running or making sure the node never went down at all. What if we wanted to allow scaling but also wanted to maintain some control over how much this scaling was allowed to disrupt our workloads? This is where pod disruption budgets come into play.

**Pod Disruption Budget (PDB)**:

A Pod Disruption Budget (PDB) is a Kubernetes resource that ensures a minimum number of pods are always available during voluntary disruptions, such as maintenance or cluster upgrades. It prevents too many pods of a critical application from being taken down simultaneously, thus maintaining the application's availability and reliability.

Let's say you have a Kubernetes Deployment with 5 replicas of a critical web service. You want to ensure that at least 3 replicas are always available during maintenance activities. You can create a PDB with the following YAML configuration:

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: web-service-pdb
spec:
  minAvailable: 3
  selector:
    matchLabels:
      app: web-service
```

This is not very different to how other Kubernetes resources work where the external resource applies its configuration by selecting the deployment with a label. The components of the above PodDisruptionBudget are as follows:

- `apiVersion: policy/v1`: Specifies the API version.
- `kind: PodDisruptionBudget`: Indicates that this resource is a PDB.
- `name: web-service-pdb`: The name of the PDB.
- `minAvailable: 3`: Specifies that at least 3 pods must be available at all times.
- `selector`: Defines the set of pods the PDB applies to. In this case, it matches pods with the label `app: web-service`.

### How it Works

1. **Normal Operation**:
   - Under normal conditions, all 5 replicas of the web service are running.

2. **During Disruption**:
   - When a voluntary disruption occurs (e.g., node maintenance or a manual pod eviction), the PDB ensures that at least 3 out of the 5 pods remain running.
   - If an attempt is made to evict more than 2 pods at the same time, the eviction will be blocked until the number of available pods is at least 3.

Now that we're clear on disruption budgets, let's look at node affinities.

**Node Affinity**:

Node affinity rules influence where pods are scheduled, indirectly affecting autoscaling decisions.

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

Ensuring that nodes & pods are started in different zones will ensure high availability when a zone goes down. This also brings us to an important point if you run a large application with many microservices. Each replica of each microservice requires its own IP, and in a normal subnet, you only have 250 of them. Considering that each node you bring up has several daemonsets running on them that reserve their own IPs, coupled with each microservice replica needing its own IP, you might quickly find yourself in a position where you have run out of IPs and the pod is unable to start because the CNI doesn't have any IPs left to assign. In this case, having several subnets spread evenly across several availability zones is the answer. But even then, it is possible that the cluster autoscaler (or Karpenter if you use that instead), will end up provisioning nodes in a subnet that is about to run out of IPs. So having zonal topology constraints at a pod level will ensure that the pods are spread out and demand that nodes be spread across the subnets, thereby reducing the chance of IP address exhaustion.

This is the very start of looking into possible problems you could run into while scaling. Depending on how much you scale and what you scale with, you might run into all manner of unpredictable issues. If you were to take an application designed to run on a static machine, and then scale it as-is, the problems would become apparent to you. So if you are planning to scale your production workloads, make sure you have proper monitoring and logging in place. For more on this, take a look at how you can [run filebeat as a sidecar](../Logging101/filebeat-sidecar.md) so that even if you were to scale your applications to hundreds of replicas, you would still have perfect logging over each of them. This is pretty crucial because at one point, sifting through log files is no longer an option. There would be so many that you would probably have trouble finding one among the thousands.