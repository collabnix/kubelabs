# How to know the runtime of Kubernetes 

It's simple. Just run the following command:



```
kubectl get nodes -o jsonpath='{.items[*].status.nodeInfo.containerRuntimeVersion}'
```
