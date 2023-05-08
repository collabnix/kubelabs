# Getting Started with CKA Preparation

## Table of Contents

```
git clone https://github.com/collabnix/cka-practice-environment
```

Bring up Test Practice Environment

```
docker-compose up -d
```


```
sudo apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF |  tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```
