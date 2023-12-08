# ConfigMaps

ConfigMaps are a fundamental part of any Kubernetes infrastructure. You are unlikely to find any major Kubernetes applications, be it a library, support infrastructure, or cloud provider that doesn't rely on ConfigMaps. So what are they?

[ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/) is simply a key-value store that keeps your data in plain text. This is in contrast to [secrets](../secerts_configmaps101/secrets-configmaps.md) which also do the same thing, but also encrypt your data. As the name implies, you would generally use ConfigMaps to store configurations that would be separate from your actual application. This way, if you wanted to change a configuration (such as an API endpoint your pod was calling), you could do it by simply changing the ConfigMap without having to change the actual application or deployment yaml, thereby removing the need to re-deploy your application once again.

ConfigMaps needs to have a structure that specifies which type of resource it is. For example, the ConfigMap for a MongoDB object would look like this:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-configmap
  namespace: my-namespace
data:
  # Key-value pairs representing configuration data
  DATABASE_URL: "mongodb://localhost:27017/mydatabase"
  API_KEY: "your-api-key-here"
  LOG_LEVEL: "info"
```

As you can see, the `kind: ConfigMap` is specified here and it follows a general Kubernetes resource pattern. However, unlike most other Kubernetes objects, there is a certain amount of flexibility allowed in this resource, where you could define all sorts of things inside the `data` attribute. For example, if you have a MySQL database and you want a SQL command to run when the database starts, you could have that SQL command as a value in the ConfigMap:

```
data:
  initdb.sql: |-
    INSERT INTO users (username, email) VALUES ('john_doe', 'john.doe@example.com');
```

There are numerous examples of different file structures being used within ConfigMaps across Kubelabs. For example, if you look at the [logging section](../Logging101/fluentd.md), you will see that the fluentd configuration file gets defined in a ConfigMaps with its own format. Meanwhile, if you wanted to add a user to an EKS cluster, you would do so by adding the user in a YAML format into the aws_auth ConfigMap. In this manner, just about every type of file can be defined within a ConfigMap.

So now you have a pretty good idea of what ConfigMaps are and what they are capable of, as well as knowledge of how you define them. So let's move on to how you would use a ConfigMap that has already been defined. As a resource that holds multiple values, there are several ways you could use the resource in a pod. One of the most popular methods is to add the ConfigMap as a volume mount. In the deployment yaml, simply specify the name of the ConfigMap as a volume, and your pod would have access to the ConfigMap the same way it would have access to any other volume. Another method of accessing the ConfigMap is to pass it as a command line argument. This is useful if you have multiple ConfigMaps, and which one you want available to your pod gets decided at runtime. You could also have the ConfigMap placed as an environment variable for a container and get it to read the environment variable and subsequently the value from the ConfigMap.

Now that you have a pretty good idea of the flexibility ConfigMaps provide, let's take a look at a full example. We will begin by defining a ConfigMap and then proceed to show all the different ways the ConfigMap can be used in a pod. We will use the same MongoDB example from before:

```
# configmap.yaml

apiVersion: v1
kind: ConfigMap
metadata:
  name: example-configmap
data:
  # Key-value pairs for configuration data
  DATABASE_URL: "mongodb://mongo-server:27017/mydatabase"
  API_KEY: "your_api_key_here"
  DEBUG_MODE: "true"
```

You can see the ConfigMap defined with the database URL, API key, and debug mode turned on. As with all Kubernetes resources, you will have to deploy this file into your cluster:

```
kubectl apply -f configmap.yaml
```

Finally, let's reference it in a sample deployment:

```
# pod.yaml

apiVersion: v1
kind: Pod
metadata:
  name: example-pod
spec:
  containers:
  - name: my-container
    image: your-image
    env:
    - name: DATABASE_URL
      valueFrom:
        configMapKeyRef:
          name: example-configmap
          key: DATABASE_URL
    - name: API_KEY
      valueFrom:
        configMapKeyRef:
          name: example-configmap
          key: API_KEY
    - name: DEBUG_MODE
      valueFrom:
        configMapKeyRef:
          name: example-configmap
          key: DEBUG_MODE
```

In this case, `valueFrom` is used to reference the values from the ConfigMap for each environment variable. Therefore, we are referencing the ConfigMap as env variables. Inside the `valueFrom` key, we also provide the `configMapKeyRef`, with the name of the key being passed in so that the value can be retrieved as a parameter. Since here we only have 3 variables, it wasn't really complicated. However, in a case where there were a large number of vars, you can imagine the deployment yaml would end up getting very repetitive and long, which would eventually make it unreadable. So, let's look at how you can mount the ConfigMap as a volume:

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-container
        image: my-nodejs-app:latest
        env:
        - name: MONGODB_CONFIG_FILE
          value: "/etc/mongodb-config/mongodb-configmap.properties"
        volumeMounts:
        - name: config-volume
          mountPath: "/etc/mongodb-config"
      volumes:
      - name: config-volume
        configMap:
          name: mongodb-configmap

```

In this example, the `MONGODB_CONFIG_FILE` environment variable is set to the path of the file containing the entire ConfigMap. This file will be mounted into the container. A volume is defined with the name `config-volume` and is associated with the ConfigMap `mongodb-configmap`. This volume is mounted into the container at the path `/etc/mongodb-config`. This way, there will be no repetition and all of the environment variables would still be accessible.

You could also safely remove the `env` key and still have all the data in the ConfigMap accessible:

```
containers:
- name: mongodb
  image: mongo:latest
  ports:
  - containerPort: 27017
  volumeMounts:
  - name: mongodb-config-volume
    mountPath: /etc/mongod
volumes:
- name: mongodb-config-volume
  configMap:
    name: mongodb-config
```

The above method will make the ConfigMap be considered as a volume instead of having it entered as an environment variable. This means that if you were to update the ConfigMap while the container was running, the container would take the new values immediately. On the other hand, if you had loaded them up as environment variables, you would have to restart the container since the variables are assigned during pod startup. Or you could directly inject the values from the ConfigMap into your container environment using the `envFrom` key:

```
containers:
- name: mongodb
  image: mongo:latest
  ports:
  - containerPort: 27017
  envFrom:
  - configMapRef:
      name: mongodb-config
```

In this version, the envFrom field is used to directly reference the ConfigMap. This will inject all the key-value pairs from the ConfigMap as environment variables into the container.

You can also load the ConfigMap as a command line argument in a deployment yaml. You do this using the `command` key. For example:

```
containers:
    - name: mongodb
      command: ["mongo", "--database-host", "$(DATABASE_URL)"]
      image: mongo:latest
      env:
        - name: DATABASE_URL
          valueFrom:
            configMapKeyRef:
              name: example-configmap
              key: DATABASE_URL
```

This command runs when the pod starts, meaning that the value will be extracted from the ConfigMap at this point.

Now that we have looked at various ways we can reference an existing ConfigMap, let's look at all the ways we can create a ConfigMap. The first method is to declare it in a yaml file, which is the example that has been used so far. However, there is also a way to define it in line with a `kubectl create configmap` command:

```
kubectl create configmap example-configmap –from-literal=DATABASE_URL="mongodb://mongo-server:27017/mydatabase" –from-literal=API_KEY"your_api_key_here" –from-literal=DEBUG_MODE="true"
```

This would create the same ConfigMap as the one we had defined before. As you can see, the longer the ConfigMap, the longer the command will be. And this ConfigMap with 3 values is itself a pretty messy command, which is why defining it as a yaml is always better. However, there are some use cases where the above method would be preferred. For example, if you wanted to auto-generate a bunch of ConfigMaps and create them in the cluster with a script, or you have a dynamic ConfigMap that changes during deployment time.

You have already seen how you can define a ConfigMap using a yaml file. However, you can also create a ConfigMap from any other file type as well, such as a text file. You do this using a command similar to the above one, and it automatically creates a resource of kind ConfigMap that has the contents of the file you specified as its data:

```
kubectl create configmap example-configmap –from-file=key1=mongodb.txt
```

List the ConfigMaps:

```
kubectl get configmaps
```

You can then describe the ConfigMap to see its full resource definition:

```
kubectl describe configmap example-configmap
```

Next, let's quickly look at immutable ConfigMaps. If you don't want the contents of a ConfigMap to be changed after you deploy it, you can add the key `immutable` at the root level of the ConfigMap yaml, and it will throw a forbidden error if you try to change the existing ConfigMap. If you want to change the resource from this point forward, you will have to delete the old resource and create a new one.

So, as you can see, there is a lot of flexibility when it comes to what you can define inside a ConfigMap, as well as in the ways you can refer to the ConfigMap. It's a very simple, yet very useful resource. As you progress along Kubernetes, you will constantly come across this particular resource, so make sure you understand it well before moving ahead to more complex resources.