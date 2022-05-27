# Helm Charts Deep dive

You already know what a Helm chart is. Now, we are going to see the structure of a Helm chart.

First, a folder must be created to house all the files pertaining to the Helm chart. This folder should be named the same as the chart itself. Drawing inspiration from the official Helm docs, let's imagine we are creating a Helm chart for Wordpress. The general file structure would look like this: 

```
📦Wordpress
 ┣ 📂charts
 ┣ 📂templates
 ┣ 📜Chart.yaml
 ┗ 📜values.yaml
```

First, let's consider the [Chart.yaml](./Wordpress/Chart.yaml). This is where chart information is defined. The ```Chart.yaml``` provided here is taken from the Helm docs and describes the file in great detail. 

Next, let us consider the templates folder. Inside this folder, you may define as many Helm templates as you wish. In this case, I have added a template called [configmap.yaml](./Wordpress/templates/configmap.yaml). As you can see, the template uses a placeholder notation ```{{}}``` in order specify that these values can be dynamically changed later on, and this is where the ```values.yaml``` comes in.

The [values.yaml](./Wordpress/values.yaml) is, simply put, the place where the values passed into the Helm template are stored. The values stored within this file can then be accessed by templates using ```.Values.<value>```. You might recognize the Yaml format since it closely resembles a Yaml used to define an ordinary Kubernetes resource.

Finally, we have the the ```charts``` folder which holds the chart dependencies. If this chart defined within Chart.yaml depends on any other charts, that information would be stored here.

## Customizing charts

If you were going to create a brand new chart, you would obviously have to customize it to suit your needs after running ```helm create```. However, even if you are using a preexisting chart, you would still want to edit the chart to your specific use-case. Most of the time, pre-made charts are easily configuable. Going back to our Wordpress example, you can see what values are configurable by running:

```
helm show values bitnami/wordpress
```

The output will show that you can configure things such as the image registry, image pull secret, etc... You can then override these values using a Yaml file. A comprehensive list of methods and limitations of overriding is provided in the [official Helm docs](https://helm.sh/docs/intro/using_helm/#the-format-and-limitations-of---set).

## Hands-on lab

Firstly, you must have an active Kubernetes cluster. The easiest way to get this up and running is using [Minikube](https://minikube.sigs.k8s.io/docs/start/).

If you have a Kubernetes cluster up and running, then it's time to install Helm. The installation is fairly straightforward, and the full installation steps can be found [here](https://helm.sh/docs/intro/install/). Run the Helm create command to get started:

```
helm create hands-on-helm
```

You will notice that the above directory structure has now been created and that these are not empty files, but have detailed descriptions and templates within them. Open up the values.yaml present and you will notice that this is a basic resource to start a simple Nginx server.
The Chart.yaml contains some basic metadata information about the chart. Meanwhile, you can see that the charts folder is empty. This is because this chart has no dependencies as of yet.

The templates folder holds sample templates. Currently, there are templates for:

- Deployments
- Services
- Ingresses

These templates can act as a reference for you to start with so that you don't have to begin from scratch.

### Template functions

Speaking about templates, now is a good time to mention that Helm uses an extended version of [Go templates](https://godoc.org/text/template). One of the biggest additions to the Go templates is the ```include``` command. This simply allows you to include a template within a template whose output can be piped to an operator. Like so:

```yaml
{{ include "included_template" $value | indent 2 }}
```

The next notable addition is the ```required``` keyword. Declaring an entry as required would mean that an empty entry would result in an error, resulting in the template refusing to render.

```yaml
{{ required "A valid foo is required!" .Values.foo }}
```

The **tpl** function comes next. This function allows strings to be evaluated as a template within a template. The syntax for this is:

```yaml
{{ tpl .Values.template . }}
```

### Image pull secrets

Image pull secrets are not only used by Helm but also by Kubernetes in general. However, Helm allows the secret to be written into template files, similar to how the ```values.yaml``` works. For example, imagine the credentials are stored in a yaml like this:

```yaml
imageCredentials:
  registry: quay.io
  username: someone
  password: sillyness
  email: someone@host.com
```

A helper template can then be defined to use this YAML:

```yaml
{{- define "imagePullSecret" }}
{{- with .Values.imageCredentials }}
{{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"email\":\"%s\",\"auth\":\"%s\"}}}" .registry .username .password .email (printf "%s:%s" .username .password | b64enc) | b64enc }}
{{- end }}
{{- end }}
```

This template can then be used within all helm charts:

```yaml
.dockerconfigjson: {{ template "imagePullSecret" . }}
```

This covers the basics of Helm charts, should you need to create one. However, only narrowly covers the full breadth of what Helm has to offer. For more tips and tricks, visit Helm [official docs](https://helm.sh/docs/howto/charts_tips_and_tricks/). Now, let's move on to Chart hooks.

[Next: Chart Hooks](chart-hooks.md)