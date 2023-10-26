## Lab

For starters, we will be using the files we created in the [Terraform section](../Terraform101/terraform-eks-lab.md) to set up our VPC, subnet, and ultimately, our cluster. So go ahead and take those files and use them to create the cluster. Once the cluster is up, take the files from the [ArgoCD section](../GitOps101/argocd-eks.md), and deploy them. The first time around, you will have to either deploy the files manually, or use CLI commands to add the repos, create the project, add the cluster created by Terraform, and finally set up the application. As you may have noticed, this is rather time-consuming and not ideal in a DR situation. But the good news is that once your ArgoCD application is up, there is no reason to spend any time setting up the application all over again. So let's take a look at the script that will handle this for us.

The script will be written in Python and take in a cluster endpoint as an argument. Basically, the only difference between the cluster that is running now vs the DR cluster is the cluster endpoint, so changing this value alone should re-deploy the modules into the new cluster. The output of this script is going to have this structure:

- A command to add the new cluster to ArgoCD (`argocd cluster add dr-cluster`)
- A command to create any namespaces that will be needed for further deployments (kubectl create ns <namespace>)
- A command that sets the correct destination namespace (argocd app set <app-name> --dest-server <new_endpoint>)
- A command that force syncs the application so that it will automatically deploy to the new destination (argocd app sync <app-name>)

The first step is to define the arguments:

```python
parser = argparse.ArgumentParser(description="Destination cluster endpoint")
parser.add_argument(
    "--dest-server",
    required=True,
    help="Server URL for destination cluster",
)
```

Now, we need to use the subprocess library to run ArgoCD CLI commands, similar to if we were running them on a local terminal. The first of these commands will be the list command which is used to list all the applications running on the (now-disabled) cluster:

```
argocd app list --project <project-name> -o name
```

We also need to capture the output, so we should assign the result to a variable and set the necessary arguments:

```
result = subprocess.run(
    ["argocd", "app", "list", "--project", "<project-name>", "-o", "name"],
    text=True,
    capture_output=True,
    check=True,
)
```

Now that we have the list of applications, it is time to start a loop that will go through this list and switch all the modules from one cluster to another. We will keep all the commands pointed to one file using the `with` command:

```
with open("change-applications.sh", "w") as file:
```

To start, we need to add the cluster to argocd:

```
file.write("argocd cluster add <cluster-name>\n")
```

Make sure that you have added your new cluster to your local kubeconfig. Otherwise, the above `cluster add` command will fail. Since we already have the list of applications, start a `for` loop:

```
for application_name in application_names:
```

Inside the loop, start running the `set` commands so that each application has the set command running in it:

```
argocd_command = f'argocd app set {application_name} --dest-namespace <namespace> --dest-server {args.dest_server}\n'
```

Followed by the sync command to force the application to update and switch to the new cluster:

```
argocd_sync = f'argocd app sync {application_name}\n'
```

Next, we write both those commands to the file we are creating:

```
file.write(argocd_command)
file.write(argocd_sync)
```

With that, the loop is complete:

```python
with open("sync-modules.sh", "w") as file:
    file.write("argocd cluster add <cluster-name>\n")
    for application_name in application_names:
        argocd_command = f'argocd app set {application_name} --dest-namespace <namespace> --dest-server {args.dest_server}\n'
        argocd_sync = f'argocd app sync {application_name}\n'
        file.write(argocd_command)
        file.write(argocd_sync)
```