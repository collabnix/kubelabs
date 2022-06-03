# Identity Access Management in AKS

Since your Kubernetes cluster would be hosted in AKS, you now need a way to manage access to this cluster. This is what this section will discuss.

## Kubernetes RBAC

Kubernetes Role-Based Access Control gives specialized control to various user actions. For instance, one user may only want to read the logs while another user would have to modify resources. RBAC allows you to specify what each user can and cannot do. However, these permissions aren't blanket permissions that apply across the cluster. So if you wanted to allow one person to run application workload in one namespace, while having only read access to logs in a different namespace, this can be handled.

This isn't all the RBAC offers. Imagine you were working in a large organization, where multiple people across various teams access the same cluster. In this situation, it makes little sense to sit around assigning access rights to every single user. All users from team A might only need basic read access, while everyone from team B needs to be set as admins of the cluster. So you could simply create a role called "read users", and another role called "admins", then bulk assign all users to their respective roles and expect them to have the proper levels of access. If you have used AWS IAM then you would be familiar with this concept.

### Roles

User permissions get defined as a role. Any roles created are valid within that namespace. However, if you want a role that applies across the entire cluster, then you should go for **cluster roles**. Just creating the roles won't do anything, as you would have to assign RBAC permission to this role. That is to say, you would bind a specific set of permissions to each role with a **RoleBinding**. Once again, RoleBinding, like roles, applies only to the specified namespace. If you want the RoleBinding to apply to the entire cluster, then you have to use a **ClustRoleBinding**.

If you are in an enterprise environment that uses Azure AD, you can manage access to your cluster using [Azure AD integration](https://docs.microsoft.com/en-us/azure/aks/concepts-identity#azure-ad-integration).

Next, let's move on to the storage options available for AKS.

[Next: AKS Storage](./aks-storage.md)