# Rollouts

A rollout is likely something you are already very familiar with when you deploy a new application version. One way of doing this is to force delete the old application version and create a new one. This has some obvious downsides such as application downtime. However, if you have peak/off-peak times this might not be as big an issue and will help with faster deployments. However, if you need to perform deployments during peak times, you will get a service degradation.

This is why you need rolling deployments. To learn more about default rolling deployments, head over to the [Blue-green strategies](../Deployment101/Blue-Green-Strategies.md) section. In short, Kubernetes will always perform blue-green deployment when you deploy new modules since it adds the following block to every deployment yaml:

spec:
 strategy:
 type: RollingUpdate
 rollingUpdate:
 maxSurge: 25%
 maxUnavailable: 25%
```