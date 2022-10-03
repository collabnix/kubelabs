# AWS Fargate

The container orchestration part is already managed by EKS, so Fargate focuses on managing the infrastructure your containers and pods run on. This means that Fargate is serverless (just like AWS Lambda), and will spin EC2 instances up and down depending on your workload. You will not be creating any instances on your own account. You don't even need to specify the number of resources that need to be allocated since Fargate is capable of making that decision on its own.

Once the pod/container has finished running, Fargate will automatically spin down the instance, meaning that you will only pay for the resources you used and for how long you used them. Fargate also comes with integrations to other AWS services, such as IAM, CloudWatch, and Elastic Load Balancer. Fargate also works well with [AWS ECS](https://aws.amazon.com/ecs/), which is a container orchestration tool provided by Amazon similar to Kubernetes or Docker swarm.

To make things easier, you can use eksctl to create a cluster with Fargate support. Doing so is as easy as specifying the argument in CLI:

```
eksctl create cluster --fargate
```