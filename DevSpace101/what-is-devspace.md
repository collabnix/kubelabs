# DevSpace

Even with the enhancements, we have to CI/CD, testing a Kubernetes application can be troublesome. While tools like Minikube can help you set up a cluster locally within minutes and get right to testing, it's still a long way between there and the final round of testing on an actual k8 server. You would have to verify that it works locally, create a pull request, get it reviewed, and merge it before your change gets integrated with the existing Kubernetes dev cluster. If you have tools such as ArgoCD, it can automate the last step for you but even then, it still takes a fair amount of time.

This doesn't really work well with a shift-left idealogy, where the idea is to do thorough testing at each stage so that errors are caught early. To facilitate this, we can use [DevSpace](https://devspace.sh).

## What DevSpace does

Instead of going through all the steps, it takes to get your change to a Kubernetes cluster, DevSpace allows you to deploy your code to the cluster with every change. It does this by maintaining a configuration file that uses your dockerfile to continuously create images from your code. Then, the image is deployed to a K8s cluster and is re-deployed by syncing your changes to match with the cluster. Since everyone who uses Kubernetes would have to be familiar with kubectl, DevSpace has the command line syntax made to match that of kubectl.

The commands are rather simple. For example, ```devspace init``` initializes your repo and prepares it for deployment while ```devspace deploy``` deploys your project using either kubectl or helm. To watch your files for any changes, you use ```devspace dev```.

DevSpace also comes with a handy UI, which you can bring up using ```devspace ui```.