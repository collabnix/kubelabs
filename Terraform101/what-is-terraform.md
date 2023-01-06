# Terraform

Imagine you had to introduce a DevOps process to a project you were working on. You would likely provision a VM on which you would set up the rest of your DevOps infrastructure. If you were working in a small organization, you would likely use a cloud service provider to save costs, and if you were working in a large organization, you would have the choice between using a cloud provider or simply using VMs that are on-premises. Whatever the case may be, you would be able to reach your goal and finish setting up the infrastructure.

Six months later, you release your application and you need to get your existing infrastructure working for the next release. However, you still need to provide support on your old release, meaning that you would want to provision another VM and get the infrastructure ready for it. This same process will have to be repeated every time you release your application while supporting previous releases, meaning that you would be wasting time repeating the same set of steps manually.

This is where infrastructure as code would come into play. Go back to the very first time you created your infrastructure. Now, instead of creating it manually, imagine that you wrote declarative code that specified which resources should be created, where, and how it should happen. Then the next time you wanted to get all that infrastructure up and running, you would only have to rerun the declarative code and have all infrastructure set up. That is essentially what Terraform is.

Terraform allows you to specify declarative code in files that can be applied to create all your necessary resources in one go. You simply specify which state you would like your infrastructure to be in, and Terraform creates, deletes, or updates the infrastructure to match that state. This largely resembles how Kubernetes works, where you specify what your cluster should be like, and Kubernetes handles the rest.

While you can use a configuration file to automate resource creation on your on-prem VMs, the largest use case for Terraform is when it gets used to set up infrastructure on the cloud. In this case, we will be using GKE with terraform to automate setting up Kubernetes clusters on Google cloud.

## Terraform providers

Now comes another question: how does Terraform connect to cloud services to set up infrastructure on them? For this, they use something called Terraform providers. Terraform has over a hundred providers that allow the automated creation of over a thousand resource types. For example, the [Google provider](https://registry.terraform.io/providers/hashicorp/google/4.47.0) gives management capabilities to many of the cloud services provided by Google. To use it.

## How does it work?

First, the Terraform core takes the existing state of your infrastructure, as well as any configurations from the input file. An input file would look something like this:

```
provider "google" {}

resource google_compute_network "mynetwork" {
name = [google_compute_network]
    # RESOURCE properties go here
}
```

In this case, we are setting the provider to `google`, meaning that this Terraform file can now automate infrastructure across Google cloud services. After that, we declare a network resource that needs to be created when the file is run.

Then it considers what the desired state should look like and creates an execution plan. Finally, it executes the plan. For the plan to be executed, it would have to use providers that allow access to various resources.   