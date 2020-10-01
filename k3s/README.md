
# Running Portainer for K3s on Raspberry Pi

```
$ curl -sfL https://get.k3s.io | sh -
[INFO]  Finding release for channel stable
[INFO]  Using v1.18.2+k3s1 as release
[INFO]  Downloading hash https://github.com/rancher/k3s/releases/download/v1.18.2+k3s1/sha256sum-arm.txt
[INFO]  Downloading binary https://github.com/rancher/k3s/releases/download/v1.18.2+k3s1/k3s-armhf
[INFO]  Verifying binary download
[INFO]  Installing k3s to /usr/local/bin/k3s
[INFO]  Skipping /usr/local/bin/kubectl symlink to k3s, already exists
[INFO]  Skipping /usr/local/bin/crictl symlink to k3s, already exists
[INFO]  Skipping /usr/local/bin/ctr symlink to k3s, command exists in PATH at /usr/bin/ctr
[INFO]  Creating killall script /usr/local/bin/k3s-killall.sh
[INFO]  Creating uninstall script /usr/local/bin/k3s-uninstall.sh
[INFO]  env: Creating environment file /etc/systemd/system/k3s.service.env
[INFO]  systemd: Creating service file /etc/systemd/system/k3s.service
[INFO]  systemd: Enabling k3s unit
Created symlink /etc/systemd/system/multi-user.target.wants/k3s.service → /etc/systemd/system/k3s.service.
[INFO]  systemd: Starting k3s
```
# Running K3s with Docker Runtime

- K3s by default comes with containerd runtime, to use docker as container runtime for K3s then use be
low docker argument with K3s command

```
$ curl -sfL https://get.k3s.io | sh -s - --docker

```

```
$ k3s --version
k3s version v1.18.2+k3s1 (698e444a)
```

```
$ sudo k3s kubectl get nodes
NAME     STATUS   ROLES    AGE   VERSION
raspi2   Ready    master   35h   v1.18.2+k3s1
```


```
$ sudo k3s kubectl get componentstatus
NAME                 STATUS    MESSAGE   ERROR
scheduler            Healthy   ok
controller-manager   Healthy   ok
```

```
$ sudo kubectl get nodes
NAME     STATUS   ROLES    AGE   VERSION
raspi2   Ready    master   36h   v1.18.2+k3s1
```

If you run kubectl get pods --all-namespaces, you will see some extra pods for Traefik. Traefik is a reverse proxy and load balancer that we can use to direct traffic into our cluster from a single entry point. Kubernetes allows for this but doesn't provide such a service directly. Having Traefik installed by default is a nice touch by Rancher Labs. This makes a default k3s install fully complete and immediately usable!

We're going to explore using Traefik through Kubernetes ingress rules and deploy all kinds of goodies to our cluster in future articles. Stay tuned!

```
sudo cat /var/lib/rancher/k3s/server/node-token
K100d0d84a5bcb9cadc03b7acdc6e81a63334380fc337d3275eca432755fb450f0c::server:XXXXXX7977f17f3
```


```
$ wget https://raw.githubusercontent.com/portainer/portainer-k8s/master/portainer-nodeport.yaml
$ sudo kubectl apply -f portainer-nodeport.yaml
namespace/portainer created
serviceaccount/portainer-sa-clusteradmin created
clusterrolebinding.rbac.authorization.k8s.io/portainer-crb-clusteradmin created
service/portainer created
deployment.apps/portainer created
```

```
 $ sudo kubectl get po,svc,deploy -n portainer
NAME                             READY   STATUS    RESTARTS   AGE
pod/portainer-669cbb94f6-g87bb   1/1     Running   12         99m

NAME                TYPE       CLUSTER-IP   EXTERNAL-IP   PORT(S)                         AGE
service/portainer   NodePort   10.43.2.13   <none>        9000:30777/TCP,8000:30776/TCP   99m

NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/portainer   1/1     1            1           99m
```

