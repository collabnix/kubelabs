# What is Kubernetes Service Catalog?

Service catalog is yet another *[controller](https://kubernetes.io/docs/concepts/architecture/controller/)* in kubernetes ecosystem, What else will it be? 😉

If you are thinking, "I was just starting to understand what are pods and deployments and now this" 🤯<br/>
Not to worry that was just the case with me when I started with `Service Catalog`.

Let's not panic! Just take a deep breath and thank god because after going through this write-up you'll be well equipped with the concept of `Service Catalog` 🎊 🎉

## Let's get started (Service Catalog 101)

Concept of `Service Catalog` is not specific to kubernetes universe of controllers. It is an old term first referenced in ITIL (Information Technology Infrastructure Library)and has been used many times in software development.<br/>
For more information: [Click Here](https://searchcio.techtarget.com/definition/IT-service-catalog)

So, What is service catalog?

Let'a take an example of Urban Clap:

* Urban clap provides home services through an online marketplace.
* As a customer you'll visit the website choose a service you want from the **service catalog**.
* The service you choose we'll be serviced to you by a service broker.

And that is it, That is the whole concept of service catalog and brokers.

Now, Apply the same concept in SDLC (Software Development Life Cycle)<br/>
<br/>Suppose, You are developing an online E-Commerce store and decide to use microservice architecture for the same.<br/>
To have a robust website you decided to use following third party services provided by your cloud provider or some other vendor, These services are listed as follows:
- Message queuing service
- DNS services 
- Certificate manager
- Authorization gateways

Not to the surprise you'll have to configure access to these services with proper credentials such that only authenticated clients can use these services.

Also, You decided to use kubernetes as the container orchestrator for your website.

Now, To configure access to these services you
first instantiated these services on the third party and then created secrets for each of these service credentials and mounted these into the pods and it is working flawlessly.<br/>
But as your application is growing you need to use more and more services and configure the credentials for the same which is a bit (very) cumbersome.

**ServiceCatalog** kubernetes controller to the rescue.
Instead of configuring those services manually you deploy a ServiceCatalog and ServiceBroker (Vendor specific) in your cluster and then use the same to create access credential secrets in your cluster and mount those in necessary pods, This is what we call seamlessness of kubernetes universe of controllers.
