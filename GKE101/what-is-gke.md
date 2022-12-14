# Google Kubernetes Engine

Google cloud is another managed cloud service which allows you to do all sorts of things without having to worry about managing the infrastructure. As will all other cloud platforms, it also comes with its own Kubernetes engine, which will be the focus of this section.

To start, you will need a [Google cloud account](https://cloud.google.com/free). You will get $300 free credit if you are signing up for the first time, which should be more than enough for us to cover this lesson. Once you finish setting up your account, head over to the [cloud console](https://console.cloud.google.com). Now is a good time to become a little familiar with the core GCP concepts. First of all, if you have any experience with other cloud providers, GCP is more or less the same. It has a compute section that allows you to set up compute instances, API section which allows you to manage APIs, IAM section that allows you to manage users and authentication, and a Kubernetes section where we will be creating clusters.

In the top right corner, you can see the option to start up a cloud shell. As with all the other cloud providers, Google allows you to do everything programatically (as opposed to doing them in the portal). The cloud shell has `gcloud` pre-installed, and provides a small VM you can use to run commands on your project.

If you were to hover over the `Kubernetes Engine` section.