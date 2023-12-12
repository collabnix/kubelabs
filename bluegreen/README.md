# What is Blue-Green Deployment ? 
Blue-Green deployment is basically an application deployment method using which we can easily update one version – named as BLUE while the another version named as GREEN will keep serving the request once done we can switch back to BLUE if required . It has great advantage for real production scenarios, no downtime is required and guess what we can easily switch to older version whenever required .

# How Blue-Green Deployment works ? 
This can be easily archived using labels and selectors; we will mostly use kubectl patch command as below, Note: we can even do this manually by editing service.
```
kubectl patch service  SERVICENAME -p '{"spec":{"selector":{"KEY": "VALUE"}}}'
``` 
In this example we will create two pods with the httpd image and will change the “It Works “message to “It Works – Blue Deployment” and “It Works – Green Deployment” for second Pod. We will also create a service which will map to blue first and once the update is done we will patch it to green. 

# Creating a Pod with Labels
```
git clone https://github.com/collabnix/kubelabs
cd kubelabs/bluegreen
```
```
$ kubectl apply -f blue.yml 
pod/bluepod created
```

```
$ kubectl get pods --show-labels
NAME        READY   STATUS    RESTARTS   AGE   LABELS
bluepod         1/1     Running   0          25m   app=blue
```
$ kubectl apply -f green.yml 
pod/greenpod created
```

```
$ kubectl get pods --show-labels
NAME        READY   STATUS    RESTARTS   AGE   LABELS
bluepod         1/1     Running   0       25m   app=blue
greenpod        1/1     Running   0       28m   app=green
```

```
svc.yml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: testing
  name: myapp
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: blue
status:
  loadBalancer: {}
```
In the above service yaml file we are mapping to our blue pod  via selectors. 

Just for understanding purpose we are changind, the default landing page of our httpd application
```
kubectl exec -it bluepod bash
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
root@bluepod:/usr/local/apache2# echo "Hello from Blue-Pod" >> htdocs/index.html 
exit
```
```
kubectl exec -it greenpod bash
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
root@greenpod:/usr/local/apache2# echo "Hello from Green-Pod" >> htdocs/index.html 
exit
```
We can verify if both the pods are having the updated output or not. 
```
kubectl get pods -o wide
NAME            READY   STATUS    RESTARTS   AGE     IP            NODE     NOMINATED NODE   READINESS GATES
bluepod         1/1     Running   0          5m38s   192.168.1.7   node01   <none>           <none>
greenpod        1/1     Running   0          4m48s   192.168.1.8   node01   <none>           <none>

controlplane $ curl 192.168.1.7
<html><body><h1>It works!</h1></body></html>
Hello from Blue-Pod

controlplane $ curl 192.168.1.8
<html><body><h1>It works!</h1></body></html>
Hello from Green-Pod
controlplane $ 
```
Not let see how it works with service IP 
controlplane $ kubectl get svc
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1      <none>        443/TCP   2d5h
myapp        ClusterIP   10.100.35.84   <none>        80/TCP    2s

curl 10.100.35.84
<html><body><h1>It works!</h1></body></html>
Hello from Blue-Pod
```
Lets try to switch to our green deployment by changing the service mapping using below command, if we try to curl the service IP it should take us to the green pod. 
```
kubectl patch service myapp -p '{"spec":{"selector":{"app": "green"}}}'

controlplane $ curl 10.100.35.84
<html><body><h1>It works!</h1></body></html>
Hello from Green-Pod
```

In this way, we can conclude work on blue green deployment works

# Contributors
[Ashutosh S.Bhakare](https://www.linkedin.com/in/abhakare/).


