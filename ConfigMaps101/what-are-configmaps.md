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