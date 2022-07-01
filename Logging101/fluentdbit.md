# Fluent Bit

Now that we've covered Fluentd, it's time to look into Fluent Bit. Fluent Bit is similar to fluentd, but is signifficantly more lightweight and consumes very little resources. Fluent Bit also has zero dependencies on anything, meaning that you can get it up and running relatively fast. However, both fluentd and Fluent Bit follow the same architecture for logging and metrics collection, and have a large number of similarities. You can also use both of them together to create a custom logging architecture.

## What is Fluent Bit?

Fluent Bit is basically the same thing as fluentd. It acts as a logging layer that collects logs from across any input source that you specify, including infrastructure resources. It then parses, fileters, and outputs the data in the same way fluentd does. It even uses plugins in the same way fluentd uses them to handle data. The advantage comes up when we need a logging layer in a containerized environment such as with a Kubernetes cluster which has a limited amount of resources and requires a logging layer that can work on each node to produce logs that can be then forwarded to a centralized logging layer such as fluentd.