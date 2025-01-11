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

---

### Mutation policy

Let's start by looking at mutation policies. In this case, we will consider a solution to the problem we discussed at the beginning of this article. Let's consider a problem where we want all the pods in a specific namespace to schedule on nodes that have the label "dedicated". We also don't want any pods from other namespaces scheduling on these nodes so we should taint the nodes. This will ensure any pods without a toleration for this taint will not be scheduled on these nodes. Next, we need to mutate the pod configurations of the pods in the namespace so that they tolerate this taint. To perform these actions, this is the policy configuration that should be used:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: enforce-scheduling
spec:
  rules:
  - name: add-toleration-and-node-selector
    match:
      resources:
        kinds:
        - Pod
        namespaces:
        - dedicated
    mutate:
      patchesJson6902: |-
        - op: add
          path: /spec/tolerations/-
          value:
            key: "dedicated"
            operator: "Equal"
            value: "true"
            effect: "NoSchedule"
        - op: add
          path: /spec/nodeSelector
          value:
            dedicated: "true"
```

Here we define a `ClusterPolicy` (custom CRD) called "enforce-scheduling" and specify 1 rule. The rule matches all the pods in the namespace "dedicated" and its job is to mutate the pods it applies to. Inside the rules, 2 separate patches are happening. The first adds toleration to each pod to ensure it can be scheduled on tainted nodes. The second adds a node selector that explicitly forces the pod to schedule on select nodes that have the label `dedicated`.

An important note when using these mutate hooks: always define them within a single resource. If you were to create 2 separate mutation hooks in 2 separate resources, there could be concurrency issues. That is, when a pod starts, both resources try to mutate the pods at once which causes one or more mutations to fail. So having the mutations listed one after the other within a single resource is the best option here. Logically speaking, you should also group your rules separately even if they are all mutations. In this case, you have the mutation "add-toleration-and-node-selector" which fits the mutations that happen under it. However, if you have another mutation that removed something, such as toleration, then you shouldn't group it under the same name "add-toleration-and-node-selector". Instead, you can create a new rule with its name above or below the current rule and have the mutation defined there. For example:

```yaml
  rules:
  - name: remove-toleration
    match:
      resources:
        kinds:
        - Pod
        namespaces:
        - dedicated
    mutate:
      ...
  - name: add-toleration-and-node-selector
    ...
```

There is no limit to the number of mutations you can define separately. Now let's look at a vaildation policy.

### Validation policy

**Kyverno validation policies** are rules designed to ensure that Kubernetes resources meet specific criteria before they are created or updated in a cluster. These policies act as a form of admission control, where Kyverno validates incoming resource configurations and either approves or rejects them based on the defined rules. Validation policies help enforce best practices, security standards, and compliance by defining what is allowed in a Kubernetes cluster. If a resource does not comply with the validation policy, it can be denied (in enforce mode) or simply reported (in audit mode).

There are a few key features of validation policies:
- Pattern-Based Validation
- Custom Error Messages
- Selective Targeting

You can also enforce validations meaning that it denies non-compliant resources from being created or updated, or audit validations, which allows non-compliant resources but reports a warning.

Now we will look at an example of a validation policy. For this case, let's assume that all pods in the cluster must have specific labels such as `app` and `environment`. The policy for that will look something like this:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-labels
spec:
  validationFailureAction: enforce  # "audit" can be used for warnings instead of rejection
  rules:
    - name: check-required-labels
      match:
        resources:
          kinds:
            - Pod
      validate:
        message: "Pods must have 'app' and 'environment' labels."
        pattern:
          metadata:
            labels:
              app: "?*"
              environment: "?*"
```

First we have `validationFailureAction: enforce` meaning any pod that does not meet the policy will be denied at the admission controller level. Next there is `match.resources.kinds: Pod` similar to the mutate hook which specifies the policy applies to `Pod` resources.

`validate.message` provides a clear error message when a resource fails validation, and `validate.pattern` defines the required structure of the resource. In this case it says that the labels `app` and `environment` must exist with any value (`?*` is a wildcard for "any value").

Based on these restrictions, this is the definition of a compliant pod:

   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: my-app
     labels:
       app: web
       environment: production
   spec:
     containers:
       - name: nginx
         image: nginx:1.21
   ```

Meanwhile, something like this can be considered "non-compliant" since it is missing the 'app' and 'environment' labels.:

   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: my-app
     labels:
       app: web
   spec:
     containers:
       - name: nginx
         image: nginx:1.21
   ```

You can also use placeholders like `{{request.operation}}` to dynamically validate based on runtime information. We can also specify namespaces (similar to the mutating policies) where the policy applies to any pods in specific namespaces. We can also use an `exclude` block that excludes specific resources from validation.

### Generation policy

As the name suggests, generation policies allow you to generate Kubernetes resources automatically. It also allows you to clone, or synchronize additional Kubernetes resources. These policies allow for the dynamic management of resources by generating dependent resources based on existing ones. This can be particularly useful for enforcing consistency, managing configurations, or reducing manual effort.

### Key Features of Generation Policies:

1. **Automatic Resource Creation:**
   - Generate resources like ConfigMaps, Secrets, or NetworkPolicies when a trigger resource is created.

2. **Dynamic Content:**
   - Use variables and placeholders to dynamically populate the generated resource with data from the source resource or cluster context.

3. **Synchronization:**
   - Keep the generated resource in sync with the source resource by automatically updating it when the source changes.

4. **Selective Targeting:**
   - Apply generation policies to specific resources based on their kind, labels, or namespaces.

---

### Common Use Cases for Generation Policies:

1. Automatically create a default `ConfigMap` or `Secret` when a namespace is created.
2. Generate `NetworkPolicy` objects for security purposes when a namespace is added.
3. Create monitoring or logging configurations dynamically for specific workloads.
4. Clone resources from one namespace to another.

---

### Example Policy: Generating a ConfigMap for New Namespaces

**Scenario:**
Automatically generate a default `ConfigMap` with predefined data whenever a new namespace is created.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: generate-default-configmap
spec:
  rules:
    - name: create-configmap
      match:
        resources:
          kinds:
            - Namespace
      generate:
        kind: ConfigMap
        name: default-config
        namespace: "{{request.object.metadata.name}}"
        synchronize: true
        data:
          config:
            default-key: default-value
```

---

### Explanation of the Example:

1. **`match.resources.kinds`:**
   - Targets `Namespace` resources. The policy is triggered when a namespace is created.

2. **`generate.kind`:**
   - Specifies that the resource to be generated is a `ConfigMap`.

3. **`generate.name` and `generate.namespace`:**
   - Defines the name of the `ConfigMap` as `default-config`.
   - The namespace of the `ConfigMap` is dynamically set to the name of the created namespace using the placeholder `{{request.object.metadata.name}}`.

4. **`synchronize`:**
   - Ensures the generated `ConfigMap` stays in sync with this policy. If the `ConfigMap` is manually modified, Kyverno will revert it to match the policy definition.

5. **`data`:**
   - Defines the key-value pairs (`default-key: default-value`) that will be included in the generated `ConfigMap`.

---

### Behavior:

1. **Trigger:**
   - A new namespace is created:
     ```yaml
     apiVersion: v1
     kind: Namespace
     metadata:
       name: example-namespace
     ```

2. **Generated Resource:**
   - A `ConfigMap` named `default-config` is automatically created in the `example-namespace`:
     ```yaml
     apiVersion: v1
     kind: ConfigMap
     metadata:
       name: default-config
       namespace: example-namespace
     data:
       default-key: default-value
     ```

3. **Sync:**
   - If the `ConfigMap` is deleted or modified, Kyverno will recreate or update it to match the policy definition.

---

### Advanced Use Cases:

1. **Generating Secrets:**
   Create a `Secret` with sensitive data like API keys or tokens when a deployment is created:
   ```yaml
   generate:
     kind: Secret
     name: app-secret
     namespace: "{{request.object.metadata.namespace}}"
     data:
       api-key: "YXNkZmFzZGZhc2Rm" # Base64 encoded value
   ```

2. **Cloning Resources:**
   Clone a `ConfigMap` from a specific namespace:
   ```yaml
   generate:
     kind: ConfigMap
     name: "{{request.object.metadata.name}}-config"
     namespace: "{{request.object.metadata.namespace}}"
     clone:
       name: base-config
       namespace: base-namespace
   ```

3. **Creating Network Policies:**
   Automatically enforce security by generating a `NetworkPolicy` for every namespace:
   ```yaml
   generate:
     kind: NetworkPolicy
     name: allow-dns
     namespace: "{{request.object.metadata.name}}"
     spec:
       podSelector: {}
       policyTypes:
         - Egress
       egress:
         - to:
             - ipBlock:
                 cidr: 8.8.8.8/32
           ports:
             - protocol: UDP
               port: 53
   ```

---

Kyverno generation policies simplify the management of Kubernetes resources by automating their creation and synchronization, ensuring consistency and reducing manual effort.

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

---

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

---

### Benefits of Kyverno:

1. **Kubernetes-Native:**
   - No new language to learn; policies use familiar Kubernetes YAML syntax.
   - Operates as a Kubernetes controller, seamlessly integrating into the ecosystem.

2. **Ease of Use:**
   - Declarative and intuitive for Kubernetes users.
   - Minimal setup compared to external policy engines.

3. **Flexibility:**
   - Supports validation, mutation, and resource generation in one tool.
   - Integrates with GitOps workflows for managing policies as code.

4. **Open Source:**
   - Actively maintained and widely adopted in the Kubernetes community.

---

### Comparison with OPA/Gatekeeper:

| Feature                  | Kyverno                              | OPA/Gatekeeper                    |
|--------------------------|--------------------------------------|-----------------------------------|
| **Policy Language**      | Kubernetes YAML                     | Rego (Custom Language)           |
| **Ease of Use**          | High (Kubernetes-native)            | Moderate (Learning curve for Rego) |
| **Policy Types**         | Validation, Mutation, Generation    | Validation (Mutation in beta)    |
| **Dynamic Context**      | Native support for Kubernetes data  | Requires custom integration      |
| **Performance**          | Efficient, lightweight              | Slightly more complex setup      |

---

### Example Policies:

#### Enforce Labels:
```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-labels
spec:
  validationFailureAction: enforce
  rules:
    - name: check-app-label
      match:
        resources:
          kinds:
            - Pod
      validate:
        message: "Pods must have the 'app' label."
        pattern:
          metadata:
            labels:
              app: "?*"
```

#### Add Default Resource Limits:
```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: default-resource-limits
spec:
  rules:
    - name: set-default-limits
      match:
        resources:
          kinds:
            - Pod
      mutate:
        patchStrategicMerge:
          spec:
            containers:
              - name: "*"
                resources:
                  limits:
                    memory: "512Mi"
                    cpu: "1"
```

#### Generate ConfigMap:
```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: generate-configmap
spec:
  rules:
    - name: create-configmap
      match:
        resources:
          kinds:
            - Namespace
      generate:
        kind: ConfigMap
        name: default-config
        namespace: "{{request.object.metadata.name}}"
        data:
          config: default
```

---

### Installing Kyverno:

1. Add Kyverno to your Kubernetes cluster:
   ```bash
   kubectl apply -f https://raw.githubusercontent.com/kyverno/kyverno/main/definitions/release/install.yaml
   ```

2. Verify installation:
   ```bash
   kubectl get pods -n kyverno
   ```

3. Apply your first policy:
   ```bash
   kubectl apply -f <policy-file>.yaml
   ```

---

Kyverno empowers Kubernetes users to enforce best practices, security standards, and operational consistency in a seamless and Kubernetes-native manner. Its simplicity and powerful capabilities make it an excellent choice for policy management in Kubernetes environments.