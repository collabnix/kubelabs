## Istio Configuration

The major advantage of service meshes that we have been repeatedly mentioning is that it tacks on to your existing cluster without intruding on your existing resources. As with most other Kubernetes resources, Istio can be configured using Yaml files. It also supports Custom Resource Definitions so that you have extended access to the Kubernetes API.

### Configuring CRD's

One major thing you may want to control inside your cluster is the inter-cluster traffic. What pods can communicate with each other, how the communication should happen, and how many times it should try before timing out. These are all things that can be addressed by Istio and can use CRDs to help. To be more specific, two main CRDs can achieve this: the Virtual Service and the Destination Rule.

**Virtual service:** This deals with the intricacies behind how the actual routing is done to the destination.

**Destination Rule:** This deals with what to do when the communication has been received. How will we get this communication over to the services, what policies need to be enforced, etc...

Remember that Istio uses Envoy as a proxy. So our CRDs won't work out of the box here. But we don't have any additional steps to take since Istio, or rather, Istiod will handle this conversion for us. It will turn these high-level routing rules into Envoy-specific configurations, which will then be sent to the Envoy proxies. All without us having to handle any part of the configuration. Once this is done, the Envoy proxies will be able to communicate with each other based on the policies and rules set aside for them without involving Istiod.

## What else does Istio offer

If you are working in a large organization that has huge clusters that increase in size all the time, having all these rules and policies enforced into each new service can be a hassle. However, Istio provides service discovery, which means that if you were to introduce a new service, Istio will passively discover the service and apply the necessary configuration without you having to do anything yourself.

Remember during the microservices section, we discussed the security risks associated with a microservice architecture. Istio addresses this problem by acting as a certificate authority that manages the certificates between microservices in a cluster and enables secure TLS communication among them. Since the interactions between the pods are restricted, monitored, and have policies enforces, this means an attacker would not be able to move around the cluster freely, even if they managed to breach the cluster's security.

Next, there are metrics. Note that with this architecture, all communications between pods go through the Envoy proxies. This means that the proxies are an excellent source of metrics, and Istio uses this to its advantage. This means the proxies gather metrics information that can be consumed by other services such as Prometheus, which adds another layer of logging for your cluster.

Istio also offers an Ingress gateway. If you don't fully understand what an Ingress is, then head over to the [Ingress section](./../Ingress101/README.md) and have a read-through. The ingress gateway supplied by Istio is similar to a regular ingress gateway (such as the one provided by [nginx](https://docs.nginx.com/nginx-ingress-controller/)). The gateway runs as a pod in your cluster and plays the role of a load balancer by accepting connections to the cluster and then distributing the connections across the microservices.

## Overview

Here's a quick wrap-up of the whole process:

1. The request from the user comes to the Istio cluster, which then gets rerouted to your microservice (based on load).
2. The request reaches the Envoy proxy related to that microservice (not the pod), where it undergoes any policies, rules, etc... set in place
3. The request is handled by the Envoy proxy and redirected to the pod. Note that since the proxy is a sidecar container attached to your pod, it can do this efficiently via localhost.
4. If there is additionally communication that needs to be done, the pod will send that information to its proxy, where step 2 will happen again
5. The Envoy proxy will forward the request to the Envoy proxy of the appropriate destination microservice, and everything from step 2 onwards will repeat

Note that the control plane is not included in this flow. This is because the requests don't actually go through the control plane, and instead, the proxies communicate with each other directly, which reduces latency. However, the control plane is actively involved in metrics collection while this flow is happening. 