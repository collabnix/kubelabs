# Jenkins

Jenkins is one of the most popular ways for you to run automated pipelines. It runs on Java and allows you to have scripted, declarative, and freestyle pipelines. Jenkins also has a massive plugin ecosystem, where you will find plugins that help connect Jenkins to just about everything. It also supports a master-slave configuration where the Jenkins master can delegate tasks to the slave nodes so that multiple jobs can run through the same Jenkins interface, but on different nodes or machines.

Naturally, Jenkins is related to just about any other automation tool. Docker, Terraform, Git, and what we'll be discussing here: Kubernetes.

Your Jenkins pipeline can be configured to automate deployment processes. For example, you could set up Jenkins to automatically pick up any changes that are done to your Kubernetes configuration files every time you push changes to your git repository, and have those changes automatically applied to your cluster. However, we have covered this type of implementation before in sections such as [ArgoCD](../GitOps101/argocd.md) and [GitLab](../GitLab101/what-is-gitlab.md), so we will be touching on something slightly different this time.

You may be well aware that Jenkins can be run as a Docker container. So now, we are going to be using the same concept and running Jenkins as a pod in a Kubernetes cluster.

## Why use Jenkins on Kubernetes

Depending on what you are building and what your Jenkins pipelines do, you need to appropriate amount of system resources. So, you might have a pipeline that runs for 3 hours with a high amount of resource usage, as well as a 30-minute light-weight build that barely needs any resources at all. In this case, if you were to install Jenkins as you normally would on an ordinary VM, you have to ensure that the VM has enough resources to run the high-intensity 3 hours build. However, this also means that when the low-intensity 30-minute build is running, you are not using the VM's full potential. If your builds don't continuously run, then there would be a period where the VM sits idle. This is a huge waste of money and resources, especially if your Jenkins VM is a machine on the cloud which you pay for in the number of minutes it runs in.

The next point is reproducibility. If you set up Jenkins on a VM and run jobs there, the config.xml files of the jobs will be present within the machine only. These config files can be added to source control so that any changes that happen to the positions are tracked. However, Jenkins consists of more than just the config file. If there are specific CPU/memory requirements, you need to be able to reproduce those as well.

Both of the above points are covered when using Kubernetes. Since Kubernetes comes with the ability to orchestrate pods, which includes pod scaling, the number of resources can be scaled up or down depending on the job that needs to be run. You can also specify things such as the memory and CPU in the deployment file so that whenever you deploy the resources, it will automatically request the necessary resources for it to run.

## How it's going to work

First, you are going to need a Kubernetes cluster to run Jenkins on. If you don't have one, I recommend the use of [Minikube](https://minikube.sigs.k8s.io/docs/start/). This will create a single node cluster on your local machine.

Once you have your cluster, you need to create a namespace on which Jenkins will live. Do so with:

```
kubectl create namespace Jenkins
```

Now that the namespace is ready, it's time to install Jenkins. For this, we will be using Helm.