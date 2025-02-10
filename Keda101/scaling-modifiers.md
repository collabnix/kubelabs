# Advanced scaling modifiers

Advanced Scaling Modifiers in KEDA allow you to combine multiple metrics for more complex scaling strategies. This feature gives you greater flexibility in defining how multiple triggers influence the scaling behavior simultaneously. Going to our previous example, let's say you want to scale based on request counts, but if there were a few requests that made the CPU usage jump, you would also like to cover that base and scale based on CPU as well. This is where advanced scaling modifiers come in.

The most basic form of using multiple metrics to determine scaling would be having both scaling triggers running. When either scaler is triggered, scaling starts. The number of replicas you would scale up to would be whichever of the scalers determined to be higher or higher value. However, this is very basic and limited. KEDA allows you to scale in a much more complicated manner based on two or more metrics.

As an example, let's say you have an application that processes messages from two separate queues: RMQ + SQS. So when making a scaling decision, you have to get the sum of the total messages in each queue in order to make a scaling decision. Let us look at a sample scaling configuration for this scenario by first looking at the RMQ trigger.

```yaml
triggers:
- type: rabbitmq
  metadata:
    host: amqp://localhost:5672/vhost # Optional. If not specified, it must be done by using TriggerAuthentication.
    mode: QueueLength # QueueLength or MessageRate
    value: "1" # message backlog or publish/sec. target per instance
    queueName: testqueue
```

Next, let's take a look at the SQS trigger:

```yaml
triggers:
- type: aws-sqs-queue
  metadata:
    # Required: queueURL or queueURLFromEnv. If both provided, uses queueURL
    queueURL: https://sqs.eu-west-1.amazonaws.com/account_id/QueueName
    queueLength: "1"  # Default: "5"
    # Required: awsRegion
    awsRegion: "eu-west-1"
    identityOwner: pod
```

Both of these work on their own. Before we put these together, we need to understand how scaling modifiers work on scaled objects vs scaled jobs. For the first example, we will consider the application for a scaled job. In this case, we will use:

```
 scaling strategy:
 multipleScalersCalculation : "sum"
```

This says that if multiple triggers exist, then scale up to the sum of both scalers. So here, the total number of messages in RMQ + SQS will be considered for scaling. The other options available are:

- max
- min
- avg

Limited modifiers.