# Helm

# What is Helm?
- Helm is a package manager for Kubernetes. Helm is the K8s equivalent of apt or yum. Helm deploys charts, which you can think of as a packaged application. 
- It is collection of all your versioned, you can perform N-number of operation like upgrade, rollback..etc

# Why use Helm?
- Application deployment becomes easy, standardized and reusable 
- While working with huge application you to deal with number of object of kubernetes (i.e. Deployment, confimap, secrets, namespace, statefulsets, daemonsets..etc) to manage and deploy all in such dynamic environment, it becomes difficult, better to package all in one place and deployed the same. 

# Helm installation

# Linux (Ubuntu/debian):
```
    curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
    sudo apt-get install apt-transport-https --yes
    echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt-get update
   sudo apt-get install helm
```
# Windows (Powershell): 

```
   choco install kubernetes-helm
```

# MacOsx (brew):
```
   brew install helm
```


