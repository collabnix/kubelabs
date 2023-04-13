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

will list all the charts applying across all namespaces.