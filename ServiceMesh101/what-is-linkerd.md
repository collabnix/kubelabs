# What is Linkerd?

Similar to Istio, this is a service mesh. It provides more or less the same functionality that Istio does, and the architecture is also very similar. Therefore, if you choose to switch from Istio to Linkerd, then the learning curve should be rather minimal. The two service meshes also maintain the same service mesh architecture and the differences are rather minimal. So let's start by talking about what is different. I

## Envoy vs Linkerd-proxy

The most notable difference between Istio and Linkerd is that while Istio uses Envoy as the proxy that gets attached to microservices, Linkerd uses its own purpose-built proxy. The makes the whole solution more light-weight, and therefore, faster. While Envoy is a proxy with many use cases, Linkerd-proxy only has a single purpose: being the most lightweight, secure, and simplest proxy available for the specific scenario of being a Kubernetes sidecar proxy. If you're interested, you can read the [blog post](https://linkerd.io/2020/12/03/why-linkerd-doesnt-use-envoy/) on the Linkerd website that specifies the multitude of reasons for a separate proxy to exist.

The lightweight nature allows Linkerd to operate very non-intrusively and allows you to add and remove features of Linkerd from your cluster on the fly.

When it comes to the other features of Linkerd, they are pretty close to what you get from Istio. The same level of metrics, logging, etc... is available, and you might even find the configuration a bit simpler. So let's take a look at that.

## Linkerd configuration

There are two ways you can inject Linkerd into your cluster. One is by adding an annotation into your yaml:

```
annotations:
    linkerd.io/inject: enabled
```

The second is by injecting it on the fly. Note that this approach only :

```
kubectl get deploy <deployment> -o yaml | linkerd inject - | kubectl apply -f -
```

You can then check on the proxy to see if it handles requests properly:

```
linkerd -n default check --proxy
```

And that's it! A painless, easy-to-maintain setup. If you want to learn more about Linkerd, then head over to the [official documentaion](https://linkerd.io/docs/) which, in my opinion, is very well written.