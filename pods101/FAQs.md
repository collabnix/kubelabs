## List of FAQs

## Que: 1. Say, I have 3 Pods running in ns3. If I delete namespace ns3 by running kubectl delete -n ns3, what will happen?

When you delete a namespace in Kubernetes using the kubectl delete command, all the resources within that namespace, including pods, will be deleted. In your case, if you delete the namespace ns3 with three pods running inside it, the following will happen:

The three pods running in namespace ns3 will be terminated and removed from the cluster.
Any associated resources linked to those pods, such as services, deployments, and config maps, will also be deleted.
Persistent volumes and persistent volume claims that were created within the ns3 namespace will be removed if they are not associated with any other resources outside the namespace.
Events related to the deleted resources will be removed from the cluster's event history.
If there are any other namespaces, they will not be affected by the deletion of ns3.
It's important to note that the deletion process is irreversible, and all data and state associated with the pods and other resources within the namespace will be lost. Therefore, exercise caution when deleting namespaces or any other Kubernetes resources to avoid unintended data loss.
