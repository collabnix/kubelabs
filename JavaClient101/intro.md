# The Kubernetes Java client

If you consider the Kubernetes architecture, you will see that there is a Kubernetes API which is called to perform operations on a Kubernetes cluster. Generally, you would use `kubectl` to call this API. However, if you were on something like a Java application and wanted to perform an operation on a Kubernetes API from the Java code, it would be a bit of a hassle to create `ProcessBuilder` objects to execute a kubectl command. Additionally, this would create long and unreadable code that is generally bad for code maintainability in the long run. This is where the various Kubernetes clients that are available for different programming languages come in.

In this case, we will be considering the Java client, although clients for other languages would run in roughly the same manner. To set up the Kubernetes library, we will be using Maven.

## Lab

### Requirements

For starters, you need to have Maven installed. You can download it from [here](https://maven.apache.org/download.cgi). You will also need Java installed. This lab will be using JDK 11. You also need a cluster to work with. If you already have a cluster available, you can go ahead and deploy it to this cluster. If not, using [Minikube](https://minikube.sigs.k8s.io/docs/start/) is the fastest and most convenient way to get a simple, one-node cluster up and running on your local machine. You can install it on any platform, and you can use several drivers ranging from Docker to Hyper-V to set up Minikube.

You also need to clean and build the client package after cloning it from GitHub, so let's start with those steps:

```
git clone --recursive https://github.com/kubernetes-client/java
cd java
mvn install
```

Make sure that your JAVA_HOME is set properly or the final command will fail.

### Making the Java project

Now that the prerequisites are complete, you are ready to set up the Kubernetes client on your Java project. However, you don't have a Java project right now, so let's focus on creating one.

To set up the Kubernetes library, you need to only add the following lines to your pom.xml:

```xml
<dependency>
    <groupId>io.kubernetes</groupId>
    <artifactId>client-java</artifactId>
    <version>15.0.1</version>
</dependency>
```