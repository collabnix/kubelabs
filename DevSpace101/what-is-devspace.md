# DevSpace

Even with the enhancements, we have to CI/CD, testing a Kubernetes application can be troublesome. While tools like Minikube can help you set up a cluster locally within minutes and get right to testing, it's still a long way between there and the final round of testing on an actual k8 server. You would have to verify that it works locally, create a pull request, get it reviewed, and merge it before your change gets integrated with the existing Kubernetes dev cluster. If you have tools such as ArgoCD, it can automate the last step for you but even then, it still takes a fair amount of time.

This doesn't really work well with a shift-left idealogy, where the idea is to do thorough testing at each stage so that errors are caught early. To facilitate this, we can use [DevSpace](https://devspace.sh).

## What DevSpace does

Instead of going through all the steps, it takes to get your change to a Kubernetes cluster, DevSpace allows you to deploy your code to the cluster with every change. It does this by maintaining a configuration file that uses your dockerfile to continuously create and reload the container from your code. Now, it's important to note that DevSpace does not create a new image per change and redeploy the whole container since that would be impractical. Instead, it hot reloads the running container to synchronize your files as you code. This means that you can have log streams running from the container, attach debuggers, etc... without having to worry about the container going offline for each change you do.

DevSpace is also compatible with all sorts of clusters. You could use it on locl clusters managed by Minikube or Microk8s, managed clusters such as AKS and LKE, or self-managed clusters such as Rancher. This level of compatibility makes it possible for any developer to use DevSpace regardless of the size of the application they are running.

Since everyone who uses Kubernetes would have to be familiar with kubectl, DevSpace has the command line syntax made to match that of kubectl. The commands are rather simple. For example, ```devspace init``` initializes your repo and prepares it for deployment while ```devspace deploy``` deploys your project using either kubectl or helm. To watch your files for any changes, you use ```devspace dev```.

DevSpace also comes with a handy UI, which you can bring up using ```devspace ui```. From here, you would be able to start terminal sessions, see real-time logs, inspect namespaces and perform monitoring of your DevSpace.

Since we will only be using DevSpace for development work, it will only ever run in a client machine which is why DevSpace is portrayed as a client-only tool. A high-level design of the system can be found below.

<img src="./DevSpace.png" alt="DevSpace architecture" width="700" />

The devspace.yaml allows you to write a declarative script that handles the workflow surrounding the handling of your application. This config file is best written by the person on your team who has the most knowledge of the cluster and its requirements. Preferably an expert in Kubernetes and DevOps. Once this file has been created and the workflow defined, everyone else just has to pull the config file to their local machines and start working with it.

## Lab

Now, let's try DevSpace and see what it has to offer. To do this, we need to first install the DevSpace CLI, after which we will be creating a docker file that DevSpace has to use to create the image. Then, we can initiate and deploy the image using DevSpace.

For starters, let's download the CLI. There are several different ways to install DevSpaces. You could install it with npm:

```
npm install -g devspace
```

yarn:

```
yarn global add devspace
```

Or you could skip the package managers and install it with curl. Linux:

```
# AMD64
curl -s -L "https://github.com/loft-sh/devspace/releases/latest" | sed -nE 's!.*"([^"]*devspace-linux-amd64)".*!https://github.com\1!p' | xargs -n 1 curl -L -o devspace && chmod +x devspace;
sudo install devspace /usr/local/bin;

# ARM64
curl -s -L "https://github.com/loft-sh/devspace/releases/latest" | sed -nE 's!.*"([^"]*devspace-linux-arm64)".*!https://github.com\1!p' | xargs -n 1 curl -L -o devspace && chmod +x devspace;
sudo install devspace /usr/local/bin;
```

Windows:

```
md -Force "$Env:APPDATA\devspace"; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Tls,Tls11,Tls12';
Invoke-WebRequest -UseBasicParsing ((Invoke-WebRequest -URI "https://github.com/loft-sh/devspace/releases/latest" -UseBasicParsing).Content -replace "(?ms).*`"([^`"]*devspace-windows-amd64.exe)`".*","https://github.com/`$1") -o $Env:APPDATA\devspace\devspace.exe;
$env:Path += ";" + $Env:APPDATA + "\devspace";
[Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::User);
```

Now that you have loft installed, let's start by initializing a project. If you already have a project with a Dockerfile in it, then feel free to use it. Otherwise, loft has provided a convenient set of read-made applications you can find on their [GitHub repo](https://github.com/loft-sh). We will be using the Python project:

```
git clone https://github.com/loft-sh/devspace-quickstart-python
cd devspace-quickstart-python
```

This application is a simple server that serves an HTML page. The [Dockerfile](https://github.com/loft-sh/devspace-quickstart-python/blob/main/Dockerfile) isn't particularly complicated either. It takes a light version of the Python image, installs a handful of requirements, and finally exposes port 8080 so that you can use it to access the application.

To initiate this project, go into the project folder, and run:

```
devspace init
```

You will then be presented with an interactive wizard which allows you to choose things such as the language used in the application, the method of deployment, and how you need to watch your application. Choose the default options, and you will have configured your project to work with DevSpace.