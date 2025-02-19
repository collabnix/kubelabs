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