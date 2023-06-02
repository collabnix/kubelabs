# KEDA

If you have been using Kubernetes for any amount of time, you already know that one of the main advantages you get is autoscaling. There are two types of autoscaling: vertical and horizontal. Vertical autoscaling is when you add more resources (memory, CPU) to match resource demands, and is usually found in managed cloud Kubernetes services. On the other hand, horizontal scaling scales your application by creating more pods and replicas. This is a system in place for all Kubernetes clusters, and this is the scaling that KEDA builds on.

KEDA stands for Kubernetes Event Driven Autoscaling, and its name properly summarizes its job. With KEDA, autoscaling occurs as a reaction to events that happen, which is why it is called "Event Driven". So what is this "event"?

It's just about anything. If you want to scale applications based on the messages of a Kafka topic, you can do that. If you want to scale your application depending on the number of records in a DynamoDB table, that's possible. If the scaling should happen based on the number of objects in a Google Cloud Storage bucket, KEDA can help you.

If you head over to the [KEDA site](https://keda.sh) and scroll down to the list of scalers, you will notice a large number of sources that can be used for scaling. These scalers are created either by the official owners of the products or by the community, and this list is continuously growing. You can also see a small description of what each scaler can scale for you.