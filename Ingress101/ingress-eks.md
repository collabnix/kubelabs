# Setting up ingress with EKS

While ingresses have been explained in simple terms in the previous section, there is a little more to it that goes on if you wish to use it with a managed Kubernetes cluster. In this section, we will talk about how you can set up an ingress to allow traffic into your Kubernetes cluster.

This lab assumes you already have an EKS cluster that has a web application deployed into it. It also assumes you already have a public subnet. If you don't please create one. This public subnet is necessary to talk to the internet.

Let's start by getting an overview of the process we are going to follow. The first thing we are going to do is create and deploy an Ingress resource. This resource will have the subnet IDs of the public subnets that you just created. We will also ensure that a load balancer is created within AWS when we deploy the ingress. Once the ingress is deployed, we should be able to take the load balancer ID from within Kubernetes and configure this load balancer from the AWS console.

We could take a look at how to configure this URL with https, but since that requires buying a domain and requesting a certificate, we will be continuing with http. We will add custom rules so that external traffic gets routed to the correct pods, and we shall finally take a brief look at target groups.

Now that the whole plan is laid out, let's start! First, we need to create the ingress resource. We shall use the already existing [ingress file](./ingress.yaml) from the last section since we only have to modify it slightly for it to work with AWS ALB. In fact, you can leave the entire file as it is, and just add a couple of lines in the annotations section that will make it ALB compatible:

```
kubernetes.io/ingress.class: "alb"
alb.ingress.kubernetes.io/scheme: internet-facing
alb.ingress.kubernetes.io/subnets: <subnet-1>, <subnet-2>, <subnet-3>
alb.ingress.kubernetes.io/target-type: ip 
alb.ingress.kubernetes.io/healthcheck-interval-seconds: '15'
alb.ingress.kubernetes.io/healthcheck-timeout-seconds: '5'
alb.ingress.kubernetes.io/success-codes: '200'
alb.ingress.kubernetes.io/healthy-threshold-count: '2'
alb.ingress.kubernetes.io/unhealthy-threshold-count: '2'
```

If you have ever set up a target group with the AWS console before, you will find most of these annotations familiar, such as the health check timeouts and healthy threshold counts. You need to specify all the public subnets you created here, and the rest of the annotations are all related to the target group that will be created. You can find the final version of the file [here](./ingress-eks.yaml). 

Once this file is ready, you can deploy it into your cluster the same way you would deploy any other Kubernetes resource:

```
kubectl apply -f ingress-eks.yaml
```

Now it's time to retrieve the ID of the load balancer your deployment created.