
# Secrets & ConfigMaps

Kubernetes has two types of objects that can be used to inject configuration data into a container when it starts up: 
- Secrets and 
- ConfigMaps

We will explore both Secrets and ConfigMaps with a real-world situation:

## Secrets:

Secrets are a Kubernetes object intended for storing a small amount of sensitive data. It is worth noting that Secrets are stored base64-encoded within Kubernetes, so they are not wildly secure. Make sure to have appropriate Role-base access controls (or RBAC) to protect access to secrets. These are a way store things that you do not want floating around in your code.

## Creating a Secret manually:

first execute the script which is present on the directory script and craete the certs and keys 

```
kubectl create secret tls nginx-certs --cert=tls.crt --key=tls.key
secret/nginx-certs created
```

```
swapnasagars-MacBook-Pro:~ swapnasagar$ kubectl get secrets
NAME                  TYPE                                  DATA   AGE
default-token-xf2f4   kubernetes.io/service-account-token   3      3d23h
nginx-certs           kubernetes.io/tls                     2      24s
```

Now that the secret is created, use kubectl describe to see it.

```
swapnasagars-MacBook-Pro:~ swapnasagar$ kubectl describe secret nginx-certs
Name:         nginx-certs
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/tls

Data
====
tls.crt:  1107 bytes
tls.key:  1704 bytes
```

Note the Data field contains the key we created earlier, note the vaule what we assigned, it is not shown in the output and only you can see the size of the value.

## ConfigMaps:

ConfigMaps are similar to Secrets. They can be created in the same ways, and can be shared in the containers the same ways. The only big difference between them is the base64 encoding obfuscation. ConfigMaps are intended to non-sensitive data - configuration data - like config files and environment variables, and are a great way to create customized running services from generic container images.

## Create a ConfigMap:

ConfigMaps can be created the same ways Secrets are. A YAML representation of the ConfigMap can be written manually and loaded it into Kubernetes, or the kubectl create configmap command can be used to create it from the command line.

Create a custom nginx file and we are going to create the configmap, which is present on the directory which is named as nginx-custom.conf

### Create the configmaps

```
kubectl create configmap nginx-config --from-file nginx-custom.conf
```

View the new ConfigMap and read the data

```
kubectl get configmaps
```

## To get the both secrets and configmaps

```
kubectl get secrets,configmaps
```

## Using Secrets and ConfigMaps:

Secrets and ConfigMaps can be mounted as volume within a pod. For the nginx pod, we will need to mount the secrets as nginx-certs, and the ConfigMap as a nginx-config. First, thoug, we need to write a Deployment for nginx, so we have something to work with. Create a file named "nginx-ssl-deployment.yaml" with the following:

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      volumes:
      - name: certs-volume
        secret:
          secretName: nginx-certs
      - name: config-volume
        configMap:
          name: nginx-config
      containers:
      - name: nginx
        image: nginx:1.9.1
        ports:
        - containerPort: 443
        - containerPort: 80
        volumeMounts:
        - mountPath: /certs
          name: certs-volume
        - mountPath: /etc/nginx/conf.d
          name: config-volume
```

Both Secrets and ConfigMaps be the source of Kubernetes "volumes" and mounted into the containers.The volumeMount is pretty self-explanitory here - create a volume mount the "certs-volume and config-volume" (specified in the volumes list, below it) to the path /etc/nginx/conf.d and /certs respectivly.

## Deploy nginx with ssl mode

```
kubectl create -f nginx-ssl-deployment.yaml
kubectl get pods -w 
kubectl describe pod <pod name>
kubectl exec -it <pod name> /bin/sh`
```

Testing your websites with 443 expose your deployment and test your set up.

## Conclusion

In this exercise, we learned how to create Kubernetes Secrets and ConfigMaps. We also learned how to use those Secrets and ConfigMaps. By volumemounts , we have also seen how it's easy to keep the configuration of individual instances of containers separate from the container image itself. By separating this configuration data, overhead is reduced to maintaining only a single image for a specific type of instance.

