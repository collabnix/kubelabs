# Kubernetes CRUD using Python


Kubernetes is a popular container orchestration platform that provides a powerful API for managing containerized applications. The Kubernetes API is a RESTful interface that allows you to interact with Kubernetes clusters programmatically. In this blog post, we will explore how to access Kubernetes API using Python.

## Prerequisites

Before we get started, you will need the following:

- A Kubernetes cluster
- Python installed on your local machine
- The kubernetes Python package installed

## Enabling Kubernetes under Docker Desktop


![Image1](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/cni9vvba9uanvzl0kujw.png)

##  Installing Kubernetes package using PIP

```shell
 pip3 install kubernetes
```

First, you need to install the kubernetes package using pip. You can do this by running the following command in your terminal:


## Listing the Kubernetes Nodes

```shell
kubectl get nodes
NAME             STATUS   ROLES           AGE     VERSION
docker-desktop   Ready    control-plane   7d18h   v1.25.4
ajeetsraina@Ajeets-MacBook-Pro ~ %
```

## Deploying hellowhale app

```shell
kubectl create deployment hellowhale --image ajeetraina/hellowhale
deployment.apps/hellowhale created
```

## Listing the Deployment
```
kubectl get deploy
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
hellowhale   1/1     1            1           12s
```


## Accessing the Deployment using Python

To get started, you need to configure the client to connect to your Kubernetes cluster. You can do this using the config.load_kube_config() method, which loads the Kubernetes configuration from the default configuration file located at $HOME/.kube/config. If you are using a different configuration file or a different location, you can pass the path to the configuration file to the config.load_kube_config() method.

Here is an example of how to configure the client:

```
from kubernetes import client, config

config.load_kube_config()
api = client.CoreV1Api()
```

This code loads the Kubernetes configuration from the default configuration file and creates a CoreV1Api object, which provides access to the Kubernetes API.

## Listing all the deployments in the default namespace

To list all the deployments in the default namespace, you can use the AppsV1Api().list_namespaced_deployment(namespace) method:

```
from kubernetes import client, config

config.load_kube_config()
api = client.AppsV1Api()

deployments = api.list_namespaced_deployment(namespace='default')
for deployment in deployments.items:
    print(deployment.metadata.name)
```

This will print the names of all the deployments in the default namespace.

```
python3 fetch.py
hellowhale
ajeetsraina@Ajeets-MacBook-Pro ~ % cat fetch.py
from kubernetes import client, config

config.load_kube_config()
api = client.AppsV1Api()

deployments = api.list_namespaced_deployment(namespace='default')
for deployment in deployments.items:
    print(deployment.metadata.name)
```


## Creating Kubernetes Objects

To create a new Kubernetes object, you can use the appropriate class from the kubernetes.client module and call the appropriate method on the API object.

For example, to create a new deployment, you can use the AppsV1Api().create_namespaced_deployment(namespace, body) method:

```bash
from kubernetes import client, config

config.load_kube_config()
api = client.AppsV1Api()

deployment = client.V1Deployment(
    api_version="apps/v1",
    kind="Deployment",
    metadata=client.V1ObjectMeta(
        name="my-deployment"
    ),
    spec=client.V1DeploymentSpec(
        replicas=3,
        selector=client.V1LabelSelector(
            match_labels={
                "app": "my-app"
            }
        ),
        template=client.V1PodTemplateSpec(
            metadata=client.V1ObjectMeta(
                labels={
                    "app": "my-app"
                }
            ),
            spec=client.V1PodSpec(
                containers=[
                    client.V1Container(
                        name="my-container",
                        image="nginx"
                    )
                ]
            )
        )
    )
)

api.create_namespaced_deployment(namespace='default', body=deployment)
```

This will create a new deployment called my-deployment with three replicas of the Nginx container.

```
kubectl get po,deploy,svc
NAME                                READY   STATUS    RESTARTS   AGE
pod/hellowhale-66b5557c4c-b9nsk     1/1     Running   0          8m22s
pod/my-deployment-b779fc99c-6rkvg   1/1     Running   0          21s
pod/my-deployment-b779fc99c-cb9f6   1/1     Running   0          21s
pod/my-deployment-b779fc99c-vj8hn   1/1     Running   0          21s

NAME                            READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/hellowhale      1/1     1            1           8m22s
deployment.apps/my-deployment   3/3     3            3           21s

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   7d18h
ajeetsraina@Ajeets-MacBook-Pro ~ %
```

## Updating Kubernetes Objects

To update an existing Kubernetes object, you can use the appropriate class from the kubernetes.client module and call the appropriate method on the API object.

For example, to update the number of replicas in a deployment, you can use the `Apps' V1Api().patch_namespaced_deployment(namespace, name, body)` method:

```
from kubernetes import client, config

config.load_kube_config()
api = client.AppsV1Api()

deployment = api.read_namespaced_deployment(name='my-deployment', namespace='default')
deployment.spec.replicas = 5

api.patch_namespaced_deployment(name='my-deployment', namespace='default', body=deployment)
```

This will update the number of replicas in the my-deployment deployment to 5.

```
kubectl get po,deploy,svc
NAME                                READY   STATUS    RESTARTS   AGE
pod/hellowhale-66b5557c4c-b9nsk     1/1     Running   0          10m
pod/my-deployment-b779fc99c-67clb   1/1     Running   0          7s
pod/my-deployment-b779fc99c-6rkvg   1/1     Running   0          2m43s
pod/my-deployment-b779fc99c-8vw96   1/1     Running   0          7s
pod/my-deployment-b779fc99c-cb9f6   1/1     Running   0          2m43s
pod/my-deployment-b779fc99c-vj8hn   1/1     Running   0          2m43s

NAME                            READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/hellowhale      1/1     1            1           10m
deployment.apps/my-deployment   5/5     5            5           2m43s

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   7d18h
ajeetsraina@Ajeets-MacBook-Pro ~ %
```

## Deleting Kubernetes Objects

To delete a Kubernetes object, you can use the appropriate class from the kubernetes.client module and call the appropriate method on the API object.

For example, to delete a deployment, you can use the AppsV1Api().delete_namespaced_deployment(name, namespace) method:

```
from kubernetes import client, config

config.load_kube_config()
api = client.AppsV1Api()

api.delete_namespaced_deployment(name='my-deployment', namespace='default')
```

This will delete the my-deployment deployment.

```
kubectl get po,svc,deploy
NAME                              READY   STATUS    RESTARTS   AGE
pod/hellowhale-66b5557c4c-b9nsk   1/1     Running   0          13m

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   7d18h

NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/hellowhale   1/1     1            1           13m
ajeetsraina@Ajeets-MacBook-Pro ~ %
```

## Conclusion

In this blog post, we have explored how to access the Kubernetes API using Python. We covered how to configure the client, how to get, create, update, and delete Kubernetes objects. The kubernetes package provides a Pythonic interface to the Kubernetes API, making it easy to work with Kubernetes resources from within your Python code.

While this blog post provides a brief introduction to accessing the Kubernetes API with Python, there is much more that can be done. The Kubernetes API provides a rich set of features for managing containerized applications, and the kubernetes package provides a comprehensive set of classes and methods for interacting with the API. With the knowledge and tools presented here, you can begin building your own Python scripts and applications for managing your Kubernetes clusters.
