# Helm cheat sheet

While the [Helm docs](https://helm.sh/docs/helm/) has extensive information on every command there is with Helm, there are a few commands that you will use regularly enough that it is important to have them memorized. This will also come in handy if you were ever to face an interview where you get asked questions about various Helm commands. It is unlikely that the interviewers will ask you to write multi-line complex commands since you absolutely will have to look through the documentation before you can get there. Instead, the commands they will expect you to know will be the basics that go on to show that you know and have used Helm in the past.

Before we begin, if you have consulted the [Kubernetes cheat sheet](./Kubernetes%20Cheat%20Sheet.md) before, you will notice that there are a large number of similarities between the flags, keywords, and commands. So let's start off on familiar ground by looking at these.

## Helm flags

```
-A
```

`-A` stands for "all namespaces" (`--all-namespaces`) and is used to look for resources across all namespaces. So, commands such as

```
helm list -A
```

will list all the charts applying across all namespaces. Another flag which shows everything with no filter applied is `-a`, which can be used in the same way.

```
-f
```

This is used to specify a file. A command such as

```
helm install -f myvals.yaml ./mychart
```

will install the chart `mychart` and override the chart values with the values from the file `myvals.yaml`. However, this same flag can be used in a different context to apply a filter. An example of this would be if you were running the `list command`:

```
helm list -f "gitlab"
```

This would list all the charts with the word `gitlab` in their name.

```
-n
```

This is used to specify the namespace, and is short for `--namespace`.


```
-o
```

shorthand for `--output`, which formats the output displayed. So if you wanted the output to be in JSON format, use

```
helm ... -o json
```

The flags that were discussed up to now are ones that match flags on Kubernetes. We will now move to flags that are specific to Helm.

```
-g
```

When you are installing a Helm chart, the chart would be installed as a release. This means that you can install the same chart multiple times with different names on the same host. To facilitate this, you need to assign a name to the helm chart. However, you can use the above flag to automatically generate a name for you.

```
helm install examples/hello-world -g
```

will install a chart with a generated name that includes the chart name as a prefix. Also, note that `-g` is the shortened form of `--generate-name`.