# Application release frameworks

Application release frameworks, or application orchestraction tools have flooded the market in the recent years, growing popluar by the day. You may know these tools more commonly as CI/CD tools such as Azure DevOps, Jenkins, etc... While the aforementioned pipelines are more general purpose and can be used to orchestrate releases in all sorts of environments, more specific tools exist for Kubernetes. This includes tools such as [ArgoCD](../GitOps101/argocd.md), which waits until changes to the Kubernetes resource yaml are merged into master, at which point ArgoCD intelligently updates the cluster with the new resource yaml.

Now, we would like to bring a slightly different tool that caters to a different need: [Shipa](https://learn.shipa.io).

## What does it do?

First of all, this is not a replacement for ArgoCD. In fact, many users regularly run both ArgoCD and Shipa together. A good example of this can be found in the [introductory page of Shipa](https://learn.shipa.io/docs).