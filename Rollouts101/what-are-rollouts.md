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

This means that during deployment of 4 replicas, you allow the cluster to have 1 extra pod during deployment (5 replicas) and also allow the cluster to make 1 replica unavailable for the sake of deployment. This means that there will always be 3 replicas running until the deployment is finished. By adding this block to your deployment yaml you can override this default behavior. This is the most efficient way to perform blue-green deployments.

Now let's take this a step further. What happens if you want to test out two different versions of the same application in a canary testing manner? For example, if you added a new feature or performed a major version upgrade on your applications' core infrastructure, you don't want to allow all your customers to suddenly have access to it before you find out that bugs remain in the application. In situations like this where testing can't cover everything, you need to expect something to go wrong and reduce the blast radius. For this, we will be discussing two methods of traffic splitting so that only a certain portion of your application traffic ends up in the new application version:

- Traffic percentage splitting
- Header-based routing

The first method is fairly simple: You take all the traffic that comes in and randomly send a certain percentage to the new application version. You will then slowly increase the traffic percentage sent to the new version (promote the deployment) until the only application receiving traffic is the new one. The best method to do this is with Argo Rollouts, which is what we will be using for the lab in the next section.

The second method can be simple or complicated depending on your exact setup. If you only want to route traffic based on the application within your cluster that communicates internally, you can use the Kubernetes gateway API for a quick canary solution. If you want more advanced features you could go for the gateway API provided by a service mesh such as Linkerd. On the other hand, if all your applications receive traffic from external sources and are routed via a load balancer connected to an ingress then the setup can be a little more complex. However, you likely want a combination of both, where traffic comes into your application from a load balancer and needs to be split there, and it then forwards the traffic to other applications within your cluster meaning that the traffic split has to be maintained here as well. In the following lab, we will be looking at both options as well as the more advanced Linkerd option.

Now that you have a good idea of what canary rollouts are, the advantages they have, and the two main methods of splitting traffic, let's head over to the lab where we will start the practical portion.