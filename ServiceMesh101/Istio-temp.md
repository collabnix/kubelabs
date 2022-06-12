## Istio Configuration

The major advantage of service meshes that we have been repeatedly mentioning is that it tacks on to your existing cluster without intruding on your existing resources. As with most other Kubernetes resoureces, Istio can be configured using Yaml files. It also support Custom Resource Defintions so that you have extended access to the Kubernetes API. 

### Configuring CRD's

One major thing you may want to control inside your cluster is the inter-cluster traffic. What pods can communicated with each other, how the communication should happen, how many times it should try before timing out. These are all things that can be addressed by Istio, and can use CRD's to help. To be more specific, there are two main CRD's that can achieve this: the Virtual Service and the Destination Rule.

**Virtual service:** This deals with the intricacies behind how the actual routing is done to the destination.

**Destination Rule:** This deals with what to do when the communication has been recieved. How will we get this communication over to the services, what policies need to be enforced, etc...

Remember that Istio uses Envoy as a proxy. So our CRD's won't work out of the box here. But we don't have any additional steps to take since Istio, or rather, Istiod, will handle this conversion for us. It will turn these high level routing rules to Envoy specific configurations, which will then be sent to the Envoy proxies. All without us having to handle any part of the configuration. Once this is done, the Envoy proxies will be able to communicate with each other based on the policies and rules set aside for them without involving Istiod.

## What else does Istio offer

If you are working in a large organization that has huge clusters that increase in size all the time, having all these rules and policies enforced into each new service can be a hassle. However, Istio provides service discovery, which mean that if you were to introduce a new service, Istio will passively discover the service and apply the necessary configuration without you having to do anything yourself. 

Remember during the microservices section, we discussed the security risks associated with a microservice architecture. Istio addresses this problem by acting as a certificate authority that manages the certificates between microservices in a cluster, and enbales secure TLS communication among them. Since the interactions between the pods are restricted, monitored, and have policies enforces, this means an attacker would not be able to move around the cluster freely, even if they managed to breach the cluster's security.

