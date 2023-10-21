## Lab

For starters, we will be using the files we created in the [Terraform section](../Terraform101/terraform-eks-lab.md) to set up our VPC, subnet, and ultimately, our cluster. So go ahead and take those files and use them to create the cluster. Once the cluster is up, take the files from the [ArgoCD section](../GitOps101/argocd-eks.md), and deploy them. The first time around, you will have to either deploy the files manually, or use CLI commands to add the repos, create the project, add the cluster created by Terraform, and finally set up the application. As you may have noticed, this is rather time-consuming and not ideal in a DR situation. But the good news is that once your ArgoCD application is up, there is no reason to spend any time setting up the application all over again. So let's take a look at the script that will handle this for us.

The script will be written in Python and take in a cluster endpoint as an argument. Basically, the only difference between the cluster that is running now vs the DR cluster is the cluster endpoint, so changing this value alone should re-deploy the modules into the new cluster. The output of this script is going to have this structure:

- A command to add the new cluster to ArgoCD (`argocd cluster add dr-cluster`)
- A command to create any namespaces that will be needed for further deployments (kubectl create ns <namespace>)
- A command that sets the correct destination namespace (argocd app set <app> --dest-server <new_endpoint>)
- A command that force syncs the application so that it will automatically deploy to the new destination.

The first step is to define the arguments:

```python
parser = argparse.ArgumentParser(description="Destination cluster endpoint")
parser.add_argument(
    "--dest-server",
    required=True,
    help="Server URL for destination cluster",
)
```