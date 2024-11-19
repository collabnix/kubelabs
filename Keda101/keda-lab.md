# KEDA Lab

## Requirements

To start, you need to have a Kubernetes cluster. [Minikube](https://minikube.sigs.k8s.io/docs/start/) is a quick and easy way to get set up with a single node cluster.

Once you have a cluster up and running, you need to deploy an application to it. This application will then be scaled with KEDA depending on a specific metric. KEDA already provides several sample applications that cover a large number of data sources in their [GitHub repo](https://github.com/kedacore/samples), and we will be using one of these samples in this lab.

In this case, we will be using the [MySQL scaler](https://keda.sh/docs/2.10/scalers/mysql/) and following the sample [here](https://github.com/turbaszek/keda-example). Start by cloning the repo:

```
git clone https://github.com/turbaszek/keda-example.git
```

Since the web application and API are both avialble in the repo and will be hosted locally, you need to first run:

```
docker build
```

which will create a Golang application.

You now have all the configuration files required to do the deployment. The `Deployment` folder you find inside the repo are all the files you need to deploy. Go ahead and deploy all the resources to the cluster:

```
kubectl apply -f deployment/
```

While the deployment takes place, let's take a look at what we are deploying. First, you will notice that there are two deployments: MySQL and Redis. The [mysql deployment](https://github.com/turbaszek/keda-example/blob/master/deployment/mysql-deployment.yaml) is straightforward. A Service, a PersistentVolumeClaim, and a Deployment. The service opens up a simple port (3306). The PersistentVolumeClaim is a necessary part of any database system since pods are ephemeral. When the pod goes down, any data that it held would disappear, which would be a pretty terrible design for a database that is designed to hold data forever. Therefore, a permanent volume is used to hold data. Finally, you have the deployment, which holds the main part of the resource. This deployment is a simple MySQL image running with 1 replica on port 3306 with the admin password "keda-talk".

If you look at the [redis deployment](https://github.com/turbaszek/keda-example/blob/master/deployment/redis-deployment.yaml), it's basically the same thing, running on the port with 6379. We will be scaling based on MySQL, so there is no need to look deeply into the redis deployment. You can avoid deploying it altogether if you prefer.

You also have a [service account resource](https://github.com/turbaszek/keda-example/blob/master/deployment/make-user.yaml) which creates a cluster role that is an admin. This is the unrestricted role that will be used across the cluster.

Next, you have the app and API deployments, which constitute the web application that will be connecting to the Redis and MySQL applications. The [API deployment](https://github.com/turbaszek/keda-example/blob/master/deployment/api-deployment.yaml) creates a service with port 3232 that runs with a load balancer. The image that will be used is the image that you previously built with `docker build`. The [App deployment](https://github.com/turbaszek/keda-example/blob/master/deployment/app-deployment.yaml) is the same thing, except it handles the application and not the API.

You probably can see where KEDA is going to fit in now. You have the API and the application, as well as the database. When the number of requests that come into the database increase, the number of pods for the API and application will also increment to handle the extra traffic. In the same way, when the number of requests decreases, the number of pods will go down to save costs.

Now that the cluster and the application are ready, install KEDA. It is recommended you use Helm for this, as Helm will largely take care of the setup for you.

Add the repo:

```
helm repo add kedacore https://kedacore.github.io/charts
```

Update it:

```
helm repo update
```

Then install KEDA in the correct namespace:

```
kubectl create namespace keda
helm install keda kedacore/keda --namespace keda
```

You can then see that the KEDA resources have been set up in the keda namespace:

```
kubectl get po -n keda
```

Now run:

```
kubectl get sa -n keda
```

You will notice that a service account has been created. In this example, we will be using a mysql instance that will be running on your local machine, and therefore will no require any additional authorization. As such, this service account will not be used. However, if you were using KEDA in a commercial situation then you would most likely be connecting to resources on the cloud where the service account and its related features will be necessary. Therefore, we will talk about the authentication aspect later.

Before you start scaling anything, look at the initial state of the pods. Open up a new terminal instance and use:

```
kubectl get po --watch
```

Make sure you set the namespace with `-n` if you deployed the API in a specific namespace. You now have an auto-updating view of the pods and their replicas.

Now, deploy the `mysql-hpa.yaml` found in the keda folder:

```
kubectl apply -f keda/mysql-hpa.yaml
```

This is where the dummy deployment we saw earlier comes into place. The dummy pod will now be scaled up and down by KEDA depending on the MySQL row count. Insert some items into the MySQL database:

```
kubectl exec $(kubectl get pods | grep "server" | cut -f 1 -d " ") -- keda-talk mysql insert
```

If you look at the watch window that you opened up earlier, you should see additional replicas of the pods getting created.

Now let's look at scaling down. Delete items from the MySQL pod:

```
kubectl exec $(kubectl get pods | grep "server" | cut -f 1 -d " ") -- keda-talk mysql delete
```

Go back to the watch window, and you should see the number of pods decreasing.

Now that you have a basic idea of KEDA and how it works, let's take a look at external authentication. Imagine you are trying to scale resources on an EKS cluster as opposed to your local machine. KEDA needs to be able to authorize itself to do that. Depending on your cloud provider, the exact steps will defer, but you only have to edit a couple of lines in one file. This makes the whole authorization process painless.

First off, open up the `values.yaml` for the KEDA helm chart. This section is the important part:

```
serviceAccount:
  # -- Specifies whether a service account should be created
  create: true
  # -- The name of the service account to use.
  # If not set and create is true, a name is generated using the fullname template
  name: keda-operator
  # -- Specifies whether a service account should automount API-Credentials
  automountServiceAccountToken: true
  # -- Annotations to add to the service account
  annotations: {}
```

The part that needs to be modified is the `annotations` section. So if you want to scale an EKS cluster based on SQS messages, then you first need an IAM role that has access to SQS, and you need to add this role arn as an annotation.

```
annotations: 
    eks.amazonaws.com/role-arn: arn:aws:iam::<account-id>:role/<role-name>
```

Next, you need to change the ScaleObject resource. The mysql-hpa.yaml has the trigger specified as the mysql db. However, it does not have an option called `identityOwner`. This is becase we are not using authentication here, and therefore do not need such a thing. In order to add authentication, this key should be added and the value set to `operator`:

```
metadata:
    ...
    identityOwner: operator
```

And that's it! You only needed to modify two lines and you have full authorization among the cluster.

While this is the easiest way to provide authentication, it is not the only way to do it. You could also change the `identityOwner` to `pod`, and create a `TriggerAuthentication` resource and feed in the AWS access keys (which isn't very secure), or have the keda service account assume a role that has access to the necessary resources (which is much more secure). There is a number of different ways to authorize, and these are covered in the [KEDA documentation](https://keda.sh/docs/1.4/concepts/authentication/).

If you added the arn, then setting up authentication is a simple matter. While Keda provides resources specifically geared towards authentication, you won't need to use any of that. In the Keda authentication types, there exists a type called `operator`. This type allows the keda service account to directly acquire the role of the IAM arn you provided. As long as the arn has the permissions necessary, keda can function. The triggers will look like the following:

```yaml
  triggers:
  - type: aws-sqs-queue
    authenticationRef:
      name: keda-trigger-auth-aws-credentials-activity-distributor
    metadata:
      queueURL: <your_queue_url>
      queueLength: "1"
      awsRegion: "us-east-1"
      identityOwner: operator  # This is where the identityOwner needs to be set
```

If you set the `identityOwner` to something else, such as `pod`, you could set up Keda to authenticate by assuming a role that has the necessary permissions instead of acquiring the IAM role itself. You could also completely scrap this part and choose to provide access keys. In this case, you would use several additional resources. For starters, you need to include your access keys in a secret. So start by defining a resource of kind `secret`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: keda-secret
  namespace: keda
data:
  AWS_ACCESS_KEY_ID: <AWS ACCESS KEY>
  AWS_SECRET_ACCESS_KEY: <AWS SECRET KEY>
```

You should then assign this resource to a Keda-specific custom resource called "TriggerAuthentication":

```yaml
apiVersion: keda.sh/v1alpha1
kind: TriggerAuthentication
metadata:
  name: keda-trigger-authentication
  namespace: keda
spec:
  secretTargetRef:
  - parameter: awsAccessKeyID
    name: keda-secret
    key: AWS_ACCESS_KEY_ID
  - parameter: awsSecretAccessKey
    name: keda-secret
    key: AWS_SECRET_ACCESS_KEY
```

This `TriggerAuthentication` resource should then be referenced within the actual `ScaledJob` resource under the `triggered` section:

```yaml
authenticationRef:
  name: keda-trigger-authentication
```

This will allow your `ScaledJob` resource to read the authentication keys that you added to your secret via the `TriggerAuthentication` resource. Of course, if you don't want to have your access keys even as a secret, you can use the operator authentication type described above. Additionally, Keda support [several different authentication types](https://keda.sh/docs/2.11/concepts/authentication/) out of the box.

With the above configuration, a new Keda job will start every time a message is sent to the SQS queue. The job should have the necessary configurations to read the content of the message sent to the queue, and the message in SQS should get consumed by the job that starts. Once the job succeeds, it will terminate. If there is a failure, the job will exit and a new job will get created. It will then attempt to consume the message.

If you added the arn, then setting up authentication is a simple matter. While Keda provides resources specifically geared towards authentication, you won't need to use any of that. In the Keda authentication types, there exists a type called `operator`. This type allows the keda service account to directly acquire the role of the IAM arn you provided. As long as the arn has the permissions necessary, keda can function. The triggers will look like the following:

```yaml
  triggers:
  - type: aws-sqs-queue
    authenticationRef:
      name: keda-trigger-auth-aws-credentials-activity-distributor
    metadata:
      queueURL: <your_queue_url>
      queueLength: "1"
      awsRegion: "us-east-1"
      identityOwner: operator  # This is where the identityOwner needs to be set
```

If you set the `identityOwner` to something else, such as `pod`, you could set up Keda to authenticate by assuming a role that has the necessary permissions instead of acquiring the IAM role itself. You could also completely scrap this part and choose to provide access keys. In this case, you would use several additional resources. For starters, you need to include your access keys in a secret. So start by defining a resource of kind `secret`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: keda-secret
  namespace: keda
data:
  AWS_ACCESS_KEY_ID: <AWS ACCESS KEY>
  AWS_SECRET_ACCESS_KEY: <AWS SECRET KEY>
```

You should then assign this resource to a Keda-specific custom resource called "TriggerAuthentication":

```yaml
apiVersion: keda.sh/v1alpha1
kind: TriggerAuthentication
metadata:
  name: keda-trigger-authentication
  namespace: keda
spec:
  secretTargetRef:
  - parameter: awsAccessKeyID
    name: keda-secret
    key: AWS_ACCESS_KEY_ID
  - parameter: awsSecretAccessKey
    name: keda-secret
    key: AWS_SECRET_ACCESS_KEY
```

This `TriggerAuthentication` resource should then be referenced within the actual `ScaledJob` resource under the `triggered` section:

```yaml
authenticationRef:
  name: keda-trigger-authentication
```

This will allow your `ScaledJob` resource to read the authentication keys that you added to your secret via the `TriggerAuthentication` resource. Of course, if you don't want to have your access keys even as a secret, you can use the operator authentication type described above. Additionally, Keda support [several different authentication types](https://keda.sh/docs/2.11/concepts/authentication/) out of the box.

With the above configuration, a new Keda job will start every time a message is sent to the SQS queue. The job should have the necessary configurations to read the content of the message sent to the queue, and the message in SQS should get consumed by the job that starts. Once the job succeeds, it will terminate. If there is a failure, the job will exit and a new job will get created. It will then attempt to consume the message.

## Conclusion
This wraps up the lesson on KEDA. What we tried out was a simple demonstration of a MySQL scaler followed by a demonstration of using various authentication methods to connect and consume messages from AWS SQS. This is a good representation of what you can expect from other data sources. If you were considering using this with a different Kubernetes engine running on a different cloud provider, the concept would still work. Make sure you read through the authentication page, which contains different methods of authentication for different cloud providers. Next up, we will look at how you can use KEDA alongside Prometheus and Linkerd to scale your pods based on the number of requests reaching your endpoints.


[Next: Scaling with KEDA and Prometheus](./keda-prometheus.md)