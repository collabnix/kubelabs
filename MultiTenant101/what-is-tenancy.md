# Multi-tenant architecture

A multi-tenant architecture is when you segregate your infrastructure based on your clients. A single instance of the software application is served to multiple customers, known as tenants. Each tenant's data and configuration are logically isolated from each other, but they share the same underlying infrastructure and codebase.

This can have many benefits, but whether you should go for an infrastructure like this is dependent on several things. Let's start off by looking at the immediate advantages of this design.

First and foremost is resource isolation. Not only does this improve security and compliance for the organization, but it also enables you to get a better idea of the resource usage and related costs that each client incurs for your company. You can use this information to better improve billing. If a single client starts growing, you can scale out that particular client's infrastructure without having to scale out everything while charging them to match. If you have a large number of small clients (individual customers), you could even provision resources on a per-customer basis. This is not in the scope of this lesson but is covered in the [Kubezoo](../Kubezoo/what-is-kubezoo.md) section.

The next is customization. It is normal for different customers to have different requirements, and a regular architecture would not be able to cater to that. With a multi-tenant system, since each customer's applications are isolated from one another, providing customization on a per-client basis becomes pretty easy.

Of course, all this doesn't mean you need to have extra computing power. Despite having a separate infrastructure per client, you will still use the same resources for all of them. In this section, we will be looking at how we can use a single cluster with one control plan and multiple worker nodes to set up a multi-tenant system that is broken down based on namespaces. But before we do that, let's consider when muti-tenancy might not be the best option.

First off, if your project is specifically designed for a single customer, then there is no point in spending time coming up with a new multi-tenant architecture since you will only have a single tenant. This does not apply if you plan to re-use your application and provide it to a different client. Additionally, if you have a large number of small clients already configured, switching to a multi-tenant architecture might not make a lot of sense considering the large amount of work it will require. In fact, it's likely that your application code isn't designed to handle workloads in a multi-tenant fashion, which means doing a fair bit of additional work to make your code fit the architecture. Finally, if you don't already have a microservice architecture, then you will have to largely scrap the idea of running different groups of clients in different infrastructures since it will get fairly expensive.

## Design

Now that we've got the introduction out of the way, let's take a look at the design we will be following for this application.

### 1. Namespace Isolation:
Each tenant will have its dedicated namespace in Kubernetes. This allows for resource isolation and management at the namespace level.

### 2. RBAC (Role-Based Access Control):
Implement RBAC to control access to resources within each namespace. Define roles and role bindings to restrict what actions users and services can perform within their respective namespaces.

### 3. Network Policies:
Use network policies to control network traffic between namespaces. Define policies to allow communication between services within the same tenant namespace while restricting traffic from other tenants.

### 4. Resource Quotas and Limits:
Set resource quotas and limits for each namespace to prevent one tenant from monopolizing resources and affecting others. This ensures fair resource allocation and prevents noisy neighbors.

### 5. Custom Resource Definitions (CRDs):
This is something that we will not be touching on in this section, but if your tenants require custom resources, CRDs are the way to go. This allows tenants to define their resource types and controllers within their namespaces.

### 6. Monitoring and Logging:
There are a large number of tools that can help with monitoring and logging, and most of them such as Prometheus, Grafana, Elasticsearch, Fluentd, and Kibana (EFK stack) have been covered in other sections. Since we will be separating tenants by namespace, a tool we haven't looked at so far that could be useful here is [Loki](https://grafana.com/docs/loki/latest/) for namespace-level logging.

### 7. Tenant Onboarding and Offboarding Automation:
This step is something that is generally overlooked and is important even if you aren't developing a multi-tenant system. You have to consider how you will handle things when you onboard a new customer. What type of scaling will you use? How much will you scale? If you don't have this, you might end up either over-provisioning or under-provisioning and thereby affect your clients. So you have to develop automation scripts or tools for efficient tenant onboarding and offboarding. This includes provisioning/de-provisioning namespaces, setting up RBAC rules, configuring network policies, and applying resource quotas.

### 8. Tenant Customization:
We spoke earlier about how it was easy to have customized versions of applications per customer when you are running a multi-tenant application. However, you can take this a step further and allow the tenant to customize their namespaces within defined limits. Provide options for configuring ingress/egress rules, setting up persistent storage, deploying custom services, etc. This allows your tenant to control not only the application but also their infrastructure to a certain level.

### 9. High Availability and Disaster Recovery:
A disaster recovery solution is pretty important when you have multiple customers using a single infrastructure. If you had each tenant using a different Kubernetes cluster, for example, one cluster going down is only going to affect that customer. However, if you make all the tenants use the same cluster with namespace separation, the cluster going down could mean all your tenants are affected. So as part of the architecture, you have to always think about redundancy and failover mechanisms at both the cluster and application levels to ensure high availability. You also have to regularly backup tenant data and configuration to facilitate disaster recovery.

### 10. Scalability:
Design the application to be horizontally scalable to accommodate varying tenant loads. Utilize Kubernetes features like Horizontal Pod Autoscaler (HPA) and Cluster Autoscaler to automatically scale resources based on demand.

### Example Workflow:
1. Tenant requests a new environment.
2. Automation scripts provision a new namespace for the tenant.
3. RBAC rules, network policies, and resource quotas are applied.
4. Tenant deploys their application within the designated namespace.
5. Monitoring and logging capture relevant metrics and events.
6. Regular audits ensure compliance and security.
7. Tenant scales resources as needed using Kubernetes APIs.
8. Upon tenant offboarding, automation scripts handle namespace cleanup and resource deallocation.

This design ensures efficient resource utilization, strong isolation between tenants, and streamlined management of a multi-tenant Kubernetes environment.

Certainly! Let's create a simple Kubernetes application using NGINX as the sample application. We'll deploy NGINX within a Kubernetes cluster, ensuring that each tenant gets their isolated namespace.

### Prerequisites:
- Kubernetes cluster (minikube, Docker Desktop with Kubernetes enabled, or any cloud provider)
- kubectl installed and configured to connect to your Kubernetes cluster

### Steps:

#### 1. Create Namespace for Tenants:
```bash
kubectl create namespace tenant1
kubectl create namespace tenant2
```

#### 2. Deploy NGINX in Each Namespace:
```bash
# Deployment for tenant1
kubectl create deployment nginx --image=nginx -n tenant1

# Deployment for tenant2
kubectl create deployment nginx --image=nginx -n tenant2
```

#### 3. Expose NGINX Service:
```bash
# Expose NGINX service for tenant1
kubectl expose deployment nginx --port=80 --target-port=80 -n tenant1

# Expose NGINX service for tenant2
kubectl expose deployment nginx --port=80 --target-port=80 -n tenant2
```

#### 4. Verify Deployments:
```bash
# Check tenant1 deployment
kubectl get deployment,svc,pods -n tenant1

# Check tenant2 deployment
kubectl get deployment,svc,pods -n tenant2
```

#### 5. Access NGINX Services:
```bash
# Get tenant1 service URL
kubectl get svc -n tenant1

# Get tenant2 service URL
kubectl get svc -n tenant2
```

### Explanation:

- **Step 1**: We create separate namespaces for each tenant (`tenant1` and `tenant2`).
- **Step 2**: NGINX is deployed within each tenant's namespace using a Kubernetes Deployment.
- **Step 3**: We expose the NGINX service within each namespace.
- **Step 4**: Verification of deployments, services, and pods within each namespace.
- **Step 5**: Accessing NGINX services via their respective service URLs.

This example demonstrates how to deploy a simple application (NGINX) within a multi-tenant Kubernetes environment, ensuring isolation between tenants using namespaces. Each tenant has its NGINX instance running independently within its namespace.