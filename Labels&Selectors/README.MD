# Labels and Selectors
In this tutorial we will learn how labels and selectors work in Kubernetes using service and pod scenario. 

# How Service uses a Selector to Map a POD IP as endpoint
In kubernetes, each pod will have a metadata definition underwhich we can define its name and labels. Labels help kubernetes to indentify the object for filtering and groupping purposes. Label uses key:value syntax , usualy each pod will have unique labels in the form of key:value pair defined.
Lets getting into the demo part now

# Creating a Pod with Labels
```
git clone https://github.com/collabnix/dockerlabs
cd dockerlabs/Labels&Selectors/
$ kubectl create -f pod.yml 
pod/mywebapp1 created
$ kubectl get pods --show-labels
NAME        READY   STATUS    RESTARTS   AGE   LABELS
mywebapp1   1/1     Running   0          10s   demo=kubelabs
```
In the above example, we have created a pod with a name called mywebapp1 and has a label called demo = kubelabs, We can create a service and map the pod to it using the same labels, which can be referred as to selector in our service definition file as below. 
```
svc.yml
kind: Service
apiVersion: v1
metadata:
  name: myservice
spec:
  selector: 
      demo: kubelabs  
  ports:
    - protocol: TCP
      port: 8081
      targetPort: 80
```
In the above service yaml file the spec section is mapping to the pod using selector attribute, it will group all the pods together having labels (key:value) called **demo=kubelabs**

```
$ kubectl create -f svc.yml 
service/myservice created

$ kubectl get pods -o wide  
NAME        READY   STATUS    RESTARTS   AGE     IP            NODE     NOMINATED NODE   READINESS GATES
mywebapp1   1/1     Running   0          6m55s   192.168.1.3   node01   <none>           <none>

$ kubectl describe svc myservice
Name:              myservice
Namespace:         default
Labels:            <none>
Annotations:       <none>
Selector:          demo=kubelabs
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.99.106.38
IPs:               10.99.106.38
Port:              <unset>  8081/TCP
TargetPort:        80/TCP
Endpoints:         192.168.1.3:80
Session Affinity:  None
Events:            <none>
```
As per the above output, we can clearly see the Endpoints of the service is mapping to our **PODIP** which is 192.168.1.3 in our case, I we create one more pod using the same labels, the service automatically detected the new pods and add the IP of that pod directly to Endpoint list. As per the below output the newly created pod having 192.168.1.4 IP address got added to endpoints of the service. 

```
$ kubectl create -f pod1.yml 
pod/mywebapp2 created
$ kubectl get pods -o wide 
NAME        READY   STATUS    RESTARTS   AGE   IP            NODE     NOMINATED NODE   READINESS GATES
mywebapp1   1/1     Running   0          10m   192.168.1.3   node01   <none>           <none>
mywebapp2   1/1     Running   0          3s    192.168.1.4   node01   <none>           <none>
$ kubectl describe svc myservice
Name:              myservice
Namespace:         default
Labels:            <none>
Annotations:       <none>
Selector:          demo=kubelabs
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.99.106.38
IPs:               10.99.106.38
Port:              <unset>  8081/TCP
TargetPort:        80/TCP
Endpoints:         192.168.1.3:80,192.168.1.4:80
Session Affinity:  None
Events:            <none>
```
In this way, we can conclude work on how the Labels and selectors work in POD and SERVICE scenarios. 

# Contributors
[Ashutosh S.Bhakare](https://www.linkedin.com/in/abhakare/).


