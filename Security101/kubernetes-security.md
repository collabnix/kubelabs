# Kubernetes Security

As individual developers, security is probably not something that is at the forefront of our minds. We focus mostly on fulfilling the requirements of a task and leave things like access control to be handled later. When it comes to working with Kubernetes, we tend to take the security aspect of things for granted. Since Kubernetes is built with security in mind, and since the authors of any emerging technologies need to give security its due care for the technology to be considered for commercial use, the Kubernetes ecosystem is relatively secure. However, when it comes to large organizations that set up large-scale clusters for internal and customer use, it is very important to have a significant amount of security measures in place. Most large organizations have entire teams dedicated to handling authorization and application security. Kubernetes depends on microservices, which use thousands of third-party applications to function. Each of these applications could potentially introduce a security vulnerability, and that is simply not acceptable. A breach that occurs for a client due to mishandled credentials could cost greatly for a business, and it is therefore in an organization's interest to ensure that they hire DevOps engineers that know security best practices. So let's take a deep dive into Kubernetes security.

## Securing images

When using third-party images, there is a possibility that the author of the image may not have taken the necessary steps to secure the image. Therefore, ensuring that images comply with the security standard set by your organization is up to you. However, if you are creating your image to be used internally or to be freely available on an image hosting site, there are several steps you should take to secure your image. After all, it would be rather embarrassing if an attacker managed to gain access to a cluster by exploiting a container running your image. So what can be done here? 

### Check your dependencies

Unless the image you are building only does a simple task, you would likely use a base image or a list of images that your image depends on. You would then build your image on top of this base image. This is one place where things can go wrong since you have little control over the base images and their content. Additionally, you may have images that interact with the underlying operating system and performs some commands that allow attackers to see a backdoor in the system. The easiest way to circumvent this issue is to use as few dependencies as possible. The more images you depend on, the greater the chance of a security risk. When choosing a dependency, make sure you only get an image that has exactly what you want. For instance, if you want to curl, then there is no reason to choose a general-purpose image that has curl/wget/other request handling commands instead of just getting an image that provides curl.

**Image scanning**: You might think that all the above steps sound complicated, but they shouldn't be, because image scanning exists. Image scanning allows you to automatically look at a database of regularly updated vulnerabilities and compare your image and its dependencies against it. Normally, you wouldn't build a commercial-grade image by hand, and would instead allow a pipeline to do that for you. You could simply add image scanning as an additional step that runs after the image itself has been built.

But vulnerabilities can be added after the image has been built, and if your image depends on other images, vulnerabilities can be introduced via those other images as well. The result of this is that you can't afford to scan your image once, push it into the container repo, and forget about it. You need to ensure that all the images that already exist in your registry are periodically scanned. You might have some help in this regard depending on the image registry you choose. For instance, registries such as GCR, AWS ECR, Docker hub, etc... have inbuilt repository image scanning capabilities. However, if you host your container registry, then you might need to do this manually.

A good exmaple of a image scanning service is [Snyk](https://snyk.io). It's extremely simple to use, and you only need to run a single command:

```
docker scan <image-name>
```

Running this command on your release pipeline should flush out any vulnerabilities in your image. Another excellent tool that can be used is [Sysdig](https://sysdig.com). They provide [container security](https://sysdig.com/use-cases/container-security/) in the same way that Snyk does, allowing you to smoothly integrate image scanning to your existing pipeline. You also get continous compliance which ensures that a new vulnerabilty that affects your image is not found after you release. This includes checking your configuration, ensuring that any credentials used within your image have not been leaked, and protecting your image against insider threats. You also get image compliance, allowing you to present proof that your image complies with any standards put in place by your organization. It also integrates smoothly with your existing [kubernetes clusters](https://sysdig.com/use-cases/kubernetes-security/), as well as your [IaC platforms](https://sysdig.com/products/secure/infrastructure-as-code-security/).

### User Service users

If you run your containers with users that have unrestricted access (such as a root user), then an attacker who gains access to your container can easily gain access to the host system since they already have elevated privileges. The solution to this problem is to create a service user when creating the container, and then to ensure that the container is handled by that un-privileged service user.  This way, even if an attacker gets access to the container, they won't be able to do much with the service account and would have to also get access to the root user before they can accomplish anything.

So how can you handle this? Docker runs commands as root by default, and you need to change this by adding the service user to your user group in the docker file. The ```usermod``` command can do this for you if you already have an existing user group, or you can create/add to user groups with:

```
RUN groupadd -r <appname> && useradd -g <appname> <appname>
```

The next step is to limit what the user can do within this image using the ```chown``` command:

```
RUN chown -R <appname>:<appname> /app
```

Next, switch to this user so that the container always runs with the user as opposed to the root user:

```
USER <appname>
```

Now, your container will run with the user you specified here, and it adds a layer of protection. However, when you spin up a pod using this image, you have to ensure that you do not misconfigure the yaml so that you override the image commands and start running your pod as root. To ensure this, place the commands:

```
allowPrivilegeEscalation: false
```

Read more about this [here](https://kubernetes.io/docs/concepts/security/pod-security-policy/#privilege-escalation).

### Maintain tight user groups and permissions

All the above precautions need to be taken when creating the image, well before it is deployed. However, these are just the first steps. Once you go ahead and deploy your images and have pods spun up from them, there are further actions that you need to take to prevent attackers from hacking into your system. It is a common conception that the users of a system are its weakest link, and while users need to be able to use the system in a way that doesn't allow it to be exploited, your job is to assume that an exploit will happen and to prepare accordingly. Note that your cluster may be accessed by accounts belonging to real people as well as automated system/service accounts. All these accounts need to be secured. If you give every single user in the organization admin privileges, then if just one of those accounts were to be compromised, your entire system will be at risk. Alternatively, if each user is grouped to a very specific set of permissions that allow the user to do only what they need to, and nothing more, then even if an account is compromised, the damage would be limited.

Luckily, Kubernetes has a solution in place so that you don't have to spend a significant amount of time setting things up. RBAC (Role-Based Access Control) allows you to specify roles, which in turn specify access.  So if you want to specify read access to a cluster's logs, but only logs about a specific namespace, you can create a role for that. Once you have a role in place, you can assign this role to any user(s), which will automatically give them all the privileges granted by that role. So this means if you have a team of people who use a specific set of permissions, you can create a role that has that set of permissions, and assign the roles to each member (or group members in a group and assign roles to the group) without having to assign each permission individually. As with everything else, you define RBAC as a Kubernetes resource that follows the standard Kubernetes Yaml format. A comprehensive look at RBAC can be found in the [RBAC101 section](../RBAC101/README.md)

### In-cluster network policies

Now that you have secured against any external attacks into your cluster, you can go ahead and assume that any security measures there will fail, and an attacker would eventually manage to find their way into the cluster. This means that you now have to ensure that your cluster is protected from the inside as well. 

By default, all the pods in a cluster are connected in some form. Most of them can access each other via localhost, and this means that if someone were to get into your cluster and find their way into one pod, every other pod would also be free for the taking. The solution to this is the same as the solution we came up with for user access: limited access. If you were to go ahead and restrict each pod's ability to communicate, this would solve the issue to some extent. A network policy would, as always, be defined as a Kubernetes resource of type ```NetworkPolicy```, and would allow you to specify ranges where of IPs that are acceptable to each resource.

While network policies are great for restricting access when it comes to a small cluster with a small number of pods, you might have some repetition and complexity when it comes to a larger cluster. Consider using a service mesh such as Istio and Linkerd to enhance the security (as well as add several other cluster-wide features) by automatically adding proxies to each pod that individually manages pod communication. You can learn more about this in the [ServiceMesh101 section](../ServiceMesh101/what-are-service-meshes.MD).

### Encryption

Despite all the above measures, pods still need to communicate. After all, that is the whole point of a microservice architecture. This is where encryption comes in. By default, any communication happening between pods happens unencrypted. This means that even if an attacker can't directly access the pods, they can gain access to the pod logs of every other pod. Using mutual TLS helps to solve the problem by encrypting inter-pod traffic. This is also available as part of Istio, which is why using service meshes in large clusters is always recommended.

### Base64 secrets

This is something that is done quite a lot in Kubernetes, and I have admittedly handled secrets by simply encoding them in base64. By default, most secrets in Kubernetes environments are encoded in base64 and stored as-is. This is a huge security risk since anyone can decode this string and have full access to your secret. Kubernetes provides a solution for this in the form of a resource [EncyptionConfiguration](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/), but you still need to securely store the encryption key. Key management services such as AWS KMS can help you with this. You could also skip having to deal with encryption keys together and use a secret management system.

Let's take a look at the inbuilt Kubernetes encryption resource. The resource is, as always, a normal yaml resource file of kind EncryptionConfiguration:

```yaml
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: <BASE 64 ENCODED SECRET>
      - identity: {}
```

The kind is defined on the top of the yaml file, after which the keys and their respective secrets are named. These secrets are defined as a list of providers that "provide" secrets to applications that request them. For example, if an application requests the secret for "key1", the provider is matched and the relevant information is released. If there is no matching provider, an error is returned. To define the encoded secret, you can use the base64 command that is present with all Unix machines:

```
head -c 32 /dev/urandom | base64
```

Set this value as your secret. Next, you need to set this resource file to be referenced in your [kube-apiserver](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/), which is the file that configures data for all API objects (which gives it the perfect position to handle you encryption data). Set this flag on the file:

```
--encryption-provider-config
```

You will also have to restart your API server to start seeing the effect of the change. Note that since your API server has access to these credentials, you must restrict access to this file. To test whether your secrets are truly encrypted, first create an ordinary Kubernetes secret:

```
kubectl create secret generic secret1 -n default --from-literal=mykey=mydata
```

Then use the ```etcdctl``` CLI command to read the secret from etcd:

```
ETCDCTL_API=3 etcdctl get /registry/secrets/default/secret1 <arguments> | hexdump -C
```

Finally, describe the secret to ensure that the secret is correctly decrypted:

```
kubectl describe secret secret1 -n default
```

The secret key is a good start, but more protection can be afforded by using a rotating secret key. This means that your secret will change regularly, and even if an attacker can gain access to your secret, there is a good probability that the secret would be outdated by the time they get to use it. However, you might notice a big problem here: downtime. If you were to change the secret, you would also have to change every place where the secret is referenced, and you would always have to take down the system while you did it. However, if you are willing to go through a slightly lengthier process, you can eliminate this downtime.

To do this, you need to introduce the new secret in stages. First, generate the new key and add it to the providers as a secondary key, after which you need you to need to restart the ```kube-apiserver```. You then need to reposition the new key so that it is the first key in the ````keys```` array, before restarting the ```kube-apiserver``` again. Finally, get all secrets from all namespaces and replace them with the new key:

```
kubectl get secrets --all-namespaces -o json | kubectl replace -f -
```

Remove the old decryption key since it is no longer useful.

### Secure etcd

Your etcd stores all key-value pairs which are necessary since the whole function of etcd is to monitor and maintain the resources in a Kubernetes cluster. As such, it has comprehensive control over your cluster, and your cluster has a consistent means of contacting etcd. If an attacker was to get access to etcd, they would therefore be able to control your cluster, and since any changes that go on within the pod are reported back to etcd, they would end up getting an insight into this information as well. Since this attacker does not need to use the API between the control plane and the resources, they end up having close to unhindered access to your cluster, which is an obvious problem.

The solution for this is quite simple. Since the API server being bypassed is the problem, simply place your etcd store behind a firewall and only allow the API server to access it. This way, an attacker who gets access to etcd would not be able to manipulate the cluster. However, your etcd store might already have some sensitive information in it, and you would like to prevent the attacker from reading this data. Encrypting the information within your etcd store can help you take care of this problem. 

### Security policies

If you were an ordinary developer working in a sizable organization, then it's highly likely that you already follow a mandatorily enforced set of cluster security policies. However, if you were in a smaller organization, or happened to be the admins of these clusters, then the responsibility would fall on you to maintain cluster security. Developers who are more interested in meeting deadlines and pushing out their products would overlook some security vulnerabilities that they introduce into a system, and it would impossible for you, as an admin, to monitor each resource they push. Instead, you can enable security policies that are enforced at deployment time, which would prevent a resource from being deployed if it does not meet the required security criteria. For instance, if there are containers set to run with root access, you can flush them out before they are deployed and reject the resource.

[Open Policy Agent](https://www.openpolicyagent.org) is an excellent tool to support this. OPA uses a unified framework that you can apply across your cloud-native stack, meaning that your entire stack will work with a single set of policies. The policy is defined in a declarative language (called Rego) and can enforce policies on every type of Kubernetes operation out there. You can also check for things like the existence of specific labels on resources, the sources of each image, and the validity of Ingress objects. You can also use admission controllers that manipulate resources that are getting applied so that they adhere to policies. This includes adding sidecar containers to each pod that gets added, automatically identifying and replacing images that get are hosted in non-corporate repositories, use taints and tolerations to mutate deployments. The best way to learn how to use their declarative language and implement OPA on your cluster is using their [interactive playground](https://play.openpolicyagent.org).

### Disaster recovery

A key point to remember here is that while you can make life harder for an attacker, no guarantee implementing all of the above security strategies will still prevent your data from being attacked. This is where disaster management comes in. While your etcd store might allow the attacker to gain privileged access to your cluster, this is not the most important part of your cluster. What is most important is your data. Since data is so valuable, ransomware is a common problem that businesses have to face, and having regular backups of your data that gets stored securely is the best way to avoid coming into these situations. Naturally, you don't have to handle this by hand since there is an excellent solution provided by Kasten called K10. K10 automatically backs up your data regularly and allows you to restore these backups at the click of a button. It also provides end-to-end security, meaning that they make sure that your backups are also secured. Attackers generally anticipate the existence of backups, and may also target these which means that you have to go the extra mile to prevent your backups from being erased.

A snapshot is taken of your data and encryption is applied not only when the data is stored, but also when the data is being transferred. This means that attackers cannot read your data even if they get hold of it. Additionally, there is a possibility of your backup being corrupted by an attacker, which you can prevent by using creating immutable backups. This means that the backups cannot be changed (which is reasonable since backups don't need to change after being backed up), or deleted. K10 is an all-in-one, easy-to-use solution that allows even a non-programmer to manage cluster security. You can even get a hands-on lab on how to use K10 [here](https://learning.kasten.io/kubernetes/labs/backup-kubernetes-application/).

Data is only one of the things that need backing up. Your cluster itself is not made up purely of data. So if an attack succeeds and your system goes offline, just being able to restore your data alone will not help you in the short run. For instance, if you run an e-commerce website, then your cluster going down even for a couple of hours could lead to lost sales, which you want to avoid. This means that you need to get your cluster back to its former state along with the data for that cluster simultaneously. K10 can help you here as well, by taking a snapshot of your cluster state. You can then apply this state in an emergency and have your cluster back to the way it was before. There are still things that can go wrong here as well, and it's up to you to test these disaster recovery methods beforehand to ensure that there are no surprises when you end up in an attack situation.

To make your life easier, K10 additionally allows you to restore your system to a Kubernetes environment different from the one you currently run. This means that even if you were running your cluster on AKS, you could restore it to Amazon EKS after an attack. You can even switch Kubernetes versions (as long as your resources support them), meaning that you could pull out a completely new environment that the attacker would be unable to predict, and deploy to it, which would ensure that your customers experience minimum downtime.

## Other measures

The above list is in no way the most extensive list of security options that are available to protect your Kubernetes clusters. There is always a new exploit being found, and it's best to assume that someday, your cluster will be attacked. The fundamental problem here is that an attacker only needs to find a single weak spot in your security system to break in, whereas a cluster-admin needs to ensure that there are zero weak spots in any of the resources to achieve complete safety. So if you are planning on being a cluster-admin or have to maintain security in a cluster, then there is a lot more in this field that you need to consider. However, if you are a normal developer, then the above steps should help you code securely, regardless of the size of your organization.