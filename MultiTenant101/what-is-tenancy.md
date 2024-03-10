# Multi-tenant architecture

A multi-tenant architecture is when you segregate your infrastructure based on your clients. A single instance of the software application is served to multiple customers, known as tenants. Each tenant's data and configuration are logically isolated from each other, but they share the same underlying infrastructure and codebase.

This can have many benefits, but whether you should go for an infrastructure like this is dependent on several things. Let's start off by looking at the immediate advantages of this design.

First and foremost is resource isolation. Not only does this improve security and compliance for the organization, but it also enables you to get a better idea of the resource usage and related costs that each client incurs for your company. You can use this information to better improve billing. If you have a large number of small clients (individual customers), you could even provision resources on a per-customer basis. This is not in the scope of this lesson but is covered in the [Kubezoo](../Kubezoo/what-is-kubezoo.md) section.