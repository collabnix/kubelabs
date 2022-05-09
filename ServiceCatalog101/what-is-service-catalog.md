# What is Kubernetes Service Catalog?

Service catalog is yet another *[controller](https://kubernetes.io/docs/concepts/architecture/controller/)* in the Kubernetes ecosystem, what else is it? 😉

The Concept of `Service Catalog` is not specific to the Kubernetes universe of controllers. It is an old term first referenced in ITIL (Information Technology Infrastructure Library)and has been used many times in software development. For more information: [Click Here](https://searchcio.techtarget.com/definition/IT-service-catalog)

So, What is a service catalog?

Let's take an example of Urban Clap:

* Urban clap provides home services through an online marketplace.
* As a customer you'll visit the website and choose a service you want from the **service catalog**.
* The service you choose will be serviced to you by a service broker.

And that's it. That is the whole concept of service catalogs and brokers.

Now, Apply the same concept in SDLC (Software Development Life Cycle)

Suppose you are developing an online E-Commerce store and decide to use microservice architecture for the same. To have a robust website you decided to use the following third-party services provided by your cloud provider (or some other vendor). These services are listed as follows:

* Message queuing service
* DNS services
* Certificate manager
* Authorization gateways

Not to your surprise, you'll have to configure access to these services with proper credentials such that only authenticated clients can use these services.

So you start by using Kubernetes as the container orchestration platform for your site. Now, to configure access to these services, you first have to instantiate these services on the third-party applications, and then create secrets for each of these service credentials. You then have to mount these into the pods, and it would end up working flawlessly.
But then the problems start showing themselves. As your application starts growing, you need to use more and more services and configure the credentials for each of them, which is a bit (very) cumbersome.

Enter **ServiceCatalog** Kubernetes controller to the rescue.
Now, instead of configuring those services manually, you deploy a ServiceCatalog and ServiceBroker (which is vendor-specific) into your cluster and then use this to create access credential secrets in your cluster. You can then mount those in the necessary pods. This is what we call the seamlessness of Kubernetes universe of controllers.
