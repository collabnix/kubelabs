# Using KEDA with prometheus

Scaling your application based on the number of requests it receives is a common situation. If you wanted to do that with KEDA, you could use the [KEDA http add-on](https://github.com/kedacore/http-add-on). This solution is great if your application is small and you don't mind the architecture of your existing application changing. However, if you want to scale based on requests without going through all that, you aren't left with many options. To begin with, you need a tool that can accurately capture the number of requests coming into each application. Service meshes have this information, but no service mesh out there handles pod scaling since that is well out of their scope. So you have KEDA which doesn't have access to metrics such as request counts, and service meshes, which have access to that information, but aren't able to scale your pods. How do you mix the two together? The answer is Prometheus.

Using KEDA with Prometheus can allow you to scale your application based on metrics that you would otherwise not have access to. Prometheus supports a wide variety of metrics out of the box, and you can use it in conjunction with other tools that push metrics into prometheus. It is also pretty simple for you to push your own metrics from your applications to Prometheus, and KEDA having a scaler based on Prometheus means you can scale based on just about anything. If you need to get a refresher on Prometheus as well as some idea about PromQL, head over to the [Prometheus](../201/monitoring/prometheus.md) section. In this case, we will be using a mix of Prometheus and [LinkerD](../ServiceMesh101/what-is-linkerd.md) to scale your KEDA application based on the number of requests it receives. We will be using the version of Prometheus that comes bundled with LinkerD, so you don't have to set up Prometheus in your cluster separately.

## Concept

When LinkerD is installed, it will deploy a sidecar proxy container to run alongside your application container and intercept any request information your application receives. It will then push these metrics to Prometheus every 10 seconds. You can find a list of all metrics LinkerD pushes [here](https://linkerd.io/2.15/reference/proxy-metrics/). We will then implement the KEDA Prometheus plugin to poll Prometheus every 10 seconds, and scale based on the results of polling.

## Requirements

You will of course need a Kubernetes cluster. A cluster such as [Minikube](https://minikube.sigs.k8s.io/docs/start/) will do fine. You then need to set up LinkerD on the cluster, which is a pretty uncomplicated task. Just follow the [doc](https://linkerd.io/2.15/tasks/install/). Make sure you also install [linkerd-viz](https://linkerd.io/2.15/reference/cli/viz/) following the install instructions so that Prometheus gets set up and automatically configured. Once all this is done, start up a simple application like a nginx server:

```
kubectl run nginx-pod --image=nginx --restart=Never --port=80
```

Expose the port:

```
kubectl expose pod nginx-pod --type=NodePort --port=80 --name=nginx-service
```

Check the services from the below command and use the IP of the server to access the nginx server:

```
kubectl get svc
```

Now that nginx is up, let's inject LinkerD to act as a proxy to this server:

```
kubectl get deploy -o yaml | linkerd inject - | kubectl apply -f -
```

The above command will add Linkerd to all pods in the default namespace. If you run a `kubectl describe` you should be able to see there is a Linkerd proxy container in addition to the Nginx container running in your proxy pod.