# Autoscaling helpers

We have now discussed HPA's, VPA's, and you might have even read the section on [KEDA](../Keda101/what-is-keda.md) to learn about advanced scaling. Now that you know all there is to about scaling, let's take a step back and look at a few important things to consider when it comes to scaling. In this section, we will discuss:

- Readiness/liveness/startup probes
- Graceful shutdowns
- Annotations that help with scaling.

You may have already come across these concepts before, and just about every Kubernetes-based tool uses them to ensure stability. We will discuss each of the above points and follow up with a lab where we test out the above concepts using a simple Nginx server.

# Probes

What are readiness/liveness/startup probes and why are they useful for autoscaling? Let's break down each type of probe.

- Readiness probe: As the name suggests, this probe checks to ensure that your container is ready.

In order to do this, you could implement several methods. The simplest and most frequently used is the http get method. You simply point the readiness probe at your containers' endpoint, then have the probe ping it. If the response to the ping is 200 OK, your pod is ready to start receiving traffic. This is incredibly useful since it's rare that your application is ready to go immediately after starting up. Usually, the application needs to establish connections with databases, contact other microservices to get some starting information, or even run entire startup scripts to prepare the application. So it may take a couple of seconds to a couple of minutes for your application to be ready to take traffic. If any requests come in within this period, they will be dropped. With the readiness probe, you can be assured that this won't happen.

Apart from a simple HTTP get requests, you could also run TCP commands to see if ports are up, or even run a whole bash script that executes all manner of commands to determine whether your pod is ready.