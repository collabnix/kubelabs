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

Apart from a simple HTTP get requests, you could also run TCP commands to see if ports are up, or even run a whole bash script that executes all commands to determine whether your pod is ready. However, this probe only continually checks to see if your app is ready to take requests. It blocks off any traffic if it starts to notice that the probe is failing. If you only have a readiness probe in place, even if your app has gone into an error state, Kubernetes will only prevent traffic from entering that pod until the probe starts to pass. It will not restart the failed application for you. This is where liveness probes come in.

- Liveness probe: Check if your application is alive.

A liveness and readiness probe do almost the same thing, except a liveness probe restarts the pod if it starts failing, unlike the readiness probe which only stops traffic to the pod until the probe starts succeeding. This means that the liveness probe should come after the readiness probe. You could say something like: if my container's port 8080 isn't being reached, stop sending traffic (readiness probe). If it is still unreachable after 1 minute, fail the liveness probe and restart the pod since the container has likely crashed, gone OOM, or is meeting some other pod or node constraints.

- Startup probe: A probe similar to the other two, but only runs on startup.

If your pod takes a while to initialize, it's best to use startup probes. Startup probes ensure that your pod started correctly. You can even use the same endpoint as the liveness probe but with a less strict wait time. When your pod is already running, you don't expect the endpoint to go down for more than a few seconds if at all. However, when starting up, you can expect it to be down until your application finishes initializing. This is why there is a separate startup probe instead of re-using the existing liveness probe.