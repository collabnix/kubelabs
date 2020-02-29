# What is a Deployment?

Deployments represent a set of multiple, identical Pods with no unique identities. A Deployment runs multiple replicas of your application and automatically replaces any instances that fail or become unresponsive. In this way, Deployments help ensure that one or more instances of your application are available to serve user requests. Deployments are managed by the Kubernetes Deployment controller.

Deployments use a Pod template, which contains a specification for its Pods. The Pod specification determines how each Pod should look like: what applications should run inside its containers, which volumes the Pods should mount, its labels, and more.

When a Deployment's Pod template is changed, new Pods are automatically created one at a time.

Deployments are well-suited for stateless applications that use ReadOnlyMany or ReadWriteMany volumes mounted on multiple replicas, but are not well-suited for workloads that use ReadWriteOnce volumes. For stateful applications using ReadWriteOnce volumes, use StatefulSets.

## Storage Class

Storage classes are Kubernetes objects that let the users specify which type of storage they need from the cloud provider. Different storage classes represent various service quality, such as disk latency and throughput, and are selected depending on the scenario they are used for and the cloud provider’s support. Persistent Volumes and Persistent Volume Claims use Storage Classes.

## Persistent Volumes and Persistent Volume Claims

Persistent volumes act as an abstraction layer to save the user from going into the details of how storage is managed and provisioned by each cloud provider (in this example, we are using AKS and Azure Storage Account). A Persistent Volume Claim is a request to use a Persistent Volume. If we are to use the Pods and Nodes analogy, then consider Persistent Volumes as the “nodes” and Persistent Volume Claims as the “pods” that use the node resources. The resources we are talking about here are storage properties, such as storage size, latency, throughput, etc.

## Creating a Storage Class
In the following example we are creating a storage class which is using Kubernetes Storage Plugin for Azure to map the storage class with Azure File Share.
Permissions mentioned in the below example can be modified according to your unique business case.

```
divyajeet@Azure:~/collabnix/deployment$ kubectl get sc
NAME                PROVISIONER                AGE
default (default)   kubernetes.io/azure-disk   49m
managed-premium     kubernetes.io/azure-disk   49m
```

```
divyajeet@Azure:~/collabnix/deployment$ vim storageclass.yaml 

kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: azurefile
provisioner: kubernetes.io/azure-file
mountOptions:
  - dir_mode=0777
  - file_mode=0777
  - uid=1000
  - gid=1000
  - mfsymlinks
  - nobrl
  - cache=none
parameters:
  skuName: Standard_LRS
reclaimPolicy: Retain
```
```
divyajeet@Azure:~/collabnix/deployment$ kubectl apply -f storageclass.yaml 
storageclass.storage.k8s.io/azurefile created
divyajeet@Azure:~/collabnix/deployment$ kubectl get sc
NAME                PROVISIONER                AGE
azurefile           kubernetes.io/azure-file   2s 
default (default)   kubernetes.io/azure-disk   49m
managed-premium     kubernetes.io/azure-disk   49m
```

## Creating Deployment

We would be demonstrating a simple counter app. This app will initially deploy one pod and dynamically create Azure File Share mapped to the pod.
After that we would manually scale the Pods to four and observe that Azure File Share which got created for first Pod will be utilized by newly created Pods. This is because we are defining a volume to be used in our YAML file.
Note:- When using Kubernetes Deployment, each Pod will start the counter from the last number of the existing Pod and not from the beginning. This proves that Deployment are used only for stateless apps because if the state was required to be preserved then the counter for each Pod would have started from numeric number 1.

```
divyajeet@Azure:~/collabnix/deployment$ kubectl get po
No resources found in default namespace.
divyajeet@Azure:~/collabnix/deployment$ kubectl get deployment
No resources found in default namespace.
```
```
divyajeet@Azure:~/collabnix/deployment$ vim deployment.yaml 

apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: counter-div
spec:
  selector:
    matchLabels:
      app: counter-div
  replicas: 1
  template:
    metadata:
      labels:
        app: counter-div
    spec:
      containers:
      - name: counter-div
        image: "divyajeetsingh/counter:1.0"
        volumeMounts:
        - name: azurefile
          mountPath: /app/
      volumes:
      - name: azurefile
        persistentVolumeClaim:
          claimName: azurefile
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: azurefile
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: azurefile
  resources:
    requests:
      storage: 1Gi

divyajeet@Azure:~/collabnix/deployment$ kubectl apply -f deployment.yaml 
deployment.apps/counter-div created
persistentvolumeclaim/azurefile created
```

## Viewing created POD's

```
divyajeet@Azure:~/collabnix/deployment$ kubectl get deployment
NAME          READY   UP-TO-DATE   AVAILABLE   AGE
counter-div   1/1     1            1           14s
divyajeet@Azure:~/collabnix/deployment$ kubectl get po
NAME                           READY   STATUS    RESTARTS   AGE
counter-div-54fdcf9d85-ln2kl   1/1     Running   0          16s
divyajeet@Azure:~/collabnix/deployment$ kubectl describe deployment
Name:                   counter-div
Namespace:              default
CreationTimestamp:      Sun, 26 Jan 2020 16:28:18 +0000
Labels:                 app=counter-div
Annotations:            deployment.kubernetes.io/revision: 1
                        kubectl.kubernetes.io/last-applied-configuration:
                          {"apiVersion":"apps/v1beta1","kind":"Deployment","metadata":{"annotations":{},"name":"counter-div","namespace":"default"},"spec":{"replica...
Selector:               app=counter-div
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=counter-div
  Containers:
   counter-div:
    Image:        divyajeetsingh/counter:1.0
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:
      /app/ from azurefile (rw)
  Volumes:
   azurefile:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  azurefile
    ReadOnly:   false
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   counter-div-54fdcf9d85 (1/1 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  27s   deployment-controller  Scaled up replica set counter-div-54fdcf9d85 to 1
divyajeet@Azure:~/collabnix/deployment$ kubectl describe po
Name:           counter-div-54fdcf9d85-ln2kl
Namespace:      default
Priority:       0
Node:           aks-agentpool-36099114-0/10.240.0.5
Start Time:     Sun, 26 Jan 2020 16:28:22 +0000
Labels:         app=counter-div
                pod-template-hash=54fdcf9d85
Annotations:    <none>
Status:         Running
IP:             10.244.1.6
IPs:            <none>
Controlled By:  ReplicaSet/counter-div-54fdcf9d85
Containers:
  counter-div:
    Container ID:   docker://b9818f0a3974996266c97ad321d52bf3a8e5093e6b463e42e5ce19e50a05b31d
    Image:          divyajeetsingh/counter:1.0
    Image ID:       docker-pullable://divyajeetsingh/counter@sha256:a282b73b265c7eae354dda1b9addaf8c5350564e656986af2c75fd730b2f0d33
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Sun, 26 Jan 2020 16:28:25 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /app/ from azurefile (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-v85rl (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  azurefile:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  azurefile
    ReadOnly:   false
  default-token-v85rl:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-v85rl
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type     Reason            Age                From                               Message
  ----     ------            ----               ----                               -------
  Warning  FailedScheduling  38s (x2 over 38s)  default-scheduler                  pod has unbound immediate PersistentVolumeClaims (repeated 2 times)
  Normal   Scheduled         37s                default-scheduler                  Successfully assigned default/counter-div-54fdcf9d85-ln2kl to aks-agentpool-36099114-0
  Normal   Pulled            35s                kubelet, aks-agentpool-36099114-0  Container image "divyajeetsingh/counter:1.0" already present on machine
  Normal   Created           34s                kubelet, aks-agentpool-36099114-0  Created container counter-div
  Normal   Started           33s                kubelet, aks-agentpool-36099114-0  Started container counter-div
```
![image1](https://github.com/collabnix/kubelabs/blob/master/201/Deployment-Picture.png)

## Checking Logs from the running Pod

```
divyajeet@Azure:~/collabnix/deployment$ Kubectl logs -f -c counter-div counter-div-54fdcf9d85-ln2kl
```

## Scaling up the deployment

```
divyajeet@Azure:~/collabnix/deployment$ kubectl scale deployment counter-div --replicas=2
deployment.extensions/counter-div scaled
divyajeet@Azure:~/collabnix/deployment$ kubectl scale deployment counter-div --replicas=3
deployment.extensions/counter-div scaled
divyajeet@Azure:~/collabnix/deployment$ kubectl scale deployment counter-div --replicas=4
deployment.extensions/counter-div scaled
```

![image2](https://github.com/collabnix/kubelabs/blob/master/201/Deployment-Picture.png)

We can see that even after the scale operation the numner of pv's did not increased, this shows that all four Pods are utilizing the same pv for Read and Write Operations.

## Remember to clean up

```
divyajeet@Azure:~/collabnix/deployment$ kubectl delete -f deployment.yaml
deployment.apps "counter-div" deleted
divyajeet@Azure:~/collabnix/deployment$ kubectl delete -f storageclass.yaml
storageclass.storage.k8s.io "azurefile-div" deleted
```

