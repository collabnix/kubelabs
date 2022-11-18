# GitLab runner on Kubernetes

In the same way, we set up the GitLab agent on your cluster, we will be using a Helm chart to set up the GitLab runner as well. If you are running GitLab on a different cluster than the one you intend to run your runner on, then you need to ensure that the two can talk to each other.  Note that the below steps assume that you are running Helm 3, and not Helm 2.

## Installing the chart

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

## Chart configuration

If you want to do additional configuration, you can change the config file you pass into the install command. The defaul [value.yaml](https://gitlab.com/gitlab-org/charts/gitlab-runner/blob/main/values.yaml) should give you a good idea of what you can configure. There is one major difference between how you would normally write a values.yaml for a Helm chart and how you would do it for the GitLab Helm chart: the GitLab Helm chart requires [TOML](https://toml.io/en/). While the file itself is a yaml file as required by Helm, the values you set inside the file need to follow the TOML format. So if you wanted to set the image the runner uses to a different image, you would do:


```
runners:
  config: |
    [[runners]]
      [runners.kubernetes]
        image = "ubuntu:16.04"
```

Note that you use `=` to set the image, and not `:` as you normally would in Yaml. If you also want to use a cache with your configuration template, GitLab supports that. The supported platforms are S3, GCP and Azure. You will have to set the details and secrets so that the runner can access these platforms. Instructions on how to do that can be found in the [documentation](https://docs.gitlab.com/runner/install/kubernetes.html#using-cache-with-configuration-template).

### RBAC

If you are working with an enterprise-level cluster, then it would most likely have [RBAC](../RBAC101/README.md). If so, your runner will need a service account to access the cluster. Fortunately, there is no need for complete configuration here as you can get the Helm chart to automatically create the service account for you by adding these values to the chart config yaml:

```
rbac:
  create: true
```

If you already have a service account created, you can alternatively specify it:

```
rbac:
  create: false
  serviceAccountName: your-service-account
```

### Parallel jobs

As with all CI/CD platforms, GitLab runners provide the option for you to run jobs concurrently. By default, the runner will allow 10 jobs to run at once, but you can override this value by specifying it in the configuration file:

```
concurrent: <number of parallel jobs>
```

You can find more info about this in the [advanced section of the docs](https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-global-section).

## Running Docker in Docker with Kubernetes

Before we start talking about running Docker in Docker with Kubernetes, let's start by discussing what Docker in Docker is.

If you were using a managed GitLab instance, meaning that you would allow GitLab to handle all the details of hosting your runners, your entire pipeline will run on a Docker container instance. When running pipelines, it is normal to create, build, and deploy Docker images. In this case, you will be spinning up a Docker container (from your pipeline) on a Docker container (which runs your pipeline). GitLab supports this configuration (or more specifically, Docker supports this configuration). This image can be found on [Docker Hub](https://hub.docker.com/_/docker) and is specifically made to allow Docker to run within Docker.

If you run multiple Docker containers within Docker, you also need to be able to communicate between the containers. For this, you also need to introduce a service tag with a version that supports Docker in Docker. You also need to ensure that all containers share the same certificate for communication to work, which can be set by placing an environment variable which will tell Docker where it should create the shared certificate.

So your configuration file needs to look something like this:

```yaml
build_image:
  image: docker:<tag-version>
  services:
    - docker:<tag-version>-dind
  variables:
    DOCKER_TLS_CERTDIR: "/certs"
```

So how does this translate to your Kubernetes cluster? Since you have a runner that works on your Kubernetes cluster, you will be creating a Docker in Kubernetes implementation. This isn't too different from a Docker in Docker implementation and uses the same pipeline script as above, although you will have to edit the config values file and override the Helm chart with the necessary TOML. While with a Docker in Docker implementation with a managed runner, you could just add the above code to your pipeline script and be done with it, there is an extra step you need to take to enable this on your self-managed Kubernetes runner.

You will have to add a `runners` tag, where you can specify the image and volume mount that the Docker cert will be located in. This will be added to the yaml that you pass into the `Helm install` command:

```
runners:
  config: |
    [[runners]]
      [runners.kubernetes]
        image = "ubuntu:20.04"
        privileged = true
      [[runners.kubernetes.volumes.empty_dir]]
        name = "docker-certs"
        mount_path = "/certs/client"
        medium = "Memory"
```

The `privileged = true` tag is necessary since Docker needs this mode to start containers. As you might expect, this introduces some security issues that are important to discuss at this point. Your host machine that runs the pipeline will have a `docker.sock` (`/var/run/docker.sock`) that needs to be exposed to the Docker container on which your Docker daemon will run. This means your Docker daemon will have access to the kernel of the host system and will use as many resources as the node can provide, ignoring any limits you set for the pod. A way around this is to have a dedicated node for build containers and using either `node-selector` or [taints and tolerations](../Scheduler101/Nodes_taints_and_tolerations.md), so that the rest of the resources are not affected by the build containers using up all their resources. Even so, the unrestricted access the Docker daemon gets makes this option less favorable in production. 

A much better approach is to instead use [Kaniko](https://github.com/GoogleContainerTools/kaniko). Kaniko is an open-source container tool that is specially designed to run Docker containers within other Docker containers or Kubernetes pods without using the Docker daemon. The absence of a Docker daemon means that privileged access is not required. So if you're planning on using Docker in Kubernetes, consider also using Kaniko.

If you're using GitLab Runner 14.2 or above, you also get the option to restrict your Docker images based on where they come from. If you work in an organization, then it is likely that they have its own container registry with images that can be trusted. As such, you can configure the TOML to only use images and services from that registry:

```
[[runners]]
  (...)
  executor = "kubernetes"
  [runners.kubernetes]
    (...)
    allowed_images = ["my.registry.tld:5000/*:*"]
    allowed_services = ["my.registry.tld:5000/*:*"]
```

The above configuration uses wildcards, and you can also set the exact list of images and services allowed so that GitLab can't use anything else. This would be useful if a security team within your organization first curates a version of an image before allowing it into the container registry, meaning that you can specify that GitLab should use only that version of the image that has been already verified.

Once the above command is added and the runner is deployed, you can use the same code you used with Docker to start running Docker in Kubernetes containers.

## Kubernetes secrets and certificates

An important concept behind keeping your credentials encrypted while running a GitLab pipeline is managing Kubernetes secrets. Take a look at the [Kubernetes secrets](../secerts_configmaps101/secrets-configmaps.md) section to get a better idea about how you can create Kubernetes secrets. Once you have an image pull secret, you can specify it and send it to the runner by adding it to the yaml:

```
imagePullSecrets: [your-image-pull-secret]
```

If you want to create a certificate, you need to specify that when installing the Helm chart itself by adding the required values:

```
helm install gitlab gitlab/gitlab \
  --set certmanager.install=false \
  --set global.ingress.configureCertmanager=false \
  --set gitlab-runner.install=false
```

This will create a self-signed certificate and you can add this to the yaml:

```
certsSecretName: RELEASE-wildcard-tls-chain
```

After that, create a new secret with the certificate specified in the file:

```
kubectl create secret generic <SECRET_NAME> \
  --namespace <NAMESPACE> \
  --from-file=<CERTIFICATE_FILENAME>
```

Then add the value you added as `<SECRET_NAME>` and place it in the values.yaml:

```
certsSecretName: <SECRET NAME>
```

### Tokens in secrets

Before GitLab version 15.6, it was customary to store your runner and registration tokens in the values.yaml and have it sent to the Helm chart. However, this was rather unsafe as your token would be stored in plain text in a yaml file that would be hosted openly on a repository. Therefore, after version 15.6, you are no longer allowed to store the token within the yaml, and are instead encouraged to place the token within a secret. To help with this, a new variable has been introduced: `runners.secret`, where you will place your secret that contains the token. For example, the secret can be created like this:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: GitLab-runner-secret
type: Opaque
data:
  runner-registration-token: <base64 encoded registration token>
  runner-token: ""
```

Then you can reference this secret within the values.yaml:

```yaml
runners:
  secret: GitLab-runner-secret
```

## Running GitLab images with non-root users

The default GitLab image requires root permissions, and cannot be run without them. However, you could run a different version of the GitLab image [GitLab Runner UBI](https://gitlab.com/gitlab-org/ci-cd/gitlab-runner-ubi-images/container_registry/1766421?_gl=1*awfj3t*_ga*MTA1NjAwMDYyMC4xNjY4MzE2ODc5*_ga_ENFH3X7M5Y*MTY2ODU4Nzk0Mi43LjAuMTY2ODU4Nzk0Mi4wLjAuMA..).

To get this image to work, the image must be set in the yaml:

```
image: registry.gitlab.com/gitlab-org/ci-cd/gitlab-runner-ubi-images/gitlab-runner-ocp:v13.11.0
```

Since you will not be running the image as a root user, you need to set which user you will be running it as:

```
securityContext:
    runAsNonRoot: true
    runAsUser: 999
```

## Removing a runner

As the last step, we will consider how we can safely remove a GitLab runner from a Kubernetes cluster.

The first step is to ensure that there are no running jobs, and then pause the runner. Not doing so might mean that the resources in the cluster are locked and will not allow you to delete the chart, resulting in error messages such as:

```
ERROR: Error cleaning up pod: Unauthorized
ERROR: Error cleaning up secrets: Unauthorized
ERROR: Job failed (system failure): Unauthorized
```

Since we installed everything at once using Helm, we can use the same to uninstall everything at once instead of removing each resource individually. For that, use:

```
helm delete --namespace <NAMESPACE> <RELEASE-NAME>
```

This is the same command as that used to install the chart (`install` replaced with `delete`), except you don't have to provide an overriding `values` file with it.

And that concludes the end-to-end guide on operating a GitLab runner on Kubernetes.