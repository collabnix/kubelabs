# Kubezoo

If you have a large number of small clients that all rely on various services you provide, it makes little sense to have a separate Kubernetes cluster for each of them. An individual cluster will incur costs for control planes and each cluster needs to have supporting resources enabled which will result in resource usage. Multi-tenancy is the solution for this problem, where we only have a single cluster which we split into multiple namespaces, which are each assigned to a client or a "tenant".

However, this solution comes with its own host of problems. The biggest issue is resource consumption. Imagine you have 4 nodes, each with a memory capacity of 16GB. If you have 3 tenants running on 3 namespaces within a cluster, one of those 3 tenants may consume 75% of the memory with their workloads while the other 2 are left with only 25%. Whatever the distribution may be, there will be a difference in the amount of resources used, and if each tenant is paying the same amount, this will lead to a disparity. It is therefore necessary to individually assign resources to each tenant depending on the amount they have requested so that tenants don't bottleneck each other.

Now take a different situation. Instead of having 3 large clients, you have hundreds of small users. Each user needs to quickly run workloads in their own private "cluster", and it needs to be quick and efficient. This would be a pretty much impossible-to-manage situation without the proper tools. If we are talking about an average-sized team, it becomes infeasible from a manpower perspective to be able to handle these kinds of quick changes.

This is where Kubezoo comes in. The solution they provide is Kubernetes API as a Service (KAaaS). Kubezoo allows you to easily share your cluster among hundreds of tenants, and allows sharing both the control plane and the data plane. This makes the resource efficiency as high as simply having a namespace for each tenant. However, unlike a namespace isolation method, this also has increased API compatibility as well as resource isolation. So while there are several different multi-tenancy options to choose from, Kubezoo is one of the best when it comes to handling a large number of small tenants.

# Lab

Now that we have covered what Kubezoo is, let's take a look at how we can set it up in a standard cluster.