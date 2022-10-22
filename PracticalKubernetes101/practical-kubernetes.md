# Practical Kubernetes

We now know quite a bit about Kubernetes and other related technologies. So let's start focusing on the more practical aspects of using Kubernetes on a day-to-day basis as a DevOps engineer. Before we start, it's essential to know where you can get answers if you get stuck, and the best place for that is the [Kubernetes documentation](https://kubernetes.io/docs/home/). However, you may want to keep a couple of kubectl commands memorized since you would use them frequently, and that is what we would touch on first.

## Useful kubectl flags

kubectl uses flags that apply to many different types of resources, and mastering them will allow you to easily use them with other Kubernetes commands. Let's take a look at them here:


The main component of Kubernetes is its pods, so let's start by taking a look at the pod commands. Note that you can use `po` as shorthand:

```
kubectl get po -A
```
