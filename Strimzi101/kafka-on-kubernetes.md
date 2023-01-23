# Kafka on Kubernetes

Before we get into running Kafka on Kubernetes, you need to have some idea about Kubernetes operators. Head over to the [operators topic](../StatefulSets101/operators.md) to get a quick refresher on the concept. The reason we are focused on Kubernetes operators is that we are going to use them to set up the Kafka cluster.

As you can imagine, setting up Kafka from scratch is no simple task and would take developers weeks if not months to set up from scratch. This is why multiple operators exist that help you set up the cluster with a few quick commands. There are three main operators for this. [Strimzi](https://strimzi.io), which is free and open source, and is what we are going to use now. [Banzai Cloud Operator (Koperator)](https://banzaicloud.com/docs/supertubes/kafka-operator/install-kafka-operator/#manual-install) which is also open source and newer than the other operators. [Confluent Operator](https://docs.confluent.io/operator/current/overview.html#co-long) which is a commercial product. If you are in a large organization, you will likely be using the Confluent version which has extensive support and constantly updating features.

All these operators have the configuration needed to run a Kafka cluster and allow you to simplify what would have taken weeks into a couple of seconds. You can take a look at the scripts Strizmi uses [here](https://strimzi.io/install/latest?namespace=kafka) which should give you some idea of the work that is automated for you. Now, let's get to setting up the operator.

## Lab

```yaml
apiVersion: kafka.strizmi.io/v1beta1
```