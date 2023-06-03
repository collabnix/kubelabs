# Accessing the Kubernetes API

## Pre-requisite

- [Setup 5 Node Kubernetes Cluster](https://collabnix.github.io/kubelabs/kube101.html)

When accessing the Kubernetes API for the first time, use the Kubernetes command-line tool, `kubectl`. To access a cluster, you need to know the location of the cluster and have credentials to access it. 

## Checking the location & credentials

```
[node1 kubelabs]$ kubectl config view
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://192.168.0.18:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
current-context: kubernetes-admin@kubernetes
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate
```
 
 
## Directly accessing the REST API
 
The kubectl handles locating and authenticating to the API server. 
If you want to directly access the REST API with an HTTP client like `curl` or `wget`, or a browser, there are multiple ways you can 
locate and authenticate against the API server:

- Run `kubectl` in proxy mode (recommended). This method is recommended, since it uses the stored apiserver location and verifies the identity of the API server using a self-signed cert. No man-in-the-middle (MITM) attack is possible using this method.
- Provide the location and credentials directly to the HTTP client. This works with client code that is confused by proxies. 
To protect against man in the middle attacks, you’ll need to import a root cert into your browser.
Using the Go or Python client libraries provides accessing `kubectl` in proxy mode.

## Using kubectl proxy

Running kubectl in proxy mode allows you to establish a secure connection to the Kubernetes API server without exposing it directly to the outside world. It acts as a bridge between your local machine and the Kubernetes cluster's API server.

Here are a few reasons why you might want to run kubectl in proxy mode for API access:

- Security: By default, the Kubernetes API server may be configured to only accept connections from within the cluster's network. Running kubectl in proxy mode allows you to securely access the API server from your local machine without needing to expose it externally. This helps protect the API server from unauthorized access and potential security threats.

- Network Restrictions: In some environments, network restrictions or firewalls may prevent direct access to the Kubernetes API server. Running kubectl in proxy mode allows you to bypass these restrictions by establishing a connection through a proxy. This is especially useful in scenarios where you are working remotely or in a restricted network environment.

- Simplified Authentication: Running kubectl in proxy mode can simplify the authentication process. Instead of configuring authentication credentials directly on your local machine, the proxy handles the authentication on your behalf. It may use the authentication options configured on the cluster, such as client certificates or tokens, to authenticate and authorize your API requests.

- Local Development: Proxy mode is often used during local development to interact with the Kubernetes API server running in a remote cluster. It allows developers to test and debug their applications against the cluster's API without the need for direct access or exposing the cluster to the local machine.

To run kubectl in proxy mode, you can use the following command:

```
kubectl proxy
```

This will start a local proxy server that listens on a specified port (default is 8001). Once the proxy is running, you can access the Kubernetes API server by making requests to localhost or 127.0.0.1 on the designated port.

Running kubectl in proxy mode provides a secure and convenient way to access the Kubernetes API server, allowing you to interact with and manage your cluster from your local machine.

The following command runs `kubectl` in a mode where it acts as a reverse proxy. It handles locating the API server and authenticating.

```
kubectl proxy --port=8080 &
```

Then you can explore the API with `curl`, `wget`, or a browser, like so:

```
curl http://localhost:8080/api/
```

The output is similar to this:

```
[node1 kubelabs]$ curl http://localhost:8080/api/
{
  "kind": "APIVersions",
  "versions": [
    "v1"
  ],
  "serverAddressByClientCIDRs": [
    {
      "clientCIDR": "0.0.0.0/0",
      "serverAddress": "192.168.0.18:6443"
    }
  ]
```
  
## Without kubectl proxy
  
  
```
  # Check all possible clusters, as you .KUBECONFIG may have multiple contexts:
kubectl config view -o jsonpath='{"Cluster name\tServer\n"}{range .clusters[*]}{.name}{"\t"}{.cluster.server}{"\n"}{end}'

# Select name of cluster you want to interact with from above output:
export CLUSTER_NAME="some_server_name"

# Point to the API server referring the cluster name
APISERVER=$(kubectl config view -o jsonpath="{.clusters[?(@.name==\"$CLUSTER_NAME\")].cluster.server}")

# Gets the token value
TOKEN=$(kubectl get secrets -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='default')].data.token}"|base64 --decode)

# Explore the API with TOKEN
curl -X GET $APISERVER/api --header "Authorization: Bearer $TOKEN" --insecure
```

[ Next >>](https://collabnix.github.io/kubelabs/pods101/deploy-your-first-nginx-pod.html)
