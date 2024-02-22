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

The above is a rather basic implementaion of an nginx server with 3 replicas, and allows connections on port 80. For starters, let's create a Helm chart from this nginx application.

For starters, let's create the Helm chart. Go into a folder you plan to run this from and type:

```
helm create nginx-chart
```

This will create a chart with the basic needed files. The directory structure should look like this:

```
nginx-chart/
├── Chart.yaml
├── templates
│   ├── deployment.yaml
│   └── service.yaml
└── values.yaml
```

By looking at the above structure, you should be able to see where the deployment and service yamls fit in. You will see that there are sample yamls created here. However, you will also notice that these yamls are go templates which have placeholders instead of hardcoded values. We will be converting our existing yamls into this format. But first, update the Chart.yaml file to include relevant metadata for nginx if you require so. Generally, the default Chart.yaml is fine.

Modify values.yaml: Add any configurable values that you want to expose to users. In this case, you might want to allow users to specify the number of replicas for the Deployment.

Create Templates:

deployment.yaml: Convert the Deployment YAML into a Helm template file, deployment.yaml. Use Helm templating to substitute values from values.yaml.
service.yaml: Convert the Service YAML into a Helm template file, service.yaml. Again, use Helm templating where necessary.
Here's how the directory structure might look:

nginx-chart/
├── Chart.yaml
├── templates
│   ├── deployment.yaml
│   └── service.yaml
└── values.yaml

```
apiVersion: v2
name: nginx-chart
description: A Helm chart for deploying Nginx service and deployment
version: 0.1.0
```

```
replicaCount: 3
image:
  repository: nginx
  tag: latest
  pullPolicy: IfNotPresent
```

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "nginx-chart.fullname" . }}
  labels:
    app: nginx
spec:
  replicas: {{ .Values.replicaCount }}
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
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        ports:
        - containerPort: 80
```

```
apiVersion: v1
kind: Service
metadata:
  name: {{ include "nginx-chart.fullname" . }}
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP
```

With this structure, users can now install your Helm chart, and they'll be able to customize the number of replicas and the Nginx image tag through the values.yaml file.

Now, let's move on to Chart hooks.

[Next: Chart Hooks](chart-hooks.md)