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