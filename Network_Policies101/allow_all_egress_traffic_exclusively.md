# Allow All Egress Traffic Exclusively

Like we did on the ingress part, sometimes you want to exclusively allow all egress traffic even if some other policies are denying it. The following NetworkPolicy will override all other egress rules and allow all traffic from all pods to any destination:

## Steps
```
git clone https://github.com/collabnix/kubelabs.git
cd kubelabs/Network_Policies101/
```
```
kubectl apply -f allow-egress.yaml

```
## Verify Access - Allowed Egress

We can see that this is the case by switching over to our “access” pod in the namespace and attempting to access the google.com .

```
 kubectl run --generator=run-pod/v1  --namespace=network-policy-demo access --rm -ti --image busybox /bin/sh

wget -q --timeout=5 google.com -O -
 
/ # wget -q --timeout=5 google.com -O -
<!doctype html><html itemscope="" itemtype

```

Now we are able to access google.

## Cleanup Namespace

```
kubectl delete ns network-policy-demo
```
