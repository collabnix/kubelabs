# Difference between Statefulset and Deployment:-

## Deployment 

Deployment is the easiest and most used resource for deploying your application. It is a Kubernetes controller that matches the current state of your cluster to the desired state mentioned in the Deployment manifest. e.g. If you create a deployment with 1 replica, it will check that the desired state of ReplicaSet is 1 and current state is 0, so it will create a ReplicaSet, which will further create the pod. If you create a deployment with name counter, it will create a ReplicaSet with name counter-<replica-set-id>, which will further create a Pod with name counter-<replica-set->-<pod-id>.
Deployments are usually used for stateless applications. However, you can save the state of deployment by attaching a Persistent Volume to it and make it stateful, but all the pods of a deployment will be sharing the same Volume and data across all of them will be same.


## StatefulSet 

StatefulSet is a Kubernetes resource used to manage stateful applications. It manages the deployment and scaling of a set of Pods, and provides guarantee about the ordering and uniqueness of these Pods.
StatefulSet is also a Controller but unlike Deployments, it doesn’t create ReplicaSet rather itself creates the Pod with a unique naming convention. e.g. If you create a StatefulSet with name counter, it will create a pod with name counter-0, and for multiple replicas of a statefulset, their names will increment like counter-0, counter-1, counter-2, etc
Every replica of a stateful set will have its own state, and each of the pods will be creating its own PVC(Persistent Volume Claim). So a statefulset with 3 replicas will create 3 pods, each having its own Volume, so total 3 PVCs.

## Dynamic PV with Azure File Share

	### Pre-Requisites:-
		1. AKS cluster, if you need one you can follow the link:- https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough-portal
		2. Storage Class
		3. Azure File Share (Created Automatically)
		4. PVC (Created Automatically)
	
## Storage Class

Storage classes are Kubernetes objects that let the users specify which type of storage they need from the cloud provider. Different storage classes represent various service quality, such as disk latency and throughput, and are selected depending on the scenario they are used for and the cloud provider’s support. Persistent Volumes and Persistent Volume Claims use Storage Classes.

## Persistent Volumes and Persistent Volume Claims

Persistent volumes act as an abstraction layer to save the user from going into the details of how storage is managed and provisioned by each cloud provider (in this example, we are using AKS and Azure Storage Account). By definition, StatefulSets are the most frequent users of Persistent Volumes since they need permanent storage for their pods.
A Persistent Volume Claim is a request to use a Persistent Volume. If we are to use the Pods and Nodes analogy, then consider Persistent Volumes as the “nodes” and Persistent Volume Claims as the “pods” that use the node resources. The resources we are talking about here are storage properties, such as storage size, latency, throughput, etc.

## Creating a Storage Class
In the following example we are creating a storage class which is using Kubernetes Storage Plugin for Azure to map the storage class with Azure File Share.
Permissions mentioned in the below example can be modified according to your unique business case.
```
divyajeet@Azure:~/collabnix$ kubectl get storageclass
NAME                PROVISIONER                AGE
default (default)   kubernetes.io/azure-disk   72m
managed-premium     kubernetes.io/azure-disk   72m
```
```
divyajeet@Azure:~/collabnix$ vim storageclass.yaml 

kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: azurefile-div
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
```
```
divyajeet@Azure:~/collabnix$ kubectl apply -f storageclass.yaml 
storageclass.storage.k8s.io/azurefile-div created
divyajeet@Azure:~/collabnix$ kubectl get storageclass
NAME                PROVISIONER                AGE
azurefile-div       kubernetes.io/azure-file   3s 
default (default)   kubernetes.io/azure-disk   73m
managed-premium     kubernetes.io/azure-disk   73m
```
## Creating Statefulset

We would be demonstrating a simple counter app. This app will initially deploy one pod and dynamically create Azure File Share mapped to the pod.
After that we would manually scale the Pods to four and observe than Azure File Shares will get created for them on the fly.
Note:- When using Kubernetes Statefulset, each pod will have it's individual File Share where as when using Kubernetes Deployments all the Pods get mapped to a Single File Share.

```
divyajeet@Azure:~/collabnix$ kubectl get po
No resources found in default namespace.
divyajeet@Azure:~/collabnix$ kubectl get statefulsets
No resources found in default namespace.
```
```
divyajeet@Azure:~/collabnix$ vim statefulsets.yaml

apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: counter-div
spec:
  serviceName: "counter-app-div"
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
        - name: counter-div
          mountPath: /app/      
  volumeClaimTemplates:
  - metadata:
      name: counter-div
    spec:
      accessModes: [ "ReadWriteMany" ]
      storageClassName: azurefile-div
      resources:
        requests:
          storage: 50Mi

divyajeet@Azure:~/collabnix$ kubectl apply -f statefulsets.yaml 
statefulset.apps/counter-div created
```
```
divyajeet@Azure:~/collabnix$ kubectl get statefulsets
NAME          READY   AGE    
counter-div   0/1     19s    

divyajeet@Azure:~/collabnix$ kubectl describe statefulsets
Name:               counter-div
Namespace:          default
CreationTimestamp:  Sun, 19 Jan 2020 11:44:39 +0000
Selector:           app=counter-div
Labels:             <none>
Annotations:        kubectl.kubernetes.io/last-applied-configuration:
                      {"apiVersion":"apps/v1","kind":"StatefulSet","metadata":{"annotations":{},"name":"counter-div","namespace":"default"},"spec"cas":1...
Replicas:           1 desired | 1 total
Update Strategy:    RollingUpdate
  Partition:        824643797832
Pods Status:        1 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=counter-div
  Containers:
   counter-div:
    Image:        divyajeetsingh/counter:1.0
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:
      /app/ from counter-div (rw)
  Volumes:  <none>
Volume Claims:
  Name:          counter-div
  StorageClass:  azurefile-div
  Labels:        <none>
  Annotations:   <none>
  Capacity:      50Mi
  Access Modes:  [ReadWriteMany]
Events:
  Type    Reason            Age   From                    Message
  ----    ------            ----  ----                    -------
  Normal  SuccessfulCreate  32s   statefulset-controller  create Claim counter-div-counter-div-0 Pod counter-div-0 in StatefulSet counter-div succ
  Normal  SuccessfulCreate  32s   statefulset-controller  create Pod counter-div-0 in StatefulSet counter-div successful
```
## Viewing the created Pod's
```
divyajeet@Azure:~/collabnix$ kubectl get po
NAME            READY   STATUS    RESTARTS   AGE
counter-div-0   1/1     Running   0          57s
divyajeet@Azure:~/collabnix$ kubectl describe po counter-div-0
Name:           counter-div-0
Namespace:      default
Priority:       0
Node:           aks-agentpool-36099114-1/10.240.0.5
Start Time:     Sun, 19 Jan 2020 11:45:00 +0000
Labels:         app=counter-div
                controller-revision-hash=counter-div-76d5b64c59
                statefulset.kubernetes.io/pod-name=counter-div-0
Annotations:    <none>
Status:         Running
IP:             10.244.1.5
IPs:            <none>
Controlled By:  StatefulSet/counter-div
Containers:
  counter-div:
    Container ID:   docker://1e5a1c6c82d64ae6ae25472002b5543828f215e7af6beb8fca7184158a62422f
    Image:          divyajeetsingh/counter:1.0
    Image ID:       docker-pullable://divyajeetsingh/counter@sha256:a282b73b265c7eae354dda1b9addaf8c5350564e656986af2c75fd730b2f0d33
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Sun, 19 Jan 2020 11:45:03 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /app/ from counter-div (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-r8b7q (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
IPs:            <none>
Controlled By:  StatefulSet/counter-div
Containers:
  counter-div:
    Container ID:   docker://1e5a1c6c82d64ae6ae25472002b5543828f215e7af6beb8fca7184158a62422f
    Image:          divyajeetsingh/counter:1.0
    Image ID:       docker-pullable://divyajeetsingh/counter@sha256:a282b73b265c7eae354dda1b9addaf8c5350564e656986af2c75fd730b2f0d33
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Sun, 19 Jan 2020 11:45:03 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /app/ from counter-div (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-r8b7q (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  counter-div:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  counter-div-counter-div-0
    ReadOnly:   false
  default-token-r8b7q:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-r8b7q
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type     Reason            Age                From                               Message
  ----     ------            ----               ----                               -------
  Warning  FailedScheduling  56s (x4 over 75s)  default-scheduler                  pod has unbound immediate PersistentVolumeClaims (repeated 2 times)  
  Normal   Scheduled         54s                default-scheduler                  Successfully assigned default/counter-div-0 to aks-agentpool-36099114-1  Normal   Pulled            52s                kubelet, aks-agentpool-36099114-1  Container image "divyajeetsingh/counter:1.0" already present on machine 
  Normal   Created           51s                kubelet, aks-agentpool-36099114-1  Created container counter-div
  Normal   Started           51s                kubelet, aks-agentpool-36099114-1  Started container counter-div
```
## Scaling Statefulsets
```
divyajeet@Azure:~/collabnix$ kubectl scale statefulsets counter-div --replicas=2
statefulset.apps/counter-div scaled
divyajeet@Azure:~/collabnix$ kubectl scale statefulsets counter-div --replicas=3
statefulset.apps/counter-div scaled
divyajeet@Azure:~/collabnix$ kubectl scale statefulsets counter-div --replicas=4
statefulset.apps/counter-div scaled
```
![image1](https://github.com/collabnix/kubelabs/blob/master/201/Picture1.png)

![image2](https://github.com/collabnix/kubelabs/blob/master/201/Picture2.png)

![image3](https://github.com/collabnix/kubelabs/blob/master/201/Picture3.png)

## Remember to clean-up
```
divyajeet@Azure:~/collabnix$ kubectl scale statefulsets counter-div --replicas=1
statefulset.apps/counter-div scaled
divyajeet@Azure:~/collabnix$ kubectl delete -f statefulsets.yaml
statefulset.apps "counter-div" deleted
divyajeet@Azure:~/collabnix$ kubectl delete -f storageclass.yaml
storageclass.storage.k8s.io "azurefile-div" deleted
```
