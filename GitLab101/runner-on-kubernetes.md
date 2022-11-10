# GitLab runner on Kubernetes

In the same way, we set up the GitLab agent on your cluster, we will be using a Helm chart to set up the GitLab runner as well. If you are running GitLab on a different cluster than the one you intend to run your runner on, then you need to ensure that the two can talk to each other.  Note that the below steps assume that you are running Helm 3, and not Helm 2.

We will start by adding the GitLab repo to Helm:

```
helm repo add gitlab https://charts.gitlab.io
```

Now you can install the Helm chart by specifying the namespace. As with other Helm charts, you can set a `values.yaml` file to set your own custom config values. You have to modify this file with some necessary details so that the runner is configured to work with your repo. To start, make a copy of the default file which can be found [here](https://gitlab.com/gitlab-org/charts/gitlab-runner/blob/main/values.yaml). There are 2 values that need to be mandatorily set. The first one is `gitlabUrl`. Set the full URL to your GitLab instance here. The second is `runnerRegistrationToken` which will be used to authenticate the pipeline with your repo. The [official documentation](https://docs.gitlab.com/ee/ci/runners/) should help you get this value. If you aren't planning to do any additional configurations, you can go ahead install the runner now:

```
helm install --namespace <NAMESPACE> gitlab-runner -f <CONFIG_VALUES_FILE> gitlab/gitlab-runner
```

You can also use other arguments usable by Helm, such as `--version` to specify which version of the runner you would like to install. To get a list of versions available, use:

```
helm search repo -l gitlab/gitlab-runner
```

If you want to do additional configuration, you can change the config file you pass into the install command. The defaul [value.yaml](https://gitlab.com/gitlab-org/charts/gitlab-runner/blob/main/values.yaml) should give you a good idea of what you can configure. There is one major difference between how you would normally write a values.yaml for a Helm chart and how you would do it for the GitLab Helm chart: the GitLab Helm chart requires [TOML](https://toml.io/en/). While the file itself is a yaml file as required by Helm, the values you set inside the file need to follow the TOML format. So if you wanted to set the image the runner uses to a different image, you would do:


```
runners:
  config: |
    [[runners]]
      [runners.kubernetes]
        image = "ubuntu:16.04"
```

