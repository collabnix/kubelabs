# Chaos Mesh

Chaos Mesh is a popular chaos testing tool specially built with Kubernetes in mind. The different types of chaos testing it allows are massive, and you can get a full list in the [official docs](https://chaos-mesh.org/docs/simulate-pod-chaos-on-kubernetes/). We will focus primarily on pod chaos in this lab. To start, let's define our objectives.

First, we will have one or more pods forcefully killed (in a non-graceful manner). We then want to see if new pods come up immediately to replace the pods that were killed & how long it takes for the new pods to come up. Once we have achieved this goal, we will look at automating the whole process like so:

- Before running the test, a new replica is created to minimize business disruption
- At a specified time during the week, a pod is killed as part of the test
- A script watches and waits to see if the replacement pod starts up
- If everything is fine, send an email or message to Slack to notify that the test succeeded, then get rid of the additional replica
- If it didn't work as expected, keep the additional replica and send out an alert that scaling isn't working

All of the above steps will be completely automated so that you can have several applications running chaos tests (preferably outside of peak business hours).

First, install Chaos mesh into your cluster with Helm:

```
helm repo add chaos-mesh https://charts.chaos-mesh.org
kubectl create ns chaos-mesh
helm install chaos-mesh chaos-mesh/chaos-mesh
```

Now, let's startup a basic nginx server


Start the pod running nginx

```
kubectl run --image=nginx nginx-app --port=80 --replicas=2
```

Accessing the app on browser

```
kubectl port-forward nginx-app 80:80
```

Now that we have a target to test chaos on, let's define a basic pod kill chaos in a file called "pod-kill.yaml":

```
apiVersion: chaos-mesh.org/v1alpha1
kind: PodChaos
metadata:
  name: pod-kill
spec:
  action: pod-kill
  mode: one
  selector:
    labelSelectors:
      app: nginx
  duration: 30s
```

Now deploy this to Kubernetes:

```
kubectl apply -f podkill.yaml
```

Immediately upon deployment, you should see one of the two replicas get killed. You can use `kubectl get po --watch` to see this happen in real-time. You can then continue to observe as the pod recovers from this incident and determine whether it recovered within the appropriate time. The next step is to automate all this so that you can handle the deployment and observability part on your behalf. For this, we will use a script stored in a ConfigMap and a CronJob that periodically triggers this script.