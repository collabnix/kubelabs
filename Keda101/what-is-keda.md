# KEDA

If you have been using Kubernetes for any amount of time, you already know that one of the main advantages you get is autoscaling. There are two types of autoscaling: vertical and horizontal. Vertical autoscaling is when you add more resources (memory, CPU) to match resource demands, and is usually found in managed cloud Kubernetes services. On the other hand, horizontal scaling scales your application by creating more pods and replicas. This is a system in place for all Kubernetes clusters, and this is the scaling that KEDA builds on.

KEDA stands for Kubernetes Event Driven Autoscaling, and its name properly summarizes its job. With KEDA, autoscaling occurs as a reaction to events that happen, which is why it is called "Event Driven". So what is this "event"?

It's just about anything. If you want to scale applications based on the messages of a Kafka topic, you can do that. If you want to scale your application depending on the number of records in a DynamoDB table, that's possible. If the scaling should happen based on the number of objects in a Google Cloud Storage bucket, KEDA can help you.

If you head over to the [KEDA site](https://keda.sh) and scroll down to the list of scalers, you will notice a large number of sources that can be used for scaling. These scalers are created either by the official owners of the products or by the community, and this list is continuously growing. You can also see a small description of what each scaler can use to trigger the scaling. The chance of you not finding a built-in scaler for your application is quite low. However, if you are working with a niche tool which doesn't have a pre-built scaler, KEDA offers a [well-documented set of steps](https://keda.sh/docs/2.0/concepts/external-scalers/) to help you create your own scaler. For added flexibility, you can create the scaler in Golang, C#, or JavaScript. Since the likelihood of you having to create your own scaler is fairly low, we will not be covering it in the lab.

The great thing about KEDA is that it is flexible from both ends. It's flexible in terms of the data source used to trigger the scaling, and it is flexible in terms of what it scales. KEDA can scale almost any type of Kubernetes resource. It can scale Deployments, StatefulSets, custom resources, Jobs, nodes, or whatever you want.

As you might guess, the ability to scale any Kubernetes resource based on just about any type of metric is an incredibly powerful tool. So let's go ahead and jump straight into the lab!

[Next: KEDA Lab](./keda-lab.md)