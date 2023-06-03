
# Installing kubernetes with kubeadm on Ubuntu 16.04+/Debian 9+/HypriotOS v1.0.1+


## Installing kubeadm kubectl kubelet

Copy paste the below snippet one by one in your CLI terminal - This is for both Master and Worker Nodes

```
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

## Initialize kubeadm - This is only for Master

```
kubeadm init
```

## Setting up kubeconfig - This is only for Master Node

```
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```


## Copying token from kubeadmn init snippet - This you should copy from Master. This you will get from Master node only

```
kubeadm join <control-plane-host>:<control-plane-port> --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```


## Installing Network Plugin - This is only for Master Node

```
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```


## Joining Worker Nodes - This is only for Worker Nodes

```
kubeadm join --token <token> <control-plane-host>:<control-plane-port> --discovery-token-ca-cert-hash sha256:<hash>
```

## Note:

Please do not run Master node snippet commands on Worker Nodes.

## References 
1. https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl
2. https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#initializing-your-control-plane-node
