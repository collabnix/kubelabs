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


gcloud container images delete gcr.io/$GOOGLE_CLOUD_PROJECT/helloworld

625a213ab16a: Pull complete
098b7ecb0094: Pull complete
Digest: sha256:bc93ed5e6ae40569caa4b410dac9141e14314f9cc9a756b0cf63152af4ef22e1
Status: Downloaded newer image for gcr.io/qwiklabs-gcp-00-c9a357e9b43e/helloworld:latest
e1fd0174ab6b855bd505dcdc225d22b955e68834ff45bdd80fa98cca14c2a15e
student_03_e8bcf68266cc@cloudshell:~/helloworld (qwiklabs-gcp-00-c9a357e9b43e)$ gcloud run deploy --image gcr.io/$GOOGLE_CLOUD_PROJECT/helloworld --allow-unauthenticated --region=$LOCATION
Service name (helloworld):
Deploying container to Cloud Run service [helloworld] in project [qwiklabs-gcp-00-c9a357e9b43e] region [us-central1]
OK Deploying new service... Done.                                                        
  OK Creating Revision... Revision deployment finished. Checking container health.
  OK Routing traffic...
  OK Setting IAM Policy...
Done.
Service [helloworld] revision [helloworld-00001-gis] has been deployed and is serving 100 percent of traffic.
Service URL: https://helloworld-lj5fky4csa-uc.a.run.app

[Next: GKE Service Mesh](gke-service-mesh.md)