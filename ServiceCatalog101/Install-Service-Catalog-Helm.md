# Install Service Catalog using Helm
Service Catalog is an extension API that enables applications running in Kubernetes clusters to easily use external managed software offerings, such as a datastore service offered by a cloud provider.

It provides a way to list, provision, and bind with external Managed Services from Service Brokers without needing detailed knowledge about how those services are created or managed.

Use Helm to install Service Catalog on your Kubernetes cluster. Up to date information on this process can be found at the kubernetes-sigs/service-catalog repo.

## Steps
- Install Helm v3 or newer
- Add the service-catalog Helm repository 
```
helm repo add svc-cat https://svc-catalog-charts.storage.googleapis.com
```
- Check to make sure that it installed successfully
```
helm search repo service-catalog
```
the output should be similar to this
```
NAME                	CHART VERSION	APP VERSION	DESCRIPTION                                       
svc-cat/catalog     	0.3.0        	           	service-catalog webhook server and controller-m...
svc-cat/catalog-v0.2	0.2.3        	           	service-catalog API server and controller-manag...
```
- Install Service Catalog with Helm repository
```
helm install catalog svc-cat/catalog --namespace catalog
```
- To verify check 
```
kubectl get all -n catalog 
NAME                                                      READY   STATUS    RESTARTS   AGE
pod/catalog-catalog-controller-manager-75fffdcf57-4dc6b   1/1     Running   0          34s
pod/catalog-catalog-webhook-7d8497cdf6-67ztv              1/1     Running   0          34s

NAME                                         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)         AGE
service/catalog-catalog-controller-manager   ClusterIP   10.48.0.101    <none>        443/TCP         36s
service/catalog-catalog-webhook              NodePort    10.48.10.105   <none>        443:31443/TCP   36s

NAME                                                 READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/catalog-catalog-controller-manager   1/1     1            1           36s
deployment.apps/catalog-catalog-webhook              1/1     1            1           36s

NAME                                                            DESIRED   CURRENT   READY   AGE
replicaset.apps/catalog-catalog-controller-manager-75fffdcf57   1         1         1       36s
replicaset.apps/catalog-catalog-webhook-7d8497cdf6              1         1         1       36s
```
