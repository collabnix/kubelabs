# Kubetail ~ Pull Logs from multiple Pods


Bash script that enables you to aggregate (tail/follow) logs from multiple pods into one stream. This is the same as running "kubectl logs -f " but for multiple pods.

## Installation

## MacOS

You can also install kubetail using brew:

```
$ brew tap johanhaleby/kubetail && brew install kubetail
```


## Linux

Clone the repository into a new kubetail directory:

```
git clone https://github.com/johanhaleby/kubetail.git kubetail
```

Edit your ~/.zshrc and add kubetail – same as clone directory – to the list of plugins to enable:

```
plugins=( ... kubetail )
```

Then, restart your terminal application to refresh context and use the plugin. Alternatively, you can source your current shell configuration:

```
source ~/.zshrc
```


## Usage

First find the names of all your pods:

```
$ kubectl get pods
This will return a list looking something like this:

NAME                   READY     STATUS    RESTARTS   AGE
app1-v1-aba8y          1/1       Running   0          1d
app1-v1-gc4st          1/1       Running   0          1d
app1-v1-m8acl  	       1/1       Running   0          6d
app1-v1-s20d0  	       1/1       Running   0          1d
app2-v31-9pbpn         1/1       Running   0          1d
app2-v31-q74wg         1/1       Running   0          1d
my-demo-v5-0fa8o       1/1       Running   0          3h
my-demo-v5-yhren       1/1       Running   0          2h
```

## To tail the logs of the two "app2" pods in one go simply do:

```
$ kubetail app2
```

## To tail only a specific container from multiple pods specify the container like this:

```
$ kubetail app2 -c container1
```

You can repeat -c to tail multiple specific containers:

```
$ kubetail app2 -c container1 -c container2
```

## To tail multiple applications at the same time seperate them by comma:

```
$ kubetail app1,app2
```

## For advanced matching you can use regular expressions:

```
$ kubetail "^app1|.*my-demo.*" --regex
```

To tail logs within a specific namespace, make sure to append the namespace flag after you have provided values for containers and applications:

```
$ kubetail app2 -c container1 -n namespace1
```
Supply -h for help and additional options:
