## List of FAQs

## Que: 1. Say, I have 3 Pods running in ns3. If I delete namespace ns3 by running kubectl delete -n ns3, what will happen?

When you delete a namespace in Kubernetes using the kubectl delete command, all the resources within that namespace, including pods, will be deleted. In your case, if you delete the namespace ns3 with three pods running inside it, the following will happen:

The three pods running in namespace ns3 will be terminated and removed from the cluster.
Any associated resources linked to those pods, such as services, deployments, and config maps, will also be deleted.
Persistent volumes and persistent volume claims that were created within the ns3 namespace will be removed if they are not associated with any other resources outside the namespace.
Events related to the deleted resources will be removed from the cluster's event history.
If there are any other namespaces, they will not be affected by the deletion of ns3.
It's important to note that the deletion process is irreversible, and all data and state associated with the pods and other resources within the namespace will be lost. Therefore, exercise caution when deleting namespaces or any other Kubernetes resources to avoid unintended data loss.

```
kubectl get po,svc,deploy -n ns3
NAME                        READY   STATUS    RESTARTS        AGE
pod/nginx-76d6c9b8c-hm899   1/1     Running   9 (8m35s ago)   6d20h
pod/nginx-76d6c9b8c-lpxhg   1/1     Running   9 (8m35s ago)   6d20h
pod/nginx-76d6c9b8c-pkkks   1/1     Running   9 (8m35s ago)   6d20h

NAME            TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
service/nginx   NodePort   10.99.254.4   <none>        80:30260/TCP   6d20h

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx   3/3     3            3           6d20h
```

```
kubectl delete ns ns3
namespace "ns3" deleted
```
