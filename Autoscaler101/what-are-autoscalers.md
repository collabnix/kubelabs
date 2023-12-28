# Autoscalers

You likely already know about scalers and what they do, since they are a core part of the Kubernetes architecture. Primary to these scalers are two scaling methods: vertical scaling, and horizontal scaling. In this section, we will dive deep into each of these types of scaling and have a hands-on look at the way that each functions. We will also see the benefits each method has, as well as the drawbacks.

## Vertical pod autoscaler

A vertical pod autoscaler works by collecting metrics (using the metrics server), and then analyzing those metrics over a period of time to understand the resource requirements of the running pods. It considers factors such as historical usage patterns, spikes in resource consumption, and the configured target utilization levels. Once this analysis is complete,  the VPA controller generates recommendations for adjusting the resource requests (CPU and memory) of the pods. It may recommend increasing or decreasing resource requests to better match the observed usage.