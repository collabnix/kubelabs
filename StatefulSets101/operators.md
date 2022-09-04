# Operators

As we saw in the previous section, Statful sets are extremely useful when it comes to managing persistent data. But managing the stateful applications come with a certain amount of leg work. It's entirely down to the architecture of how Kubernetes has been designed. If we consider a stateless application, Kubernetes is great since it handles everything automatically. If you want to scale your application up or down, add new resources while the application is running, perform rolling updates, you have minimal work on your hands since Kubernetes can do all this for you. If a pod goes down, Kubernetes bring it back up. If a job fails to execute, Kubernetes tries again. This all relies on the fact that these resources are ephermeral, and that one instance is indistinguishable from the next.

However, this is not the case with stategul sets. You can't take down one database pod, start a second database pod, and expect all the data to remain. Statful sets exist for this purpose, ensuring that resources are persisted. But this means that no longer can Kubernetes manage your application for you; you must do it yourself. Each database, logger has its own way of doing things, so there is no one-size-fits-all solution, and you need to keep an eye on things across the entire application lifecycle. At this point, it appears as if the whole purpose of using Kubernetes might be lost, but that is where operators come in.

## What is an operator

