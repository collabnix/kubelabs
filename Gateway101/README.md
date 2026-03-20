# Kubernetes Gateway API 101

The **Kubernetes Gateway API** is the next-generation traffic management API for Kubernetes, designed to be a more expressive, extensible, and role-oriented successor to the Ingress API. It is a standard part of the Kubernetes ecosystem (maintained by the SIG-Network community) and is now the recommended way to expose HTTP, HTTPS, and TCP services in Kubernetes.

## What You Will Learn

- What the Gateway API is and how it differs from Ingress
- Core resources: `GatewayClass`, `Gateway`, and `HTTPRoute`
- How to install a Gateway API-compatible controller
- How to expose a service using the Gateway API
- Advanced routing: path-based, header-based, and traffic splitting

---

## Why Gateway API Over Ingress?

| Feature | Ingress | Gateway API |
|---|---|---|
| Role separation | Single resource | `GatewayClass` (infra), `Gateway` (operator), `HTTPRoute` (developer) |
| Multiple protocols | HTTP/HTTPS only | HTTP, HTTPS, TCP, TLS, UDP |
| Traffic splitting | Vendor annotation | Native weight-based routing |
| Header/path matching | Limited | Rich, expressive matching |
| Cross-namespace routing | Not supported | Supported via `ReferenceGrant` |
| Extensibility | Vendor annotations | Typed extension points |

---

## Core Resources

### 1. GatewayClass

A `GatewayClass` defines the type of load balancer infrastructure to provision. It is cluster-scoped and managed by infrastructure providers (similar to `StorageClass`).

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: nginx
spec:
  controllerName: gateway.nginx.org/nginx-gateway-controller
```

### 2. Gateway

A `Gateway` represents an instance of a load balancer. It is managed by cluster operators and specifies listeners (ports and protocols).

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: my-gateway
  namespace: default
spec:
  gatewayClassName: nginx
  listeners:
    - name: http
      port: 80
      protocol: HTTP
```

### 3. HTTPRoute

An `HTTPRoute` defines how HTTP traffic reaching the `Gateway` is routed to backend services. Developers manage this resource to define application-level routing rules.

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: my-app-route
  namespace: default
spec:
  parentRefs:
    - name: my-gateway
  hostnames:
    - "myapp.example.com"
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /
      backendRefs:
        - name: my-service
          port: 8080
```

---

## Lab 1: Installing the Gateway API CRDs

The Gateway API CRDs must be installed before any controller. Run the following to install the latest stable CRDs:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml
```

Verify the CRDs are installed:

```bash
kubectl get crd gateways.gateway.networking.k8s.io \
               gatewayclasses.gateway.networking.k8s.io \
               httproutes.gateway.networking.k8s.io
```

Expected output:

```
NAME                                        CREATED AT
gateways.gateway.networking.k8s.io         2024-01-01T00:00:00Z
gatewayclasses.gateway.networking.k8s.io   2024-01-01T00:00:00Z
httproutes.gateway.networking.k8s.io       2024-01-01T00:00:00Z
```

---

## Lab 2: Installing NGINX Gateway Fabric (Controller)

We will use [NGINX Gateway Fabric](https://github.com/nginxinc/nginx-gateway-fabric) as our Gateway API controller. It is a CNCF-certified implementation.

```bash
# Install NGINX Gateway Fabric
kubectl apply -f https://raw.githubusercontent.com/nginxinc/nginx-gateway-fabric/v1.3.0/deploy/crds.yaml
kubectl apply -f https://raw.githubusercontent.com/nginxinc/nginx-gateway-fabric/v1.3.0/deploy/default/deploy.yaml
```

Verify the controller is running:

```bash
kubectl get pods -n nginx-gateway
```

Expected output:

```
NAME                             READY   STATUS    RESTARTS   AGE
nginx-gateway-5d4f7b9c8d-xklt2  2/2     Running   0          30s
```

---

## Lab 3: Deploy a Sample Application

Apply the sample Deployment and Service:

```bash
kubectl apply -f https://raw.githubusercontent.com/collabnix/kubelabs/master/Gateway101/demo-app.yaml
```

Or create them manually:

```bash
kubectl create deployment demo --image=httpd:alpine --port=80
kubectl expose deployment demo --port=80
```

---

## Lab 4: Create the GatewayClass and Gateway

Apply the `GatewayClass` and `Gateway` manifests:

```bash
kubectl apply -f https://raw.githubusercontent.com/collabnix/kubelabs/master/Gateway101/gateway.yaml
```

Check the Gateway status:

```bash
kubectl get gateway my-gateway
```

Expected output:

```
NAME         CLASS   ADDRESS        PROGRAMMED   AGE
my-gateway   nginx   192.168.1.10   True         60s
```

The `PROGRAMMED: True` status means the Gateway is ready to route traffic.

---

## Lab 5: Create an HTTPRoute

Apply the `HTTPRoute` manifest:

```bash
kubectl apply -f https://raw.githubusercontent.com/collabnix/kubelabs/master/Gateway101/http-route.yaml
```

Check the HTTPRoute status:

```bash
kubectl get httproute demo-route
```

Test the route using the Gateway address:

```bash
GATEWAY_IP=$(kubectl get gateway my-gateway -o jsonpath='{.status.addresses[0].value}')
curl http://$GATEWAY_IP/ -H "Host: demo.example.com"
```

Expected output:

```html
<html><body><h1>It works!</h1></body></html>
```

---

## Lab 6: Advanced Routing — Path-Based Routing

The Gateway API supports rich routing rules. This example routes `/api` to one service and `/web` to another:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: path-based-route
  namespace: default
spec:
  parentRefs:
    - name: my-gateway
  hostnames:
    - "myapp.example.com"
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /api
      backendRefs:
        - name: api-service
          port: 8080
    - matches:
        - path:
            type: PathPrefix
            value: /web
      backendRefs:
        - name: web-service
          port: 80
```

---

## Lab 7: Traffic Splitting (Canary / Blue-Green)

The Gateway API natively supports weight-based traffic splitting, making canary deployments easy without any vendor annotations:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: canary-route
  namespace: default
spec:
  parentRefs:
    - name: my-gateway
  hostnames:
    - "myapp.example.com"
  rules:
    - backendRefs:
        - name: my-app-stable
          port: 80
          weight: 90
        - name: my-app-canary
          port: 80
          weight: 10
```

This sends 90% of traffic to the stable version and 10% to the canary.

---

## Lab 8: Header-Based Routing

Route requests to a specific backend based on request headers (useful for A/B testing):

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: header-route
  namespace: default
spec:
  parentRefs:
    - name: my-gateway
  hostnames:
    - "myapp.example.com"
  rules:
    - matches:
        - headers:
            - name: X-User-Group
              value: beta-testers
      backendRefs:
        - name: my-app-beta
          port: 80
    - backendRefs:
        - name: my-app-stable
          port: 80
```

---

## Cleaning Up

Remove all Gateway API resources created in this tutorial:

```bash
kubectl delete httproute demo-route path-based-route canary-route header-route --ignore-not-found
kubectl delete gateway my-gateway --ignore-not-found
kubectl delete gatewayclass nginx --ignore-not-found
kubectl delete deployment demo --ignore-not-found
kubectl delete service demo --ignore-not-found
```

---

## Further Reading

- [Kubernetes Gateway API Official Docs](https://gateway-api.sigs.k8s.io/)
- [Gateway API vs Ingress](https://gateway-api.sigs.k8s.io/concepts/api-overview/)
- [NGINX Gateway Fabric](https://github.com/nginxinc/nginx-gateway-fabric)
- [Gateway API Implementations](https://gateway-api.sigs.k8s.io/implementations/)
- [Ingress101 Tutorial](../Ingress101/README.md)
- [Services101 Tutorial](../Services101/README.md)
- [Network Policies Tutorial](../Network_Policies101/README.md)
