# Authentication

This section will cover running authentication tools inside your cluster. In particular, we will be focusing on the use of Keycloak to act as an OIDC provider. This provider can then be used to authenticate your internal tools running within Kubernetes as well as outside Kubernetes (as long as it is inside the same VPC).

Most organization have their own VPN which can be used to access resources within their private VPC. This is standard practice when managing your internal resources since you want to minimize your attack surface as much as possible. This means severely reducing the amount of internet-facing services you have that can be susceptible to vulnerabilities. So while well-established providers such as Google SSO exist, your services need to be internet-facing for those providers to work. This is where running your OIDC provider within your VPC comes in handy. If both your provider and the tools that use the provider are in the same VPC, there is no issue.

For this example, we will be setting up Keycloak, and then using it to authenticate Devtron, which is a CI/CD & cluster operations tool. To learn more about it, head to the [observability section](../Observability101/observability.md). We will set up both tools with Helm, which you are already familiar with. You will also need to have a Kubernetes cluster either running locally on your machine or on a cloud platform.

## Keycloak installation

Bitnami has an official Keycloak chart present, but this chart has some unresolved issues around its database configuration, so we will be using a different Keycloak chart from codecentric instead. We will be using all the default values since they work fine for our use case, so install the chart with the following:

```
helm install keycloak codecentric/keycloak
```

Once the pods are ready, you can use port forwarding to access the Keycloak dashboard:

```
kubectl port-forward svc/keycloak-http 80:80 -n keycloak
```

You could also use a load balancer to access the resource by editing the service and setting the type to load balancer. Make sure you also set the annotation:

```
service.beta.kubernetes.io/aws-load-balancer-internal: true
```

This will make sure your LB is internal instead of internet-facing.

## Devtron installation

Now that Keycloak is up, let's focus on setting up Devtron. We will set it up without any additional integrations:

```
helm repo add devtron https://helm.devtron.ai
helm repo update devtron
helm install devtron devtron/devtron-operator \
--create-namespace --namespace devtroncd
```

Exposing this is similar to exposing Keycloak. Either use port forwarding or edit the `devtron-service` inside the `devtroncd` namespace the same way as before. Once you have done that, log in to the Keycloak dashboard.

## Managing the realm

Keycloak allows you to separate your clients into various realms. For this exercise, you can use the default master realm used by Keycloak, or you could create your own realm to put the clients under. In any case, all you need to do here is to go to Realm settings > General, and click on "OpenID Endpoint Configuration". This will open up a JSON page. Take note of the first item in the block `issuer`. You will need this for the next part.

## Creating the Devtron client

Since Keycloak is the provider, Devtron will be the client that requests the authentication service. In the same way, if you had a different service that required authentication with Keycloak, that would be another client. 

From the left pane, go to clients > Create.

Here, set the client ID to `devtron`, and the name to `Devtron`. Make sure the client protocol is openid-connect and the access type is confidential. Under "Valid Redirect URIs", set the redirect URL you got from Devtron.