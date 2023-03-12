# Creating Your First NetworkPolicy Definition

The NetworkPolicy resource uses labels to determine which pods it will manage. The security rules defined in the resource are applied to groups of pods. This works in the same sense as security groups that cloud providers use to enforce policies on groups of resources. Below is a sample network policy.

```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: test-network-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - ipBlock:
        cidr: 172.17.0.0/16
        except:
        - 172.17.1.0/24
    - namespaceSelector:
        matchLabels:
          project: myproject
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 6379
  egress:
  - to:
    - ipBlock:
        cidr: 10.0.0.0/24
    ports:
    - protocol: TCP
      port: 5978
      
    ```
Let us look into it in detail. First, you would notice that it is of Kind NetworkPolicy, and it is meant to apply to pods that have the label `db`. The next section says that this policy allows both ingresses and egresses in and out of the pods. The next two blocks define where the ingresses and egresses are allowed to come from. Before we go into that section, you will notice that `cidr` ranges have been specified. So let's take a closer look at what cidr is.

## CIDR
