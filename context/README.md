# How to delete Kubernetes Cluster using ```kubectl config```

Context is different from Cluster. To delete the cluster, use the below CLI:


Say, you have multiple Kubernetes cluster as listed below:

```
[Captains-Bay]🚩 >  kubectl config view|more
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://036E0C0FBDDF8738A2A2E3CF40E7BFE6.sk1.us-east-2.eks.amazonaws.com
  name: amazing-mushroom-1592298240.us-east-2.eksctl.io
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://83AEAE7D9A99A68DFA4162E18F4AD470.gr7.us-east-2.eks.amazonaws.com
  name: arn:aws:eks:us-east-2:125346028423:cluster/training-eks-9Vir2IUu
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://BE4A3B69D0229AE5AD01A0915EFFBD08.yl4.us-east-2.eks.amazonaws.com
  name: beautiful-creature-1591004252.us-east-2.eksctl.io
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://kubernetes.docker.internal:6443
  name: docker-desktop
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://0E0BC4B9A938622E31159B2A8B6297F9.gr7.us-east-2.eks.amazonaws.com
  name: fabulous-sculpture-1591045453.us-east-2.eksctl.io
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://75D85FFCB3BE9DA23F34EA9CAA51BF53.gr7.us-east-2.eks.amazonaws.com
  name: ferocious-monster-1591041531.us-east-2.eksctl.io
- cluster:
```

If you want to delete those clusters one by one, you need to run the below command:


```
[Captains-Bay]🚩 >  kubectl config delete-cluster fabulous-sculpture-1591045453.us-east-2.eksctl.io
deleted cluster fabulous-sculpture-1591045453.us-east-2.eksctl.io from /Users/ajeetraina/.kube/config
```

## Contexts


```
[Captains-Bay]🚩 >  kubectl config get-contexts
CURRENT   NAME                                                                 CLUSTER                                                            AUTHINFO                                                             NAMESPACE
          arn:aws:eks:us-east-2:125346028423:cluster/training-eks-9Vir2IUu     arn:aws:eks:us-east-2:125346028423:cluster/training-eks-9Vir2IUu   arn:aws:eks:us-east-2:125346028423:cluster/training-eks-9Vir2IUu
*         docker-desktop                                                       docker-desktop                                                     docker-desktop
          docker-for-desktop                                                   docker-desktop                                                     docker-desktop
          iam-root-account@amazing-mushroom-1592298240.us-east-2.eksctl.io     amazing-mushroom-1592298240.us-east-2.eksctl.io                    iam-root-account@amazing-mushroom-1592298240.us-east-2.eksctl.io     jx
          iam-root-account@beautiful-creature-1591004252.us-east-2.eksctl.io   beautiful-creature-1591004252.us-east-2.eksctl.io                  iam-root-account@beautiful-creature-1591004252.us-east-2.eksctl.io   jx
          iam-root-account@fabulous-sculpture-1591045453.us-east-2.eksctl.io   fabulous-sculpture-1591045453.us-east-2.eksctl.io                  iam-root-account@fabulous-sculpture-1591045453.us-east-2.eksctl.io   jx
          iam-root-account@ferocious-mongoose-1592288955.us-east-2.eksctl.io   ferocious-mongoose-1592288955.us-east-2.eksctl.io                  iam-root-account@ferocious-mongoose-1592288955.us-east-2.eksctl.io   jx
          iam-root-account@ferocious-monster-1591041531.us-east-2.eksctl.io    ferocious-monster-1591041531.us-east-2.eksctl.io                   iam-root-account@ferocious-monster-1591041531.us-east-2.eksctl.io    jx
          iam-root-account@unique-painting-1591039510.us-east-2.eksctl.io      unique-painting-1591039510.us-east-2.eksctl.io                     iam-root-account@unique-painting-1591039510.us-east-2.eksctl.io      jx
          minikube                                                             minikube                                                           minikube                                                             jx
[Captains-Bay]🚩 >  kubectl config delete-context iam-root-account@amazing-mushroom-1592298240.us-east-2.eksctl.io
deleted context iam-root-account@amazing-mushroom-1592298240.us-east-2.eksctl.io from /Users/ajeetraina/.kube/config
```
