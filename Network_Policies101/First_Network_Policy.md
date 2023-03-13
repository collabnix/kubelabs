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

Let us look into it in detail. First, you would notice that it is of Kind NetworkPolicy, and it is meant to apply to pods that have the label `db`. The next section says that this policy allows both ingresses and egresses in and out of the pods. The next two blocks define where the ingresses and egresses are allowed to come from. Ingress has a "from" section while egress has a "to" section, and each section has a largely similar body. An `ipBlock` section has been defined with a CIDR range to define which IP addresses are allowed. In the above case, the cidr is `172.17.0.0/16`, which means that this ingress rule covers everything from 172.17.0.0 – 172.17.255.255. The `-16` is what dictates this range. However, if you were to create a pod with an IP address of 172.17.1.0 and use this network policy, the pod will not be included in the ingress range. This is because of the `except` section that singles out `172.17.1.0/24`, which is the whole range from 172.17.1.0 to 172.17.1.255. Any pod with an address from that range will not fall into the ingress category.

The next two parts of the ingress block are the `namespaceSelector` and `podSelector`. These allow you to match all the pods in a specific namespace, as well as all the pods that have a specific pod label. The final part is the `ports` section which determines which ports and protocols can be used to communicate into the pods. So in a way, everything that happens inside this block filter pods that are allowed to communicate with the pods to the network policy gets applied.