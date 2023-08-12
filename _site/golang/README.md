
# Kubernetes CRUD using Go

Kubernetes is a popular container orchestration platform used by developers to deploy and manage their applications. While Kubernetes provides a powerful command-line interface called kubectl for managing Kubernetes resources, it can also be accessed programmatically using various programming languages such as Python, Go, and Java.

In this blog post, we will focus on using Go to perform CRUD (Create, Read, Update, and Delete) operations on Kubernetes resources. Specifically, we will demonstrate how to perform CRUD operations on deployments using the Kubernetes API and the official Go client library. We will be performing these operations on a local Kubernetes cluster running on Docker Desktop.

## Prerequisites

Before we start, make sure you have the following prerequisites:

- Docker Desktop installed
- Go installed
- A basic understanding of Kubernetes concepts such as deployments and pods

## Setting up the Go environment

To get started, we need to set up our Go environment. We will first create a new directory for our project and initialize a new Go module:

```sh
mkdir kubernetes-go && cd kubernetes-go
go mod init github.com/<username>/kubernetes-go
```

Next, we need to install the k8s.io/client-go package, which provides a client library for accessing the Kubernetes API:

```sh
go get k8s.io/client-go@v0.22.2
```

## Creating a deployment

Let's start by creating a deployment using Go. In Kubernetes, a deployment is used to manage a set of replica pods. We will create a deployment that manages a single pod running an Nginx web server.

First, create a new file called create_deployment.go and add the following code:

```go
package main

import (
    "fmt"
    "os"

    "k8s.io/client-go/kubernetes"
    "k8s.io/client-go/rest"
    "k8s.io/client-go/util/retry"
    appsv1 "k8s.io/api/apps/v1"
)

func main() {
    // create a Kubernetes client
    config, err := rest.InClusterConfig()
    if err != nil {
        panic(err.Error())
    }
    clientset, err := kubernetes.NewForConfig(config)
    if err != nil {
        panic(err.Error())
    }

    // create the deployment object
    deployment := &appsv1.Deployment{
        ObjectMeta: metav1.ObjectMeta{
            Name: "nginx-deployment",
        },
        Spec: appsv1.DeploymentSpec{
            Replicas: int32Ptr(1),
            Selector: &metav1.LabelSelector{
                MatchLabels: map[string]string{
                    "app": "nginx",
                },
            },
            Template: corev1.PodTemplateSpec{
                ObjectMeta: metav1.ObjectMeta{
                    Labels: map[string]string{
                        "app": "nginx",
                    },
                },
                Spec: corev1.PodSpec{
                    Containers: []corev1.Container{
                        {
                            Name:  "nginx",
                            Image: "nginx:latest",
                            Ports: []corev1.ContainerPort{
                                {
                                    ContainerPort: 80,
                                },
                            },
                        },
                    },
                },
            },
        },
    }

    // create the deployment
    retryErr := retry.RetryOnConflict(retry.DefaultRetry, func() error {
        _, err := clientset.AppsV1().Deployments("default").Create(deployment)
        return err
    })
    if retryErr != nil {
        fmt.Fprintf(os.Stderr, "Failed to create deployment: %v\n", retryErr)
        os.Exit(1)
    }

    fmt.Println("Deployment created successfully!")
}

func int32Ptr(i int32) *int32 { return &i }
```

In this script, we first import the necessary packages, including k8s.io/client-go/kubernetes, which provides the clientset for accessing the Kubernetes API. We also import the appsv1 package, which defines the Deployment resource.

Next, we create a Kubernetes client using the rest.InClusterConfig() function, which returns a *rest.Config object containing the configuration for accessing the Kubernetes API server. We use this config to create a new kubernetes.Interface clientset.

We then create a new Deployment object with the desired specifications, including the number of replicas, the pod selector, and the container specifications. The retry.RetryOnConflict() function is used to ensure that we can safely create the deployment in case of conflicts with existing resources.

Finally, we call the Create() function on the Deployments client with the newly created Deployment object to create the deployment on the Kubernetes cluster.

To run this script, simply execute the following command:

```sh
go run create_deployment.go
```

This will create a new deployment called nginx-deployment with a single replica running the Nginx web server.

## Updating a deployment

Now let's update the deployment we just created. We will update the image used by the Nginx container to a newer version.

Create a new file called update_deployment.go and add the following code:

```go
package main

import (
    "fmt"
    "os"

    "k8s.io/client-go/kubernetes"
    "k8s.io/client-go/rest"
    "k8s.io/client-go/util/retry"
    appsv1 "k8s.io/api/apps/v1"
)

func main() {
    // create a Kubernetes client
    config, err := rest.InClusterConfig()
    if err != nil {
        panic(err.Error())
    }
    clientset, err := kubernetes.NewForConfig(config)
    if err != nil {
        panic(err.Error())
    }

    // get the deployment object
    deployment, err := clientset.AppsV1().Deployments("default").Get("nginx-deployment", metav1.GetOptions{})
    if err != nil {
        fmt.Fprintf(os.Stderr, "Failed to get deployment: %v\n", err)
        os.Exit(1)
    }

    // update the deployment
    deployment.Spec.Template.Spec.Containers[0].Image = "nginx:1.21.1"

    retryErr := retry.RetryOnConflict(retry.DefaultRetry, func() error {
        _, updateErr := clientset.AppsV1().Deployments("default").Update(deployment)
        return updateErr
    })
    if retryErr != nil {
        fmt.Fprintf(os.Stderr, "Failed to update deployment: %v\n", retryErr)
        os.Exit(1)
    }

    fmt.Println("Deployment updated successfully!")
}
```

In this script, we first get the existing deployment object using the Deployments().Get() function. We then update the image used by the Nginx container to version 1.21.1.

We then use the retry.RetryOnConflict() function again to ensure that we can safely update the deployment.

Finally, we call the Update() function on the Deployments client with the updated Deployment object to update the deployment on the Kubernetes cluster.

To run this script, simply execute the following command:

```sh
go run update_deployment.go
```
This will update the existing nginx-deployment with the new image.

Scaling a deployment
Next, let's scale the deployment we just updated. We will increase the number of replicas from 1 to 3.

Create a new file called `scale_deployment.go` and add the following code:

```go
package main

import (
    "fmt"
    "os"

    "k8s.io/client-go/kubernetes"
    "k8s.io/client-go/rest"
    "k8s.io/client-go/util/retry"
    appsv1 "k8s.io/api/apps/v1"
)

func main() {
    // create a Kubernetes client
    config, err := rest.InClusterConfig()
    if err != nil {
        panic(err.Error())
    }
    clientset, err := kubernetes.NewForConfig(config)
    if err != nil {
        panic(err.Error())
    }

    // get the deployment object
    deployment, err := clientset.AppsV1().Deployments("default").Get("nginx-deployment", metav1.GetOptions{})
    if err != nil {
        fmt.Fprintf(os.Stderr, "Failed to get deployment: %v\n", err)
        os.Exit(1)
    }

    // scale the deployment
    replicas := int32(3)
    deployment.Spec.Replicas = &replicas

    retryErr := retry.RetryOnConflict(retry.DefaultRetry, func() error {
        _, updateErr := clientset.AppsV1().Deployments("default").Update(deployment)
        return updateErr
    })
    if retryErr != nil {
        fmt.Fprintf(os.Stderr, "Failed to scale deployment: %v\n", retryErr)
        os.Exit(1)
    }

    fmt.Println("Deployment scaled successfully!")
}
```

In this script, we first get the existing deployment object using the Deployments().Get() function. We then set the number of replicas to 3.

We then use the retry.RetryOnConflict() function again to ensure that we can safely update the deployment.

Finally, we call the Update() function on the Deployments client with the updated Deployment object to scale the deployment on the Kubernetes cluster.

To run this script, simply execute the following command:

```sh
go run scale_deployment.go
```

This will scale the existing nginx-deployment to 3 replicas.

## Deleting a deployment

Finally, let's delete the deployment we just scaled.

Create a new file called delete_deployment.go and add the following code:

```go
package main

import (
    "fmt"
    "os"

    "k8s.io/client-go/kubernetes"
    "k8s.io/client-go/rest"
    metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func main() {
    // create a Kubernetes client
    config, err := rest.InClusterConfig()
    if err != nil {
        panic(err.Error())
    }
    clientset, err := kubernetes.NewForConfig(config)
    if err != nil {
        panic(err.Error())
    }

    // delete the deployment
    err = clientset.AppsV1().Deployments("default").Delete("nginx-deployment", &metav1.DeleteOptions{})
    if err != nil {
        fmt.Fprintf(os.Stderr, "Failed to delete deployment: %v\n", err)
        os.Exit(1)
    }

    fmt.Println("Deployment deleted successfully!")
}
```

In this script, we simply call the Delete() function on the Deployments client with the name of the deployment we want to delete.

To run this script, simply execute the following command:

```sh
go run delete_deployment.go
```

This will delete the existing nginx-deployment from the Kubernetes cluster.

## Conclusion

In this blog post, we have learned how to perform CRUD operations on Kubernetes resources programmatically using Go on Docker Desktop. We have covered how to create, update, retrieve, scale, and delete a deployment using the Kubernetes API and the client-go library in Go.

Using the Kubernetes API programmatically allows us to automate the management of our Kubernetes resources and integrate them into our applications and workflows. This is particularly useful when dealing with large-scale Kubernetes clusters and complex deployment scenarios.

In addition, we have demonstrated how to run these scripts on a local Kubernetes cluster using Docker Desktop, which allows developers to test their code in a development environment before deploying to a production cluster.

We hope that this blog post has provided you with a solid foundation for working with the Kubernetes API and client-go library in Go, and that it will help you automate your Kubernetes workflows and streamline your operations.
