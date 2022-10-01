## Lab

To start with, we need to first install the DevSpace CLI, after which we will be creating a docker file that DevSpace has to use to create the image. Then, we can initiate and deploy the image using DevSpace.

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

You will then be presented with an interactive wizard which allows you to choose things such as the language used in the application, the method of deployment, and how you need to watch your application. Choose the default options, and you will have configured your project to work with DevSpace. You would also notice that this has introduced a devspace.yaml file into your project folder.

If you have worked with any sort of pipelines that can be declared using yaml (such as Bitbucket or Azure DevOps), you would find this file a little familiar. There is a section in the yaml called ```pipelines```. There is one section called "dev", which contains the list of commands that will run when you execute ```devspace dev```, and a section called "deploy" which will run when you call ```devspace deploy```. 

```yaml
pipelines:
  dev:
    run: |-
        ...
  deploy:
    run: |-
        ...
```

Running both commands first deploys any dependencies that this project has, and the dev command then deploys the Helm charts as a deployment resource before starting the app in dev mode. The "deploy" option deploys your image by building it, tagging it, and pushing it before deploying it as a Helm chart. In short, use "dev" while you are doing development and use "deploy" when you are planning on deploying your image.

Next comes the images section. This will include the list of images that will get built using your Dockerfile. 

```yaml
images:
  app:
    image: <image-repo>
    dockerfile: ./Dockerfile
```

Note that you should try not to build images as much as possible when using the dev mode since that would slow down your development process considerably. After that are the deployments section, which defines how your application should be deployed. 

```yaml
deployments:
  app:
    helm:
      chart:
        ...
      values:
        ...
```

If you selected all the defaults, then you also chose Helm as your deployment method, and this will be shown here. If you instead selected some other deployment method such as kubectl, then that will show up. This is also the part which houses the information to use when you run the ```devspace deploy``` command.

When you run the ```devspace dev``` command, that corresponds to the next part of the file. 

```yaml
dev:
  app:
    imageSelector: ghcr.io/loft-sh/devspace/app
    devImage: ghcr.io/loft-sh/devspace-containers/go:1.18-alpine
    ports:
      - port: "2345"
      - port: "8080"
```

Under the ```dev``` section of the yaml,  you define everything that is needed to get the hot-reloading development environment up and running. This includes the devImage, the ports that it should open, proxy commands, and so on.

Now you have a fully configured DevSpace project that is ready to be deployed. However, you now need a cluster to deploy this project to. If you already have a cluster available, you can go ahead and deploy it to this cluster. If not, using [Minikube](https://minikube.sigs.k8s.io/docs/start/) is the fastest and most convenient way to get a simple, one-node cluster up and running on your local machine. You can install it on any platform, and you can use several drivers ranging from Docker to Hyper-V to set up Minikube.

Once you have a cluster up and running, make sure the kubeconfig file for your cluster is where it should be. Then, make sure that DevSpace uses this kubeconfig file and the cluster associated with it:

```
devspace use context               
devspace use namespace collabnix-lab
```

The first command will set devspace to be used in the context of your Kubernetes cluster specified by the kubeconfig. The second specifies the namespace that will be automatically created during deployment time. Once everything has been set properly, start-up DevSpace:

```
devspace dev
```

This will run using the configuration you provided under the ```dev``` part of the ```devspace.yaml```. Note that these lines are written in emulated bash. That means that you can add any ordinary bash commands here and it will run as if it was running in a bash shell. However, since it is emulated, you could just run this command on a Windows machine and have it work the same way. Now, let's start the application. Since we are running a Python application, use:

```
python main.py
```

And you're done! You now have an application that gets deployed to a Kubernetes cluster but also gets reloaded every time you make a change, meaning that you can see your changes apply in real-time. Open up the project using your favourite IDE, and do a change. Once the change is done, save it, and your file should get reloaded in the cluster. Since the yaml controls the whole process, if you need to exclude files from being synced, make sure to change that in the ```sync``` part of the yaml.

If you need to perform debugging on your application, DevSpace allows you to attach your debugger by allowing port forwarding. To specify which ports need forwarding, you can edit the yaml. If you head over to your terminal instance that runs DevSpace, you will notice that your application has started syncing. You will also notice that a stream of logs has started getting written to the terminal, which displays any errors or events that need your attention. If you update your project files, this log stream will get updated to show that changes were applied. You can run commands such as:

```
kubectl get pod
kubectl get deployment
kubectl get svc
```

These will show you all the pods, deployments, and services that have been created when you ran ```devspace dev```. What you should note is that when you updated a file, the pod didn't get recreated. If that happened, you would have to wait until the pod came back up, which would have taken much longer. Instead, only the container the pod was running on got reloaded. You can also use ```helm ls``` to see the helm chart that was used to deploy all this (in the case that you used helm to install the chart). The helm chart gets created out of the values you place under the ```deployment``` section of the devspace yaml. However, if you have your own Helm chart (that is, you create a Helm chart that can be used to deploy your application), then you can specify the helm chart directly in the devspace.yaml.

Also don't forget, you also have a UI that you can use for monitoring purposes that you can access with 

```
devspace ui 
```

This UI allows you to check the logs of each cluster, which is much more user-friendly than sifting through the logs in the terminal. If you have multiple clusters, then you can select which cluster you want using the drop-down options in the KubeContext. You can then drill down further by selecting which namespace you want. This will give you a list of pods that DevSpace is managing. You can select the pod to get its individual log, and you can also sh into the pod from here using an interactive terminal.

So, to conclude, you can see how DevSpace is a very useful tool for any developer in organizations ranging from small to big. If you are working in a team, the whole team can use a single devspace, and if you're working individually, you can still use DevSpace to hot reload containers. This makes the development process much more efficient, and a lot faster.