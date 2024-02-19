# Helm templates

In even a small-scale organization, you would have at least a couple of applications that work together inside a Kubernetes cluster. This means you would have a minimum of 5-6 microservices. As your organization grows, you could go on the have 10, then 20, even 50 microservices, at which point a problem arises: the deployment manifests. Handling just one or two is fairly simple, but when it comes to several dozen, updating and adding new manifests can be a real problem. If you have a separate git repository for each microservice, you will likely want to keep each deployment yaml within the repo. If this is a regular organization that follows best practices, you will be required to create pull requests and have them reviewed before you merge to master. This means if you want to do something as simple as change the image pull policy for several microservices, you will have to make the change in each repo, create a pull request, have it reviewed by someone else, and then merge the changes. This is a pretty large number of steps that a Helm template can reduce to just 1.

To start, we will need a sample application. We could use the same charts that we used in the previous section, but instead let's go with a new application altogether: nginx.

This will be our starting point:

```
# nginx-deployment.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```

```
# nginx-service.yaml

apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP

```


Now, let's move on to Chart hooks.

[Next: Chart Hooks](chart-hooks.md)