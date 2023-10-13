# Disaster Recovery

When you create a production-grade application, you assure your clients a certain amount of uptime. However, during a disaster situation, this uptime stops being guaranteed. For example, if you host your applications on the us-east-1 region of AWS, and that region goes down, you need to be able to get your application up and running on a different region, such as us-west-2, so that your customers get as little downtime as possible.  In this section, we will explore the different ways we can set up a full disaster recovery solution for a Kubernetes cluster using tools we are already used to such as Terraform and ArgoCD. If you need a quick refresher on these areas, please consult the [Terraform](../Terraform101/what-is-terraform.md) and [ArgoCD](../GitOps101/argocd-eks.md) sections.

## Overview

We will start by defining an overview of how our DR system will kick into place.