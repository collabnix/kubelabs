# Setting up ingress with EKS

While ingresses have been explained in simple terms in the previous section, there is a little more to it that goes on if you wish to use it with a managed Kubernetes cluster. In this section, we will talk about how you can set up an ingress to allow traffic into your Kubernetes cluster.

This lab assumes you already have an EKS cluster that has a web application deployed into it. It also assumes you already have a public subnet. If you don't please create one. This public subnet is necessary to talk to the internet.

Let's start by getting an overview of the process we are going to follow. The first thing we are going to do is create and deploy an Ingress resource. This resource will have the subnet IDs of the public subnets that you just created. We will also ensure that a load balancer is created within AWS when we deploy the ingress. Once the ingress is deployed, we should be able to take the load balancer ID from within Kubernetes and configure this load balancer from the AWS console.

We could take a look at how to configure this URL with https, but since that requires buying a domain and requesting a certificate, we will be continuing with http. We will add custom rules so that external traffic gets routed to the correct pods, and we shall finally take a brief look at target groups.

Now that the whole plan is laid out, let's start! First, we need to create the ingress resource. We shall use the already existing [ingress file](./ingress.yaml) from the last section as a starting point.