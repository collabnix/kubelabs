## Retrieving logs from Multiple Pods and Containers


If you want to retrieve logs from multiple Pods, you can use the kubectl logs command with the --selector flag to specify a label selector that matches the desired Pods. This allows you to fetch logs from all Pods that match the specified label selector.

Here's an example command to retrieve logs from multiple Pods using a label selector:

```
kubectl logs --selector=app=my-app
```

In this example, app=my-app is the label selector, where app is the label key and my-app is the label value. This command will fetch logs from all Pods that have the label app=my-app.

You can further refine the label selector to match specific criteria or use multiple label selectors to target specific Pods. For example, you can use the following command to fetch logs from Pods that have both app=my-app and environment=production labels:

```
kubectl logs --selector=app=my-app,environment=production
```

By leveraging label selectors, you can efficiently retrieve logs from multiple Pods based on various criteria, such as application name, environment, or any other labels you have assigned to your Pods.
