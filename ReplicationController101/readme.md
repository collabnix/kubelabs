# Replication Controller
- A Replication Controller ensure that a specified number of replicas (identical copies) of a pod are running at all times.
- If there are too few replicas, the Replication Controller creates additional ones; if there are too many, it terminates the excess pods.
- Replication Controllers use label selectors to identify the pods they manage. This allows for flexibility in specifying which pods should be part of a particular set. Labels are key-value pairs attached to pods, and selectors are used to filter and group pods based on these labels.
## Creating Your First ReplicationController
```
git clone https://github.com/collabnix/kubelabs.git
cd kubelabs/ReplicationController101/
```
```
kubectl apply -f ReplicationController.yaml
```
```
kubectl get rc
```

```
NAME      DESIRED   CURRENT   READY   AGE
nginxrc   2         2         0       7s
```
```
kubectl describe rc nginxrc
```
Output :-
```
Name:         nginxrc
Namespace:    default
Selector:     team=dev
Labels:       app=nginx
Annotations:  <none>
Replicas:     2 current / 2 desired
Pods Status:  0 Running / 2 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  team=dev
  Containers:
   nginxcont:
    Image:        nginx
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Events:
  Type    Reason            Age   From                    Message
  ----    ------            ----  ----                    -------
  Normal  SuccessfulCreate  2s    replication-controller  Created pod: nginxrc-gc4t2
  Normal  SuccessfulCreate  2s    replication-controller  Created pod: nginxrc-wj2hd
```
## ReplicationController Manifest
```
apiVersion: v1
kind: ReplicationController
metadata:
  name: nginxrc
  labels:
    app: nginx
spec:
  replicas: 2
  selector:  #optional
    team: dev
  template:  #pod template
    metadata:
      labels:
        team: dev
    spec:
      containers:
      - name: nginxcont
        image: nginx
        ports:
        - containerPort: 80
```
Let’s examine the file that was used to create our ReplicationController:

- The apiVersion for this object is currently v1
- The kind of this object is ReplicationController
- In the metadata part, we define the name by which we can refer to this ReplicationController . We also define a number of labels through which we can identify it.
- The spec part is mandatory in the ReplicationController object. It defines:
	- The number of replicas this controller should maintain. It default to 1 if it was not specified.
	- The selection criteria by which the Replicationcontroller will choose its pods. Be careful not to use a label that is already in use by another controller. Otherwise, another Controller may acquire the pod(s) first. Also notice that the labels defined in the pod template (spec.template.metadata.label) cannot be different than those defined in the matchLabels part (spec.selector).
	- The pod template is used to create (or recreate) new pods. It has its own metadata, and spec where the containers are specified. You can refer to our article for more information about pods.

## Labels and Selector in Replication Controller
- If you don't mention labels(.metadata.labels) then by default it take from pod labels(.spec.template.metadata.labels).
- If you don't mention selector(.spec.selector) then by default it take from pod labels(.spec.template.metadata.labels).

### Let Create One Replication Controller without Lables(.metadata.labels) and Selector
```
git clone https://github.com/collabnix/kubelabs.git
cd kubelabs/ReplicationController101/
```
```
kubectl apply -f replicationcontrollerselector.yaml
```
```
kubectl describe rc nginxrc
```
Output :-
```
Name:         nginxrc
Namespace:    default
Selector:     team=dev
Labels:       team=dev
Annotations:  <none>
Replicas:     2 current / 2 desired
Pods Status:  2 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  team=dev
  Containers:
   nginxcont:
    Image:        nginx
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Events:
  Type    Reason            Age   From                    Message
  ----    ------            ----  ----                    -------
  Normal  SuccessfulCreate  3s    replication-controller  Created pod: nginxrc-r49jg
  Normal  SuccessfulCreate  3s    replication-controller  Created pod: nginxrc-wkjbf
```

It takes labels & Selctor both from Pod template labels (.spec.template.metadata.labels).

## Selector is Mutable  in Replication Controller.
When you update the selector and Pod template labels(.spec.template.metadata.labels), pods that no longer match the new criteria will be orphaned. These pods will continue running but won't be managed by the ReplicationController anymore. The controller won't scale them up or down, and if they crash, they won't be replaced.

## Replication Controller vs Replica Set
- Selector Matching:
    - Replication Controller: Uses only the equality-based selector. It does not support more advanced matching criteria.
    - ReplicaSet: Introduces the use of set-based selectors, allowing for more expressive and flexible pod selection.

- Selectors Immunity:
    - Replication Controller: The selector is mutable; you can update it after creation.
    - ReplicaSet: The selector is immutable after creation. If you need to change the selector, you create a new ReplicaSet.



