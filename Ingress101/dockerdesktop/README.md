## Install Ingress-Nginx to your Docker Desktop Kubernetes

## 1. Apply the ingress controller configs for Kubernetes

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.6.4/deploy/static/provider/cloud/deploy.yaml
```

## 2. Check the ingress-controller with this command 

```
kubectl -n ingress-nginx get pod

NAME                                        READY   STATUS      RESTARTS   AGE
ingress-nginx-admission-create-w4r54        0/1     Completed   0          30s
ingress-nginx-admission-patch-vxs6c         0/1     Completed   1          30s
ingress-nginx-controller-6b94c75599-z27dp   1/1     Running     0          30s
```

Your local Kubernetes cluster is ready to serve real HTTP traffic.

## Step 3. Testing the Ingress-Controller with a little Demo App

Let’s confirm it working by applying some test workload and exposing it with an ingress object:

```
kubectl apply -f https://raw.githubusercontent.com/gefyrahq/gefyra/main/testing/workloads/hello_dd.yaml
```

This is the “hello-nginx” application, from our Kubernetes development tool Gefyra

If you check the ingress objects with:

```
kubectl get ingress

NAME            CLASS    HOSTS                    ADDRESS   PORTS   AGE
hello-ingress   <none>   hello.127.0.0.1.nip.io             80      7s
```

you will find the hello-ingress object to be reachable on http://hello.127.0.0.1.nip.io (this requires nip.io Domains to work 
in your current network; if not look for “DNS rebind protection”). 
Once you point your browser to that address you will be welcomed with the Hello Nginx screen.



![image](https://github.com/collabnix/kubelabs/assets/313480/2056387d-1211-49ba-9e8e-13d18859c901)

It tells a bit about your cluster: the pod name of the process running this simple page and the IP address of the pod.

