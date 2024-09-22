# Autoscalers

You likely already know about scalers and what they do, since they are a core part of the Kubernetes architecture. Primary to these scalers are two scaling methods: vertical scaling, and horizontal scaling. In this section, we will dive deep into each of these types of scaling and have a hands-on look at the way that each functions. We will also see the benefits each method has, as well as the drawbacks.

## Vertical pod autoscaler

A vertical pod autoscaler works by collecting metrics (using the metrics server), and then analyzing those metrics over a period of time to understand the resource requirements of the running pods. It considers factors such as historical usage patterns, spikes in resource consumption, and the configured target utilization levels. Once this analysis is complete,  the VPA controller generates recommendations for adjusting the resource requests (CPU and memory) of the pods. It may recommend increasing or decreasing resource requests to better match the observed usage. This is the basis of how a VPA works. However, this is not the end of the job for the VPA, as it has to constantly monitor and create a feedback loop where the VPA regularly adjusts pod resources based on the latest metrics.

As you might already know, these steps are also largely performed by the Horizontal pod autoscaler as well. What differentiates the VPA from the HPA is how scaling is performed. With a VPA, the autoscaler recommends changes to a pod's resource requirements, it does so by modifying the pod's associated resource settings in the deployment or StatefulSet manifest. This triggers Kubernetes to create new pods with the updated resource specifications and gradually replace the existing pods. So it will perform a rolling update where the old pod with insufficient resources is replaced with a new pod that has the required resource allocation.

Scaling down happens in the same way, where the VPA dynamically updates the resource specifications of existing pods. When scaling down, it may reduce the requested CPU or memory resources if historical metrics indicate that the pod consistently uses less than initially requested. Then, the VPA indirectly scales down by updating the resource settings in the pod's associated deployment or stateful set manifest. It then triggers a controlled rolling update, creating new pods with updated resource specifications while phasing out the old ones.

## Horizontal pod autoscaler

A horizontal pod autoscaler works in the same way as a VPA for the most part. It continuously monitors specified metrics, such as CPU utilization or custom metrics, for the pods it is scaling. You define a target value for the chosen metric. For example, you might set a target CPU utilization percentage. Based on the observed metrics and the defined target value, HPA makes a scaling decision to either increase or decrease the number of pod replicas. The amount of resources allocated to each pod remains the same. The number of pods will increase to accommodate this influx. If there is a service associated with the pod, the service will automatically start load balancing across the pod replicas without any intervention from your side.

Scaling down is handled in roughly the same way. When scaling down, HPA reduces the number of pod replicas. It terminates existing pods to bring the number of replicas in line with the configured target metric. The scaling decision is based on the comparison of the observed metric with the target value. HPA does not modify the resource specifications (CPU and memory requests/limits) of individual pods. Instead, it adjusts the number of replicas to match the desired metric target.

Before we go into the lab, since we are talking about metrics, let's take a breif look at the quality of service classes for pod metrics:

## Quality of Service classes

In Kubernetes, Guaranteed, Burstable, and BestEffort are Quality of Service (QoS) classes that define how pods are treated in terms of resource allocation and management. These classes help Kubernetes prioritize and manage workload resources effectively. Here's what each term means:

**Guaranteed**: Pods with Guaranteed QoS are allocated the amount of CPU and memory resources they request, and these resources are guaranteed to be available when needed. Kubernetes reserves resources for pods with Guaranteed QoS, ensuring that they will not be throttled or terminated due to resource shortages. Pods in this class are expected to consume all the resources they request, so they must be careful with their resource requests to avoid wasting resources.

**Burstable**: Pods with Burstable QoS may use more resources than they request, but only up to a certain limit. Kubernetes allows pods in this class to use additional CPU and memory resources if they're available, but there's no guarantee that these resources will always be available. Pods in this class may be throttled or terminated if they exceed their resource limits and there's contention for resources with other pods. 

**BestEffort**: Pods with BestEffort QoS have the lowest priority for resource allocation.These pods are not guaranteed any specific amount of CPU or memory resources, and they are the first to be evicted if the node runs out of resources.BestEffort pods are typically used for non-critical workloads or background tasks that can tolerate resource contention or occasional interruptions.

Now that we have thoroughly explored both types of autoscalers and taken a breif look at how QoS classes work, let's go on to a lab where we will look at the scalers in more detail.

[Next: Autoscaler lab](../Autoscaler101/autoscaler-lab.md)