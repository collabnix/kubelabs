# Karpenter fine tuning

Let's say you have a large number of microservices. About 20 - 30. Depending on the type of workload, you might have separate Karpenter node pools. Some of them might be CPU intensive, so you might use C class machines, while others are memory intensive leading you to use R class. So first let's look into Karpenter's node provisioning.

## Handling Compute-Intensive Workloads

Fine-tuning Karpenter involves configuring `NodePool`, `NodeClaim`, and `EC2NodeClass` (for AWS) to handle different workload requirements. The key aspects to consider include performance, cost, and resilience. For a start, le's look at handling Compute-Intensive Workloads. Compute-intensive workloads, such as machine learning (ML) inference and video processing, require powerful CPU or GPU-based instances. An example configuration is as follows:

```yaml
apiVersion: karpenter.k8s.aws/v1beta1
kind: NodePool
metadata:
  name: compute-intensive-pool
spec:
  template:
    spec:
      nodeClassRef:
        name: compute-optimized
      requirements:
        - key: "node.kubernetes.io/instance-type"
          operator: In
          values: ["c6i.large", "c6i.xlarge", "g5.2xlarge"]
        - key: "karpenter.k8s.aws/instance-category"
          operator: In
          values: ["c"]
      taints:
        - key: "compute-intensive"
          effect: "NoSchedule"
```

This NodePool uses `c6i.large`, `c6i.xlarge`, and `g5.2xlarge` instances for high-performance computing & applies a taint (`compute-intensive`) to ensure only specific workloads run on these nodes. Any applications that need these compute intensive nodes need to tolerate this taint in their pod definition.

## Handling Cost-Efficient Batch Jobs

Batch jobs, such as ETL processes or analytics, can tolerate interruptions, making them ideal for spot instances. In this case you can be a bit more lenient with the workloads since there are no end users that immediately get affected due to a small interruption:

```yaml
apiVersion: karpenter.k8s.aws/v1beta1
kind: NodePool
metadata:
  name: batch-job-pool
spec:
  template:
    spec:
      nodeClassRef:
        name: batch-job-class
      requirements:
        - key: "karpenter.k8s.aws/capacity-type"
          operator: In
          values: ["spot"]
        - key: "node.kubernetes.io/instance-type"
          operator: In
          values: ["m5.large", "m5.xlarge"]
      labels:
        workload-type: "batch"
```

This NodePool uses spot instances (`m5.large`, `m5.xlarge`) to reduce costs and labels nodes with `workload-type: batch` for targeted scheduling. As with before, the workloads using these nodes need to have a toleration for these taints.

## Handling Low Latency for Web Applications

Latency-sensitive workloads, such as real-time APIs or web applications, need stable on-demand instances with a balanced CPU-memory ratio. If there are any interruptions you could face 502 errors & thereby degrade the user experience as they have to retry their applications.

```yaml
apiVersion: karpenter.k8s.aws/v1beta1
kind: NodePool
metadata:
  name: web-app-pool
spec:
  template:
    spec:
      nodeClassRef:
        name: web-app-class
      requirements:
        - key: "karpenter.k8s.aws/capacity-type"
          operator: In
          values: ["on-demand"]
        - key: "node.kubernetes.io/instance-type"
          operator: In
          values: ["t3.medium", "t3.large"]
      labels:
        workload-type: "web-app"
      annotations:
        karpenter.sh/do-not-disrupt: "true"
```

This NodePool uses `t3.medium`, `t3.large` on-demand instances to ensure stability. We also have `karpenter.sh/do-not-disrupt` prevents premature node termination. The annotation `karpenter.sh/do-not-disrupt` is a mechanism in Karpenter that prevents specific nodes from being disrupted, regardless of disruption budgets or consolidation policies. It essentially ignores any other configuration given in the `disruption` section of the nodepool and keeps the machines running. Using this is essentially like having static machines around at all times, so it would be better to dynamically add this annotation only when you need it and remove it later so that the nodepools can adjust. Adding this annotation dynamically can be done via a script:

```bash
#!/bin/bash
NODES=$(kubectl get nodes -l karpenter.sh/provisioner-name=default -o jsonpath='{.items[*].metadata.name}')
for node in $NODES; do
  kubectl annotate node $node karpenter.sh/do-not-disrupt="true" --overwrite
done
```

So if you are in the middle of a DDoS attack and you want to keep your servers up while the attack is being handled, you could either run this script manually or have it automated by whatever tool you used as your application firewall.

## Handling Data-Intensive Workloads

Data-intensive workloads, such as databases or persistent storage workloads, require high memory and disk throughput. `r` class machines are generally the best option for memory, but note that they have very low CPU which might affect application start times. Also, the smallest available `r` machine has 16GB of memory so it might be too much considering that the best way to run an application is distributed with multiple machines in different availability zones. However, if your applications are memory intensive and you have a number of them, the `r` class is the way to go.

```yaml
apiVersion: karpenter.k8s.aws/v1beta1
kind: NodePool
metadata:
  name: data-intensive-pool
spec:
  template:
    spec:
      nodeClassRef:
        name: high-memory-class
      requirements:
        - key: "karpenter.k8s.aws/instance-category"
          operator: In
          values: ["r"]
        - key: "node.kubernetes.io/instance-type"
          operator: In
          values: ["r5.large", "r5.xlarge"]
      labels:
        workload-type: "database"
      taints:
        - key: "database"
          effect: "NoSchedule"
```

This NodePool uses memory-optimized instances (`r5.large`, `r5.xlarge`). Applies `database` taint to limit workloads.

## Fine tuning node classes

Now that we have looked at fine-tuning node pools, let's consider node classes. Node classes define the details of the machines that get spun up. For example, what subnet should it use, what security groups should be assigned to each machine, what tags should get added, which AMIs to use, etc... It might look like there is nothing to fine-tune here. While there certainly is nothing to change in terms of machine sizes and resources used, you should consider the way Karpenter operates when setting up resources. You might want to schedule different workloads on different subnets, or you might want to use separate cost allocation tags to measure the costs of your workloads separately. It is also very likely that you would want to assign different security groups to different workloads so that your applications don't have unnecessary ports exposed. When considering these things, it is necessary to start fine-tuning node classes.

Let's start by defining a node class:

```yaml
apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata:
  name: default
spec:
  amiFamily: AL2
  role: "KarpenterNodeRole-test-cluster"
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: "test-cluster"
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: "test-cluster"
  tags:
    cost-tag: CostAllocation
  amiSelectorTerms:
    - id: "ami-03d24239f12d53c4a"
    - id: "ami-09c00c2e93ce7bd23"
```

In the above node class, you instruct Karpenter to start nodes in subnets with the tag `karpenter.sh/discovery: "test-cluster"` in them. This means, for example, if you find your subnet running out of IPs, all you have to do is create a new subnet and add this tag and Karpenter will start using that subnet as well. In the same way, if you were to be doing some changes to a NAT gateway and you wanted a subnet cleared of all the machines using it, you could simply remove the tag from the subnet and Karpenter will perform a rolling update to remove any machines that it has on the subnet.

Next, we have the security group defined in the same way. Any machines that come up need to have all security groups with the tag `karpenter.sh/discovery: "test-cluster"` assigned to them. Removing this tag will make Karpenter perform a rolling update of the machines to create new ones that don't have this security group attached, and adding the tag will make Karpenter perform an update that will add this tag to all the machines that use this node class. Another thing here is the tag `cost-tag: CostAllocation`. Any machines that come up from this node class will have this tag attached to it. So if this tag is a cost allocation tag, you would be able to find out exactly how much your EKS infrastructure costs using it.

```yaml
apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata:
  name: nodeclass-high-resource
spec:
  amiFamily: AL2 
  role: "KarpenterNodeRole-test-cluster" 
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: "test-cluster" 
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery-high-resource: "test-cluster"
  tags:
    cost-tag: CostAllocation
  amiSelectorTerms:
    - id: "ami-03d24239f12d53c4a"
    - id: "ami-09c00c2e93ce7bd23"
```

Next, let's look at a different node class. It looks about the same as the one before, except this one has the tag `karpenter.sh/discovery-high-resource: "test-cluster"` which means it will only attach any security groups that have the tag `karpenter.sh/discovery-high-resource: "test-cluster"` in them. Note that you have multiple tags in both the security group selector as well as subnet selector, meaning that you can have a base set of security groups that apply to all machines and a specific selection of security groups that only apply to a subset.

And that's it for fine-tuning Karpenter node classes. Next, let's look at fine-tuning the node pool further with disruption budgets.

## Fine tuning disruption budgets

First off, the syntax we will be using here is only available for Karpenter v1.0 upwards, so you will need to upgrade if you are in v0.3xx or lower. You can follow the official [migration guide](https://karpenter.sh/v1.0/upgrading/v1-migration/) for this. Let's start by looking at a sample of a disruption budget:

```yaml
apiVersion: karpenter.k8s.aws/v1beta1
kind: NodePool
metadata:
  name: data-intensive-pool
spec:
  template:
    spec:
      nodeClassRef:
        name: high-memory-class
      requirements:
        - key: "karpenter.k8s.aws/instance-category"
          operator: In
          values: ["r"]
        - key: "node.kubernetes.io/instance-type"
          operator: In
          values: ["r5.large", "r5.xlarge"]
      labels:
        workload-type: "database"
      taints:
        - key: "database"
          effect: "NoSchedule"
  disruption:
    consolidationPolicy: WhenEmptyOrUnderutilized
    expireAfter: 720h # 30 * 24h = 1h
    budgets:
    - nodes: "10%"
      schedule: "0 14 * * *"
      duration: 8h
      reasons:
      - "Empty"
      - "Drifted"
    - nodes: "50%"
      reasons:
      - "Empty"
      - "Drifted"
    - nodes: "5"
```

Take note of the last part of the NodePool where `disruption` is declared. There are 3 separate budgets, so let's look at them one by one.

1. **First Budget Rule:**
   ```yaml
   - nodes: "10%"
     schedule: "0 14 * * *"
     duration: 8h
     reasons:
     - "Empty"
     - "Drifted"
   ```
   - Karpenter is allowed to delete up to **10% of the nodes** at a time.
   - This rule is **only active** from **2 PM (14:00) onwards** each day and lasts for **8 hours** (until 10 PM).
   - The deletions will only happen if the nodes are **Empty** (i.e., not running workloads) or **Drifted** (i.e., they no longer match the cluster requirements due to changes in constraints or instance types).

2. **Second Budget Rule:**
   ```yaml
   - nodes: "50%"
     reasons:
     - "Empty"
     - "Drifted"
   ```
   - Karpenter is allowed to delete **up to 50% of the nodes** at a time.
   - This rule has **no specific schedule**, meaning it is always in effect.
   - Again, deletions only happen if the nodes are **Empty** or **Drifted**.

3. **Third Budget Rule:**
   ```yaml
   - nodes: "5"
   ```
   - At any given time, Karpenter is allowed to delete **up to 5 nodes**.
   - This rule does not specify any reasons or schedule, meaning it applies at all times.

### How These Rules Work Together:
- During **2 PM to 10 PM**, Karpenter follows the **10% rule** for deletions due to `Empty` or `Drifted` nodes.
- At other times, Karpenter follows the **50% rule** but only for `Empty` or `Drifted` nodes.
- The **absolute limit of 5 nodes** applies at all times.

This setup ensures **controlled, scheduled** deletions while allowing **larger-scale cleanups when necessary**, without over-deleting nodes too quickly.

## Conclusion

That brings us to the end of the section on fine tuning Karpenter. Next, let's look at the Karpenter upgrade process.

[Next: Upgrading Karpenter](./karpenter-upgrade.md)