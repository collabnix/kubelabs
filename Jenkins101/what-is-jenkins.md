# Jenkins

Jenkins is one of the most popular ways for you to run automated pipelines. It runs on Java and allows you to have scripted, declarative, and freestyle pipelines. Jenkins also has a massive plugin ecosystem, where you will find plugins that help connect Jenkins to just about everything. It also supports a master-slave configuration where the Jenkins master can delegate tasks to the slave nodes so that multiple jobs can run through the same Jenkins interface, but on different nodes or machines.

Naturally, Jenkins related to just about any other automation tool. Docker, Terraform, Git, and what we'll be discussing here: Kubernetes.

Your Jenkins pipeline can be configured to automate deployment processes. For example, you could set up Jenkins to automatically pick up any changes that are done to your Kubernetes configuration files every time you push changes to your git repository, and have those changes automatically applied to your cluster. However, we have covered this type of implementation before in sections such as [ArgoCD](../GitOps101/argocd.md) and [GitLab](../)