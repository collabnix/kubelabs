# Deny Egress Traffic That Has No Rules

We’re doing the same thing here but on egress traffic. You can find a NetworkPolicy definition that will deny all outgoing traffic unless allowed by another rule [here](./default-deny-egress.yaml). As you can see, it is basically the same thing as the rule that allowed no ingresses.

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

Now, let's take a look at the other side of what we have been doing. What do we do if we want to only allow all ingress traffic (and not egress)? For example, there might be a debugging situation where you need to test an application without having to worry about the network policies, meaning that you want to override any policies that are curently applied. So let's look into that.

[Next: allowing ingress traffic](./allow_all_ingress_traffic_exclusively.md)