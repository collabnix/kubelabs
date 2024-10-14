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
helm install chaos-mesh chaos-mesh/chaos-mesh -n chaos-mesh --version 2.6.3 --set chaosDaemon.runtime=containerd
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

First, we will need an image that has both curl & kubectl. In an enterprise environment, you should create this image yourself by building a Docker image with the necessary tools, and then pushing it into your organization's private repo. This is because publicly available images could get vulnerabilities, get deleted without your knowledge, or exceed your repo pull count which will lead to new images not being pulled. In a testing situation, however, feel free to use an image on Docker Hub with both tools involved. We will be using `tranceh2/bash-curl-kubectl`.

Next, will be creating the script that performs the Chaos test with re-usability in mind. This means using arguments to pass information such as deployment name, namespace, and chaos type. Since we will be alerting the status of the report to a Slack channel, we should also pass the Slack webhook URL in this manner. It is best to use a secret to store the webhook URL, and then reference the secret as an env variable. The script itself will be created inside a ConfigMap that will then be mounted to the pod created by the CronJob as a volume. As a final touch, we set the restart policy to `Never` since we don't want a job the introduces chaos restarting indefinitely and accidently firing during peak times. Below is the finalized script.

```
apiVersion: batch/v1
kind: CronJob
metadata:
  name: pod-chaos-test
  namespace: default
spec:
  schedule: "5 5 * * 2" # At 5:05 AM on Tuesday
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: chaos-test
            image: tranceh2/bash-curl-kubectl
            command:
            - /bin/sh
            - -c
            - |
              cp /scripts/chaos.sh /tmp/chaos.sh
              chmod +x /tmp/chaos.sh
              /tmp/chaos.sh deployment namespace namespace pod-kill $SLACK_WEBHOOK_URL
            volumeMounts:
            - name: chaos-script
              mountPath: /scripts
            env:
            - name: SLACK_WEBHOOK_URL
              valueFrom:
                secretKeyRef:
                  name: slack-webhook-secret
                  key: SLACK_WEBHOOK_URL
          restartPolicy: Never
          volumes:
          - name: chaos-script
            configMap:
              name: chaos-script
```

The above job should call the template responsible for running the chaos deployment. Now, let's look at the script itself. For the script, we will use `kubectl patch` to temporarily increase the replica count, followed by `kubectl apply` to apply the chaos. Next, we will use `kubectl wait` to see if the pod returns and the required replica count is maintained. The result will then be sent to Slack with a curl command. Finally, we will use a `kubectl patch` command to restore the number of replicas to their initial count and delete the chaos object that gets created. Below is the scrcipt will all the mentioned items: 

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: chaos-script
  namespace: default
data:
  chaos.sh: |
    #!/bin/bash

    # Define variables from arguments
    DEPLOYMENT_NAME=$2
    NAMESPACE=$3
    CHAOS_NAMESPACE=$4
    CHAOS_NAME=$5
    SLACK_WEBHOOK_URL=$6

    # Get current replica count
    current_replicas=$(kubectl get deployment $DEPLOYMENT_NAME -n $NAMESPACE -o jsonpath='{.spec.replicas}')

    echo "Current replicas = $current_replicas"

    # Increase replica count by 1
    new_replicas=$((current_replicas + 1))

    kubectl patch deployment $DEPLOYMENT_NAME --type='json' -p='[{"op": "replace", "path": "/spec/replicas", "value": $new_replicas}]'

    # Wait for the new pod to be created and the container to be ready
    start_time=$(date +%s)

    kubectl wait --for=condition=available --timeout=300s deployment/$DEPLOYMENT_NAME -n $NAMESPACE

    echo "Delete chaos"

    kubectl delete PodChaos $CHAOS_NAME -n $CHAOS_NAMESPACE | true

    echo "Applying chaos"

    # Apply chaos mesh job
    kubectl apply -f - <<EOF
    apiVersion: chaos-mesh.org/v1alpha1
    kind: PodChaos
    metadata:
      name: $CHAOS_NAME
      namespace: $CHAOS_NAMESPACE
    spec:
      action: pod-kill
      mode: one
      selector:
        labelSelectors:
          app: $DEPLOYMENT_NAME
      duration: 30s
    EOF

    # Wait for chaos to complete and check if the deployment recovers
    echo "Waiting until pod recovers"

    if kubectl wait --for=condition=available --timeout=300s deployment/$DEPLOYMENT_NAME -n $NAMESPACE; then
        curl -X POST -H 'Content-type: application/json' --data '{"text":"$DEPLOYMENT_NAME Pod recovery successful within 2.5 mins."}' $SLACK_WEBHOOK_URL
    else
        curl -X POST -H 'Content-type: application/json' --data '{"text":"$DEPLOYMENT_NAME Pod recovery failed"}' $SLACK_WEBHOOK_URL
    fi

    kubectl patch deployment $DEPLOYMENT_NAME --type='json' -p='[{"op": "replace", "path": "/spec/replicas", "value": $current_replicas}]'

    echo "Delete chaos"

    kubectl delete PodChaos $CHAOS_NAME -n $CHAOS_NAMESPACE
```

Let's go step by step. This script increases the number of replicas by 1 and waits for it to fully start. Once it is ready, it deletes any hanging chaos objects and applies the chaos yaml to kill 1 pod, then waits again for the pod to recover. If the pod hasn't recovered in 300 seconds, it informs that to Slack and exits. Else it sends a success message and reduces the deployment count back to the original number. Finally, it deletes the pod chaos.

Apply the above files to your Kubernetes cluster using `kubectl apply`, then manually trigger the Cron job. You can see the job that runs with:

```
kubectl get jobs
```

Find the name of the job that is running the chaos test and use:

```
kubectl logs <job-name>
```

To see the chaos test as it happens. Also use:

```
kubectl get pods -A --watch
```

Keep an eye on the pods as they get killed and auto-recover. Once the test is done, it will send a message with the status to Slack.

This covers pod kill chaos and how we can automate it end to end. Now, let's take a look at two other types of Chaos: memory chaos and CPU chaos.

## Resource chaos

Killing a pod was the most basic type of chaos out there. When it comes to resource-based chaos, Chaos Mesh injects processes into a running container to give it Chaos, requiring several new permissions and configurations. First, when we installed Chaos Mesh, we used `chaosDaemon.runtime=containerd`. This is needed since by default, this value is set to `docker`. Next, we need to watch the chaos deployments as they happen since it is likely that all the requirements required by the chaos are not available in your cluster.

Now that we have a general idea of what to look out for, let's start with CPU chaos. Unlike pod chaos where there is a recovery after the chaos ends, there is no such recovery event for CPU chaos. Since CPU is very flexible, Kubernetes will allow the CPU requirements to go until the node has no more CPU left. At this point, your application will get CPU throttled. So instead in this section, we will create a system with a CPU-based HPA. To get an in-depth idea of HPAs, go to the [scaling section](../Autoscaler101/what-are-autoscalers.md).