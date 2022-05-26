# Chart repositories

You already know what a chart repository is and how to install a chart off an existing repo. So let us consider how we would go about creating a chart repo and serving it, as well as a deep-dive into chart repositories.

While chart repositories such as ArtifactHub exist, you may want to create your own chart repositories. A chart repository is simply an HTTP server whcih has an ```index.yaml``` in it. The HTTP server does not need to be a physical server, and can instead be a GCS bucket, S3 bucket, or even something like GitHub pages. Going back to the ```index.yaml```, this is neccessary to hold a reference to all charts in a repo, and is generally hosted on the same server.

To create this file, use

```bash
helm repo index
```

This generates an index file. If you have packages charts (such as alpine) present in the local directory where you run this command, those charts will be taken into consideration.

## Hosting a chart

Now that your chart repo structure is complete, let's go ahead and host the chart. There are a ton of ways to achieve this, and we will be using GitHub pages. This [official guide](https://docs.github.com/en/pages/getting-started-with-github-pages/creating-a-github-pages-site) should be able to start you off with creating a GitHub page.

Once your page is setup, there are some other steps that need completing in order for you to convert it to a Helm chart repo. You need to use [chart releaser](https://github.com/helm/chart-releaser). Chart releaser is a GitHub action workflow, which is essentially a pipeline you can use to automate releases. Read more about GitHub action [here](https://github.com/features/actions).
