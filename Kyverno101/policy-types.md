# Policy types

Now let's look at the three main policy types.

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

Generation policies work based on triggers. This means that when a trigger is set off, a new resource will be created automatically. For example, ConfigMaps and secrets are bound to a single namespace. If you had a cluster with namespaces being made occasionally, it would be a hassle to manually create the secrets/ConfigMaps each time a new namespace is created. So a better alternative is to have a Kyverno generation policy that gets triggered when a new namespace is created that will automatically generate secrets and ConfigMaps for the new namespace. 

Since you likely need for certain variables to change while generating resources, Kyverno allows use of variables and placeholders to dynamically populate the generated resource with data from the source resource or cluster context. We will look at an example of using such variables. Once a resource is generated, you can also use Kyverno to maintain state by keeping the generated resource in sync with the source resource by automatically updating it when the source changes.

Finally, as with the other two policy types, you can apply generation policies to specific resources based on their kind, labels, or namespaces.

#### Example Policy: Generating a ConfigMap for New Namespaces

In this example policy, we will automatically generate a default `ConfigMap` with predefined data whenever a new namespace is created.

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

**`match.resources.kinds`** targets `Namespace` resources. The policy is triggered when a namespace is created. **`generate.kind`:** specifies that the resource to be generated is a `ConfigMap`. **`generate.name` and `generate.namespace`:** defines the name of the `ConfigMap` as `default-config` and the namespace of the `ConfigMap` is dynamically set to the name of the created namespace using the placeholder `{{request.object.metadata.name}}`. **`synchronize`:** ensures the generated `ConfigMap` stays in sync with this policy. If the `ConfigMap` is manually modified, Kyverno will revert it to match the policy definition. Finally we have **`data`:** defines the key-value pairs (`default-key: default-value`) that will be included in the generated `ConfigMap`.

Here is an example of the generate block for a secret being created.  

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

In this case, we use a placeholder variable `request.object.metadata.namespace` that will hold the namespace. The namespace will automatically be set to the ns of the object that is being referred. Instead of creating a new resource, if we were to clone a resource, it would look something like this:

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

In this case, the ConfigMap is cloned from `base-config` ConfigMap. Finally, here is an example of the generate block that creates a NetworkPolicy for every namespace:

3. **Creating Network Policies:**
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

This brings us to the end of the three policy types that are used by Kyverno.

Next, let's look at some Kyverno samples. 

[Kyverno samples](./kyverno-sample.md)