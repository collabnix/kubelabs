# Advanced scaling modifiers

Advanced Scaling Modifiers in KEDA allow you to combine multiple metrics for more complex scaling strategies. This feature gives you greater flexibility in defining how multiple triggers influence the scaling behavior simultaneously. Going to our previous example, let's say you want to scale based on request counts, but if there were a few requests that made the CPU usage jump, you would also like to cover that base and scale based on CPU as well. This is where advanced scaling modifiers come in.

The most basic form of using multiple metrics to determine scaling would be having both scaling triggers running. When either scaler is triggered, scaling starts. The number of replicas you would scale up to would be whichever of the scalers determined to be higher or higher value. However, this is very basic and limited. KEDA allows you to scale in a much more complicated manner based on two or more metrics.

As an example, let's say you have an application that processes messages from two separate queues: RMQ + SQS. So when making a scaling decision, you have to get the sum of the total messages in each queue in order to make a scaling decision. Let us look at a sample scaling configuration for this scenario by first looking at the RMQ trigger.

```yaml
triggers:
- type: rabbitmq
  metadata:
    name: rmq
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
    name: sqs
    # Required: queueURL or queueURLFromEnv. If both provided, uses queueURL
    queueURL: https://sqs.eu-west-1.amazonaws.com/account_id/QueueName
    queueLength: "1"  # Default: "5"
    # Required: awsRegion
    awsRegion: "eu-west-1"
    identityOwner: pod
```

Both of these work on their own. Before we put these together, we need to understand how scaling modifiers work on scaled objects vs scaled jobs. For the first example, we will consider the application for a scaled job. In this case, we will use:

```yaml
 scalingstrategy:
 multipleScalersCalculation : "sum"
```

This says that if multiple triggers exist, then scale up to the sum of both scalers. So here, the total number of messages in RMQ + SQS will be considered for scaling. The other options available are:

- max
- min
- avg

Scaled jobs are somewhat limited in that only these options are available when it comes to scaling modifiers. While it still provides far broader options compared to the normal inbuilt Kubernetes scalers, it is quite small compared to the scaling options provided for ScaledObjects. So, let's look into those next.

With ScaledObjects, you can create scaling modifiers that use the full range of functions available in the [expr](https://expr-lang.org/docs/language-definition) library. For example, taking into account the same two triggers as before, we can create a scaling modifier like this:

```yaml
advanced:
  scalingModifiers:
    formula: "(rmq + sqs)/2"
    target: "2"
    activationTarget: "2"
    metricType: "AverageValue"
```

According to the above definition, you add the queue lengths of RMQ and SQS, divide them by 2 to get a mean value, and see if that value is greater than 2. If it is, scaling happens. You can also use number functions such as max, min, abs, ceil, floor, round, etc... This gives way more options than the four functions available for scaled jobs. The next interesting thing we can do here is use ternary operators to create if conditions within the scaler itself. So, for example, say we want this: if the rmq queue length is greater than the sqs queue length, return the rmq queue length/2. Else, return the sqs queue length. This can be handled by a function such as:

```yaml
formula: "rmq > sqs ? rmq/2 : sqs"
```

This way, you can use expressions to return conditional values instead of a static number or scaler options. You can also mix in other expressions provided in the library to make the calculations even more complex depending on your needs so that your pods scale exactly when you need them to. You also can chain expressions together like so:

```yaml
formula: "rmq < 2 ? rmq+sqs >= 2 ? 5 : 10 : 0"
```

The above means, if value of rmq is less than 2 AND rmq+sqs is at least 2 then return 5, if only the first is true return 10, if the first condition is false then return 0.

This brings us to the end of the topic of scaling modifiers. Before we wrap up, several KEDA options can help make scaling decisions, so we will take a brief look at them next.

[Next: Scaling options](./scaling-options.md)