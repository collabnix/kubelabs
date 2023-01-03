## Google Cloud Run

So far, you've created a managed Kubernetes cluster. However, if you were hosting a web application, you will still have to handle scaling yourself. The cluster's worker nodes would also be created using compute instances which are all dedicated to running your containers. This means that you will continue to be charged for the VMs whether or not you are using their resources to run pods. In a sense, you still have a whole infrastructure dedicated to you, whose computational costs and powers depend on you.

This is where Google Cloud Run comes in. Cloud run is a service that handles your containers, scales them depending on demand, and you only need to pay for the number of minutes and processing power your container actually uses. So you basically hand over all infrastructure related concerns to GCP and only focus on the content of your containers.

### Cloud Run process

From your end, using cloud run is quite simple. You first need to take the container that you want to run, and push it to gcr. You then need to deploy the image to cloud run. And that's it! A simple two step process to get your container up and running in Cloud Run. This is the same number of steps it took you to start a GKE cluster, except with Cloud Run you don't have to manage a cluster after you set it up.

Now let's go ahead with a Cloud Run lab. You can do the lab using the gcloud SDK if you have it installed on your machine, or using the cloud shell.

Cloud run is a cloud service similar to other services GCP makes available. Therefore, you need to first enable the Cloud Run API. You could do this using the GCP console, or using the CLI/SDK:

```
gcloud services enable run.googleapis.com
```

As with the GKE clusters, you need to set a compute region where your resources will get created in:

```
gcloud config set compute/region us-central1
```

You then need to take your Docker image and push it. You can either use the gcloud SDK on your local machine to push an image that you have created or create a new image on Google cloud using cloud shell. If you are using cloud shell, a simple NodeJs application would do. Open up cloud shell and paste in the following commands.

Create a directory for your new project:

```
mkdir helloworld && cd helloworld
```

Create a NodeJS application:

```
echo '{
  "name": "helloworld",
  "description": "Simple hello world sample in Node",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "start": "node index.js"
  },
  "author": "Google LLC",
  "license": "Apache-2.0",
  "dependencies": {
    "express": "^4.17.1"
  }
}' > package.json
```

```
echo "const express = require('express');
const app = express();
const port = process.env.PORT || 8080;
app.get('/', (req, res) => {
  const name = process.env.NAME || 'World';
  res.send('Hello ${name}!');
});
app.listen(port, () => {
  console.log('helloworld: listening on port ${port}');
});" > index.js
```

Create a Dockerfile that will be used to make the image:

```
echo '
FROM node:12-slim
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --only=production
COPY . ./
CMD [ "npm", "start" ]' > Dockerfile
```

Now you need to build the image. However, you don't have to do this manually as gcloud offers a single-line command to get the application ready for Cloud Run. You need to get the name of your Google Cloud project, and use it to run the below command on the cloud shell:

```
gcloud builds submit --tag gcr.io/<project-name>/helloworld
```

You can list the images and verify that the image has been created:

```
gcloud container images list
```

You can test this image locally using Docker as you would any normal Docker image. When you are certain that the image is ready for deployment, you can deploy the image to cloud run with:

```
gcloud run deploy --image gcr.io/<project-name>/helloworld --allow-unauthenticated --region=$LOCATION
```

When you run the command, the image you just created will be deoloyed with a log output like this:

```
Service name (helloworld):
Deploying container to Cloud Run service [helloworld] in project <project-name> region [us-central1]
OK Deploying new service... Done.                                                        
  OK Creating Revision... Revision deployment finished. Checking container health.
  OK Routing traffic...
  OK Setting IAM Policy...
Done.
Service [helloworld] revision [helloworld-00001-gis] has been deployed and is serving 100 percent of traffic.
Service URL: https://helloworld-lj5fky4csa-uc.a.run.app
```

As you can see from above, the container is run and health checks are performed to ensure that the container is working as intended. IAM policies are also automatically set, and traffic starts being immediately routed into your container. All this happens behind the scenes and requires no configuration from you. If the traffic throughput increases, Cloud Run will automatically increase the number of replicas to handle the increase in traffic by itself.

You can also go to the **Navigation Menu >> Cloud Run** to get a graphical overview of your Cloud Run deployment.

### Cleaning up

Cloud Run doesn't utilize any resources when idle, unlike a GKE cluster where you always have multiple compute instances running. However, it's still necessary to clean up Cloud Run since you are storing the container image within GCP and will get charged for it. Use this command to delete the container image:

```
gcloud container images delete gcr.io/<project-name>/helloworld
```

Then delete the Cloud Run instance:

```
gcloud run services delete helloworld --region=us-central1
```

Alternatively, you could just delete your whole project if there is nothing else on it.

And that's it! Now, we can move on to learning a different way to run applications on GCP using GKE service meshes.

[Next: GKE Service Mesh](gke-service-mesh.md)