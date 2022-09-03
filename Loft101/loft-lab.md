## Lab

Before we start the Loft lab, you need to have a Kubernetes cluster up and running. If you already have a cluster available, that can be used. If not, you can get [Minikube](https://minikube.sigs.k8s.io/docs/start/). Minikbe starts up a single node cluster in your local machine, which is fine since the whole idea of Loft is to use a single cluster that then builds multiple virtual clusters on top of it. If you were to have additional nodes, Loft would still be able to create clusters that shared resources between the nodes. To start, install the Loft CLI:

```
curl -s -L "https://github.com/loft-sh/loft/releases/latest" | sed -nE 's!.*"([^"]*loft-linux-amd64)".*!https://github.com\1!p' | xargs -n 1 curl -L -o loft && chmod +x loft;
sudo mv loft /usr/local/bin;
```

If you are on Windows:

```
md -Force "$Env:APPDATA\loft"; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Tls,Tls11,Tls12';
Invoke-WebRequest -UseBasicParsing ((Invoke-WebRequest -URI "https://github.com/loft-sh/loft/releases/latest" -UseBasicParsing).Content -replace "(?ms).*`"([^`"]*loft-windows-amd64.exe)`".*","https://github.com/`$1") -o $Env:APPDATA\loft\loft.exe;
$env:Path += ";" + $Env:APPDATA + "\loft";
[Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::User);
```

Then test if Loft has properly been installed:

```
loft --version
```

Make sure you are using the correct Kubeconfig file, and then deploy loft to your k8s cluster using your newly installed Loft CLI:

```
loft start
```

Once the above command finishes running, you should see the login details printed out. The username, password, access URL, and command to log in via CLI can be seen here. For now, head over to the localhost URL provided in the output using your browser, and use the login details to log into Loft. Once you're inside, you will see several tabs to the left which show the various sections of the UI. The cluster section shows the clusters you have connected to Loft. If you are running a single node cluster with Minikube, then only that cluster will show since it is already connected to Loft. From this point, you can use the "Connect cluster" button to connect any other clusters you have.

Connecting a cluster is a simple 4-step process, although you only actually have to provide the kubeconfig file of the cluster that you are connecting to. Loft uses [Kiosk](https://github.com/loft-sh/kiosk) which handles everything from that point. You can go back to your clusters page and see that the new remote cluster has been added. Loft also installs Kiosk on the remote cluster so that it gets managed as well. You also have a list of Helm charts that you can 1-click install on your remote clusters, such as dashboards or certificate managers.

Now that the clusters are created, it's time to add users. The users' section of the page should give you a form that you can use to add users, as well as bind cluster roles to the user so that they can have restricted/unrestricted access to the cluster. Once the user has been created, you get a link that you can provide to the user, so that they can start accessing the cluster. You can now log out of Loft and then use the URL you were just provided to log back in as that user. You would no longer have access to the admin parts of Loft since this is a non-admin user, but you should be able to see and use all the clusters + remote clusters. 