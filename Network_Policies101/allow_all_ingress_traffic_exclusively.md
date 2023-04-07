# Allow All Ingress Traffic Exclusively

We may want to override any other NetworkPolicy that restricts traffic to your pods, perhaps for troubleshooting a connection issue. This can be done by applying the following NetworkPolicy definition:

## Steps
```
git clone https://github.com/collabnix/kubelabs.git
cd kubelabs/Network_Policies101/
```
Run the following to create a NetworkPolicy which allows traffic  from any pods in the network-policy-demo namespace.

```
kubectl apply -f allow-ingress.yaml
```

## Verify Access - Allowed Ingress

Now ingress traffic to nginx will be allowed. We can see that this is the case by switching over to our “access” pod in the namespace and attempting to access the nginx service.

```
 kubectl run --generator=run-pod/v1  --namespace=network-policy-demo access --rm -ti --image busybox /bin/sh

wget -q --timeout=5 nginx -O -
```

```
/ # wget -q --timeout=5 nginx -O -
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

The only difference we have here is that we add an ingress object with no rules at all.

Be aware, though, that this policy will override any other isolating policy in the same namespace.
