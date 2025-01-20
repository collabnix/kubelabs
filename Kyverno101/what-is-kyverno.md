# What is Kyverno

Kyverno is a Kubernetes-native policy engine designed to manage and enforce configuration best practices, security policies, and operational compliance for Kubernetes clusters. Unlike other policy engines like Open Policy Agent (OPA), which uses a separate query language (Rego), Kyverno leverages Kubernetes' native YAML syntax to define policies, making it intuitive for Kubernetes users.

Let's first take a look at the configuration part of Kyverno. Imagine a multi-tenant architecture with several applications running on several namespaces of your cluster. So each namespace  (namespace A, B, C) will have a separate copy of application A, B, C, etc...  However, you want to separate the resources for these applications by instructing everything in namespace A to separate on a node with label "A", everything in namespace B to schedule on a node with label "B', etc... One way you can do this is to have several copies of you Deployment manifest and specify the node selector per each namespace. However, this means you will be creating several copies of the same file which is a problem when it comes to maintenance and increases complexity. It would be much simpler if you could have a single manifest file that didn't specify a node selector at all, and the node selector would get automatically set per namespace as you deployed your applications. This is what Kyverno provides.

### Key Features of Kyverno:

#### 1. **Policy Definition with YAML:**
 Kyverno policies are defined as Kubernetes Custom Resources (CRs). This means you can declare policies in regular YAML, similar to how you would declare any other resource.

#### 2. **Policy Types:**
   - **Mutation Policies:** Automatically modify or add specific configurations to resources (e.g., inject default labels, set resource limits). This is what we discussed earlier, where you mutate the configuration so that namespace-specific configurations are applied at deployment time.
   - **Validation Policies:** Ensure resources conform to specific requirements (e.g., require labels, restrict container images).
   - **Generation Policies:** Generate and manage additional resources based on existing ones (e.g., create ConfigMaps or Secrets dynamically).

We will look into each of these policy types at a later point.

#### 3. **Admission Control:**
 Kyverno integrates with Kubernetes admission controllers to enforce policies during resource creation or updates. Based on the defined policies, it can block, allow, or mutate resources.

#### 4. **Policy Violation Reporting:**
 Kyverno creates Kubernetes events or custom status fields to report policy violations. This makes it easier to monitor compliance using existing Kubernetes tools like `kubectl`, dashboards, or monitoring solutions. This is useful if you have to maintain compliance such as ISO or SOC. Once the violation reporting is in place, you can assume your cluster is complicated as long as these reports don't reflect any violations.

#### 5. **Policy as Code:**
 Since Kyverno uses YAML, it enables "Policy as Code," allowing teams to version-control their policies alongside application code, promoting a GitOps approach. This is a much better approach than manually applying policy constraints via `kubectl`, which would result in confusion on which policies were used at a later point. 

#### 5. **Validation Tests:**
   Kyverno supports testing policies using sample Kubernetes resources to ensure correctness before applying them in production.

Now that we have a broad understanding into what Kyverno is, consider the following use cases where Kyverno will come in handy. 

### Common Use Cases for Kyverno:

1. **Enforcing Security Standards:**
   - Restrict the use of privileged containers.
   - Ensure all images come from trusted registries.
   - Require TLS for all Ingress resources.

2. **Resource Consistency:**
   - Require labels for all resources (e.g., `app`, `team`, `environment`).
   - Set default resource limits if not provided.

3. **Operational Compliance:**
   - Automatically add annotations for observability tools.
   - Inject sidecar containers or environment variables for specific workloads.

4. **Custom Resource Management:**
   - Automatically generate network policies, ConfigMaps, or Secrets when a namespace is created.
   - Clean up resources when associated objects are deleted.

To use Kyverno, a policy needs to be defined and applied. The Kyverno workflow is as follows.

### Kyverno Workflow:

1. **Policy Definition:**
   Write Kyverno policies as Kubernetes Custom Resource Definitions (CRDs).

2. **Policy Application:**
   Apply the policies to the cluster using `kubectl apply`.

3. **Policy Enforcement:**
   Kyverno operates in three modes:
   - **Enforce:** Strictly enforce policies by blocking non-compliant resources.
   - **Audit:** Allow non-compliant resources but report violations.
   - **Generate:** Create or update resources as needed.

4. **Monitoring:**
   Use `kubectl`, Kyverno CLI, or observability tools to monitor policy compliance and violations.


[Next: Policy types](./policy-types.md)

Kyverno empowers Kubernetes users to enforce best practices, security standards, and operational consistency in a seamless and Kubernetes-native manner. Its simplicity and powerful capabilities make it an excellent choice for policy management in Kubernetes environments.