# The Kubernetes Java client

If you consider the Kubernetes architecture, you will see that there is a Kubernetes API which is called to perform operations on a Kubernetes cluster. Generally, you would use `kubectl` to call this API. However, if you were on something like a Java application and wanted to perform an operation on a Kubernetes API from the Java code, it would be a bit of a hassle to create `ProcessBuilder` objects to execute a kubectl command. Additionally, this would create long and unreadable code that is generally bad for code maintainability in the long run. This is where the various Kubernetes clients that are available for different programming languages come in. These clients are able to do almost everything that the kubectl command can. You can take a look at the list of examples that the Java client has provided [here](https://github.com/kubernetes-client/java/tree/master/examples/examples-release-15/src/main/java/io/kubernetes/client/examples). Note that while it is entirely possible to deploy Java application on Kubernetes clusters, that is not the aim of the client library. The idea here is to control and configure the cluster from within a Java application.

In this case, we will be considering the Java client, although clients for other languages would run in roughly the same manner. To set up the Kubernetes library, we will be using Maven.

## Lab

### Requirements

For starters, you need to have Maven installed. You can download it from [here](https://maven.apache.org/download.cgi). You will also need Java installed. Specifically, you will need Java 17 since the sample Spring application we will be running requires it. You also need a cluster to work with. If you already have a cluster available, you can go ahead and deploy it to this cluster. If not, using [Minikube](https://minikube.sigs.k8s.io/docs/start/) is the fastest and most convenient way to get a simple, one-node cluster up and running on your local machine. You can install it on any platform, and you can use several drivers ranging from Docker to Hyper-V to set up Minikube.

You also need to clean and build the client package after cloning it from GitHub, so let's start with those steps:

```
git clone --recursive https://github.com/kubernetes-client/java
cd java
mvn install
```

Make sure that your JAVA_HOME is set properly or the final command will fail.

### Making the Java project

Now that the prerequisites are complete, you are ready to set up the Kubernetes client on your Java project. For this instance, we will use a Java project that deploys a Spring [pet clinic web app](https://github.com/spring-projects/spring-petclinic). The initial application can be cloned from [this repo](https://github.com/Phantom-Intruder/java-kubeclient). This is the application we will be using as a base for the rest of the lab. Included in the repo is a folder called `configs` which include the deployment and service that needs to be deployed on to your cluster for the application to run. We will not be doing this using the regular `kubectl apply -f deployment.yaml`, instead managing the application using the Java client.

To start off, you need to set up the Kubernetes library you just built. To set up the Kubernetes library, you need to only add the following lines to the pom.xml:

```xml
<dependencies>
    <dependency>
        <groupId>io.kubernetes</groupId>
        <artifactId>client-java</artifactId>
        <version>15.0.1</version>
    </dependency>
</dependencies>
```

Run:

```
mvn clean install
```

This will set up the new Kubernetes dependency, which means that you are now all set up to go. What we want to do first is to create a deployment and a service. There are two ways to achieve this. The Java client is powerful enough that you can create both resources without having to touch an external yaml file by declaring everything you would declare in the Yaml from within the Java code. And example of this can be found [here](https://github.com/kubernetes-client/java/blob/master/examples/examples-release-15/src/main/java/io/kubernetes/client/examples/DeployRolloutRestartExample.java) where a deployment is created, restarted and rolled out from within the code itself. However, understanding and maintaining such syntax can become tedious, which is why the client also allows you to use a pre-existing yaml files and use it to deploy the code from within the Java client. This is done by creating a File object from the yaml file and passing it into the relevant method:

```java
File file = new File("configs/service.yaml");
V1Service yamlSvc = (V1Service) Yaml.load(file);

CoreV1Api api = new CoreV1Api();
V1Service createResult =
        api.createNamespacedService("default", yamlSvc, null, null, null, null);
```

Its also possible to run other types of commands against the cluster. Examples of what can be done along with code examples can be found in the [examples page](https://github.com/kubernetes-client/java/wiki/3.-Code-Examples).