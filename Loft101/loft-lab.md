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