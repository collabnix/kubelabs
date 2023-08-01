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

Now it's time to retrieve the ID of the load balancer your deployment created. To do this, run the following command:

```
kubectl get ingress -A
```

You should see the load balancer address now. The rest of the configuration will happen from the AWS side. So open up the AWS console and head over to the EC2 section. From here. you should be able to see the "Load Balacers" subsection. Open this page and search for the correct load balancer using the address you copied. From here, you should see the list of listeners. An HTTP listener should have been automatically created. If not, you can add it yourself. Alternatively, if you have a registered certificate, you could go for an HTTPS listener. If you use HTTP, it will be on port 80 while HTTPS uses port 443. For the default routing option, select "Show 404 page". Don't worry, we will set up proper routing to the services later. Right now, you only defined the base routing rule, which is that anything that comes into the load balancer should return a 404. Once the listener is set up, your ingress is ready to receive HTTP/HTTPS traffic. However, you need to have routing to allow anything into the specific services you mentioned in your load balancer.

For this, open up the listener. There are several options on how routing can happen. We will be using the simplest and most widely used method: path-based routing.