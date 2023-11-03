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
with open("change-applications.sh", "w") as file:
    file.write("argocd cluster add <cluster-name>\n")
    for application_name in application_names:
        argocd_command = f'argocd app set {application_name} --dest-namespace <namespace> --dest-server {args.dest_server}\n'
        argocd_sync = f'argocd app sync {application_name}\n'
        file.write(argocd_command)
        file.write(argocd_sync)
```

If you have additional commands you would like to get run before the deployments start happening (such as the creation of a new namespace), it can be done at the start of the `with` command. You can also modify the `argocd` command to have any of the flags and options [used by the set command](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_app_set/). So if you wanted to create a namespace called "application" and have the deployments be done into that namespace, you would add the line:

```
file.write("kubectl create ns application\n")
```

Under the `with` command, then modify the `argocd app set` command by adding `--dest-namespace application`.

Since you used the `with` command to open the file, you don't have to close it, which means this is all that is required.

## Usage

Now that we have the entire DR plan in place, let's view what would happen during a DR situation, and what we would need to do to get everything back up and running. To start, we will be getting the cluster up and running with the below commands:

`terraform init`
`terraform apply`

This will set up both the cluster and any resources required to start the cluster. Starting the cluster will take a certain amount of time depending on how many nodes you have assigned to your node group. Once it is up, take the cluster endpoint head over to the location of your Python script, and run it:

```
python create_cluster.py --dest-server <server endpoint>
```

This will create a file called "change-applications.sh". Look it over to ensure that everything you need is in there. It should have any custom commands you placed as well as the set command that changes the location of the cluster, along with force sync commands. If everything looks as it should be, go ahead and run the file:

```
sh change-applications.sh
```

If you have already logged into ArgoCD CLI via the terminal, then the commands should run sequentially and the pods should start scheduling in the new cluster. You can see this happen in real-time with the ArgoCD CLI.

And that's it! You now have a full DR solution that will allow you to get your systems up and running in about 30 minutes. In a regular full-scale application, there would be things such as databases where you want to get the DB up and running with minimal data loss in the new region. When it comes to these matters, it's either better to hand off the management of these critical servers to a database service provider entirely so that they can handle the database DR (since database-related issues can get critical) or to have your own on-prem servers that you have a good handle on. You can then use these servers to host your databases during a DR situation.