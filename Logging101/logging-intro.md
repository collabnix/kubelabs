# Why do we need logs?

The first thing that probably came to your mind when you saw the topic was debugging. Obviously, when your application crashes or has some sort of issue, then you would be quite interested to know why the issue came in the first place. Logging is especially useful in places such as production codebases that, for instance, belong to your clients. If one of their clusters was to have a problem, or if their services suddenly stopped working, instead of attaching directly to their clusters, you would take a look at their logs to see what went wrong. While this may be the most obvious use for logging, there are some others.

The second would be compliance. This obviously won't affect you if you're an individual developer, but if you work in a large organization, then there would be certain logging policies you have to follow. These can include company policies, data compliance policies, security policies, and so on. You might be aware of regulations such as GDPR, HIPAA, PCI, etc... which all require a certain level of logging to be present.

Finally, logging is very useful in identifying possible security threats. Keeping access logs allows you to blacklist any suspicious IPs and notice any breaches that may have occurred.

So, we've established that logging is important, and in some cases, mandatory. How do we go about actually implementing logging?

# Logging strategies

When you talk about a software log, you immediately think of a log file. This is the most common way to log things. It doesn't matter what type of software you use on a daily basis, there is definitely some sort of logging going on in the background. But is this the most optimal way to log things, especially in a cluster with multiple microservices that keep spewing hundreds of lines of data every second? Let me rephrase that question: when was the last time you actually enjoyed reading a log file? I'm guessing the answer is never. That is because log files are not made with human readability in mind. The only job of a log file is to hold as much data as possible so that hopefully, somewhere in between all the junk, the actual root cause for your error can be found. Naturally, this is not optimal when it comes to clusters.

This is where some visualization would be useful, and let's start off by talking about that strategy. More specifically, let's dive into the world of Elasticsearch.

[Next: Elasticsearch](./what-is-elasticsearch.md)