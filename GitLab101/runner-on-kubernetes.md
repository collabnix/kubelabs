# GitLab runner on Kubernetes

In the same way, we set up the GitLab agent on your cluster, we will be using a Helm chart to set up the GitLab runner as well. If you are running GitLab on a different cluster than the one you intend to run your runner on, then you need to ensure that the two can talk to each other.  Note that the below steps assume that you are running Helm 3, and not Helm 2.

We will start by adding the GitLab repo to Helm:

```
helm repo add gitlab https://charts.gitlab.io
```

Now you can install the Helm chart by specifying the namespace. As with other Helm charts, you can set a `values.yaml` file to set your own custom config values. If this option is not provided the default values will be used, which can be seen [here](https://gitlab.com/gitlab-org/charts/gitlab-runner/blob/main/values.yaml).

```
helm install --namespace <NAMESPACE> gitlab-runner -f <CONFIG_VALUES_FILE> gitlab/gitlab-runner
```

You can also use other arguments usable by Helm, such as `--version` to specify which version of the runner you would like to install.