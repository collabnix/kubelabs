## Installing Kyverno:

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

## Kyverno Samples

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