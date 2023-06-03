# Install Minibroker

## What is a minibroker?

Remember that a component of setting up service catalogs was a **service broker**. While you obviously need a broker from a cloud provider in a production environment, this doesn't really make sense when you are in the testing or development phases. Minibroker works seamlessly with Minikube to set up an implementation of the Open Service Broker API and provide this functionality.

## Steps

The steps are similar to the way the service catalog was installed. First, add minibroker to the Helm repo:

```
helm repo add minibroker https://minibroker.blob.core.windows.net/charts
kubectl create namespace minibroker
helm install minibroker --namespace minibroker minibroker/minibroker
```

You can also update Minibroker with this command:

```
helm upgrade minibroker minibroker/minibroker \
  --install \
  --set deploymentStrategy="Recreate"
```

You can find more information about Minibroker in its official [repo](https://github.com/kubernetes-retired/minibroker).

With this, you are all set up to start working with a service catalog.
