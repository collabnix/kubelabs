# Scaling Options

As we already know, there are two types of scaled resources that KEDA provides: ScaledJobs and ScaledObjects. Each of them has different configurations and thereby different scaling options. Let's start with the scaling options available to ScaledJobs.

## ScaledJobs options

We already know the mandatory job options that KEDA provides so we will skip over all of those and get to the specialized options that are rarely talked about. First is the job rollout strategy:

```yaml
rollout:
  strategy: gradual
  propagationPolicy: foreground 
```

You generally don't want to interrupt jobs while they are running. So if you wanted to deploy a new version of the Scaled job, you would likely have to wait for a time window where the old jobs are over before deploying the new version. However, when using the `gradual` rollout strategy, whenever a ScaledJob is being updated, KEDA will not delete existing Jobs. Only new Jobs will be created with the latest job definition.

Next, let's look at scaling strategies. We used the `multipleScalersCalculation` strategy in the previous section, so we'll look at the others here. The default scaling strategy works well enough and uses: `maxScale - runningJobCount` to decide how many jobs to start up. 

Another scaling strategy is the `accurate` strategy specially designed for queue-based scaling, which follows a `maxReplicaCount - runningJobCount` method. The main goal is to address limitations in the existing queue-based scaling by considering unlocked messages instead of total queue length. The new approach ensures jobs are accurately created based on real-time demand while respecting maxReplicaCount. This improvement helps avoid unnecessary job scaling and aligns job execution with actual workload needs. So in our previous example with SQS, we would benefit from using `accurate` scaling. The default approach scales based on total messages in the queue, which may not reflect real-time processing needs. The `accurate` strategy focuses on unlocked (pending) messages, leading to more precise scaling by reducing over-provisioning and ensuring jobs match actual workload demand. If your SQS messages have varying processing times or concurrency limits, this improvement can help avoid excessive job creation while maintaining efficiency. 

The final scaling strategy is `eager`, which utilizes all available slots up to the maxReplicaCount, ensuring that waiting messages are processed as quickly as possible. This is an over-provisioning scenario, and it might be better to avoid using this option unless you need to process your jobs incredibly fast.

Next, let's look at annotations. An inbuilt scaler for scaled jobs is autoscaling.keda.sh/paused: true. If you patch your existing scaled jobs with this annotation, scaling will be paused. Any annotation you place in the annotations section of the scaled job will be present in any jobs created by the scaled job resource.

Next, let's look at the options available for scaled ScaledObjects

## ScaledObjects options

As before, let's skip the common options that we all use and look at the specialized ones. The first is `idleReplicaCount` which is the count used when scaling is not active. By default, the count will normally fall to the minimum replica count, but if you want the idle count to be higher, you can use this.

Next, let's look at the `fallback` option. This is the number of replicas that must be active if the scaler is in an error state. For example, let's assume that due to a permission issue, our sample scaler can no longer reach SQS. Therefore it has no idea how many replicas it should scale up to. In this situation, it would go down to the minimum replica value, but that is not a good idea if you are in a high-traffic situation. In this case, you can define the fallback:

```yaml
  fallback:                                          
    failureThreshold: 3                              
    replicas: 6  
```

The threshold will be the number of times SQS is unreachable. In this case, if KEDA can't reach SQS, it will try 3 times after which the number of replicas will be scaled to 6. This is useful if you have a very important application that needs to handle scaler-level failures.

Let's also look at the various annotations available for the KEDA-scaled objects:

```yaml
annotations:
    scaledobject.keda.sh/transfer-hpa-ownership: "true"
    validations.keda.sh/hpa-ownership: "true"          
    autoscaling.keda.sh/paused: "true"                 
```

`scaledobject.keda.sh/transfer-hpa-ownership`: If you already have an HPA at work, you can use this to transfer ownership of scaling to this scaled object. `validations.keda.sh/hpa-ownership` disables HPA ownership validation. The final annotation `autoscaling.keda.sh/paused` does the same jobs as it does for scaled jobs, where it pauses the autoscaling.

Finally, look at the `advanced` section of the scaled job configuration. For example:

```yaml
  advanced:                                               
    restoreToOriginalReplicaCount: true/false               
    horizontalPodAutoscalerConfig:                          
      name: {name-of-hpa-resource}                          
      behavior:
        scaleDown:
          stabilizationWindowSeconds: 300
          policies:
          - type: Percent
            value: 100
            periodSeconds: 15
          - type: Pods
            value: 4
            periodSeconds: 60
```

Starting with `restoreToOriginalReplicaCount`, when a ScaledObject is deleted, the replica count has been maintained at whatever value it was at the time of deletion. If this is set to true, the replica count is decreased to the original replica count.

`horizontalPodAutoscalerConfig`: Under the hood, KEDA uses HPAs to handle scaling, and with Kubernetes v1.18, the scaling behavior can be fine-tuned at a deeper level. KEDA allows us to do this from the Scaled Object definition itself. Here, the `name` section is where you specify the name of the HPA created by keda. By default, it is `keda-hpa-{scaled-object-name}`. The `behavior` section is where the scaling behavior is defined and this is actually a direct copy of the configuration given by the [Kubernetes API](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#configurable-scaling-behavior). Not something that is provided by KEDA.

`scaleDown` (or `scaleUp`) is where you define the policies for scaling up or down. You could also choose to use both options to control both scaling up and scaling down. In the above example, we have `stabilizationWindowSeconds` which is somewhat similar to the cooldown period in KEDA, where the number of pods is maintained if the scaling metric fluctuates a lot to prevent unnecessary pod starts and stops. After this, we have the `policies` section where you describe the specifics of the scale-down policy. We use percent here and 100% here means that the application can be scaled down to the minimum replica count (not 0), for 15 seconds. This doesn't mean that the replicas will scale down within 15 seconds, just that the policy will be active for 15 seconds.

You could also use pods instead of percent to specify the type to scale down. This way it will scale down the exact number of pods instead of the percentage of pods. Useful if you have a fixed number of replicas in mind. Next, let's look at `scaleup`:

```yaml
  scaleUp:
    stabilizationWindowSeconds: 0
    policies:
    - type: Percent
      value: 100
      periodSeconds: 15
    - type: Pods
      value: 4
      periodSeconds: 15
    selectPolicy: Max
```

As you can see, it is the same as `scaledown`. Let's take a look at a new attribute added here, `selectPolicy`. This can be either Min, Max, or disabled. Setting `selectPolicy` to Min means that the autoscaler chooses the policy that affects the smallest number of Pods, while Max does the opposite. Setting it to disabled turns off scaling in the given direction. So, in this case, if we set it to disabled, it will disable scaling up completely.

This is the full range of options provided by the `advanced` section of the KEDA scaler. To get more info about the advacned options available for kubernetes autoscalers, [check the docs](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/).

## Conclusion

This brings us to the end of the scaling options provided by both scaled jobs and scaled objects. These options cover native Kubernetes options that KEDA extends as well as custom options provided by KEDA itself. For more info on these scaling options, check out the KEDA official docs for [scaled objects](https://keda.sh/docs/2.16/reference/scaledobject-spec/) and [scaled jobs](https://keda.sh/docs/2.16/reference/scaledjob-spec/).