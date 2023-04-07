# Deny Egress Traffic That Has No Rules

We’re doing the same thing here but on egress traffic. The following NetworkPolicy definition will deny all outgoing traffic unless allowed by another rule:


## Steps
```
git clone https://github.com/collabnix/kubelabs.git
cd kubelabs/Network_Policies101/
kubectl apply -f default-deny-egress.yaml
```
## Verify Access - Denied All Egress

We can see that this is the case by switching over to our “access” pod in the namespace and attempting to  wget google.com.


```
 kubectl run --generator=run-pod/v1  --namespace=network-policy-demo access --rm -ti --image busybox /bin/sh

 wget -q --timeout=5 google.com -O -

 [node1 ~]$  kubectl run --generator=run-pod/v1  --namespace=network-policy-demo access --rm -ti --image busybox /bin/sh
 If you don't see a command prompt, try pressing enter.
 / # wget -q --timeout=5 google.com -O -
 wget: bad address 'google.com'
 / #

 ```
