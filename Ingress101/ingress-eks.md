# Setting up ingress with EKS

While ingresses have been explained in simple terms in the previous section, there is a little more to it that goes on if you wish to use it with a managed Kubernetes cluster. In this section, we will talk about how you can set up an ingress to allow traffic into your Kubernetes cluster.

This lab assumes you already have an EKS cluster that has a web application deployed into it. It also assumes you already have a public subnet. If you don't please create one. This public subnet is necessary to talk to the internet.

Let's start by getting an overview of the process we are going to follow.