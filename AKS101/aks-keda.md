# Kubernetes Event-driven Autoscaling (KEDA)

The first thing you need to know about KEDA is that it is still in a preview stage and is therefore not meant for production use. It might have been released by the time you are reading this, so head over to the [official docs](https://docs.microsoft.com/en-us/azure/aks/keda-about) and make sure that there is no information pane warning you about the stability.

As you may have inferred, KEDA helps you scale your cluster resources in a simple and lightweight manner. Now, you may be asking, don't we already have an excellent scaling mechanism within Kubernetes? Why do we need something more? Well, the thing about KEDA is that it doesn't replace Kubernetes scaling, and rather extends upon it, giving you a host of additional features. Let's start by looking at the architecture KEDA uses.

## Architecture

KEDA has two main roles within Kubernetes. The Agent and the metrics server. The agent is responsible for doing the actual scaling by activating and deactivating deployment, which is dictated by the number of events present. The metrics server, as the name suggests, exposes metrics related to autoscaling, and can send this information to external services that handle metrics.

One major point to understand about KEDA is that it is **event-driven**. This means that it doesn't scale randomly, and needs to have some event triggered for it to start functioning. It is upon receiving this event that KEDA decides whether a deployment should be activated or deactivated. There is a rather exhaustive list of event sources and scalers that can be considered, and this information is detailed in the [official docs](https://keda.sh/docs/2.7/concepts/#event-sources-and-scalers).

## Deploying KEDA

If you are deploying KEDA into a non-AKS cluster, then you can use Helm and follow a simple 3 step process to introduce it into your cluster. The detailed steps can be found [here](https://keda.sh/docs/2.7/concepts/#event-sources-and-scalers).

However, since we are working with AKS you need to enable KEDA as an addon. To start, you need Azure CLI in your cluster, after which you need to register the KEDA feature in your subscription:

```
az feature register --name AKS-KedaPreview --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.ContainerService
```

Then use the Azure resource manager template to specify KEDA:

```
"workloadAutoScalerProfile": {
    "keda": {
        "enabled": true
    }
}
```

Thant's it! You can now connect to your AKS cluster using Azure CLI and check deployments. The [example deployment](https://docs.microsoft.com/en-us/azure/aks/keda-deploy-add-on-arm#example-deployment) from the official docs is a great place to start. Make sure to go through the rest of the documentation if you need any more information or clarification.