## Google Cloud Run

So far, you've created a managed Kubernetes cluster. However, if you were hosting a web application, you will still have to handle scaling yourself. The cluster's worker nodes would also be created using compute instances which are all dedicated to running your containers. This means that you will continue to be charged for the VMs whether or not you are using their resources to run pods. In a sense, you still have a whole infrastructure dedicated to you, whose computational costs and powers depend on you.

This is where Google Cloud Run comes in. Cloud run is a service that handles your containers, scales them depending on demand, and you only need to pay for the number of minutes and processing power your container actually uses. So you basically hand over all infrastructure related concerns to GCP and only focus on the content of your containers.

### Cloud Run process

From your end, using cloud run is quite simple. You first need to take the container that you want to run, and push it to gcr. You then need to deploy the image to cloud run. And that's it! A simple two step process to get your container up and running in Cloud Run. This is the same number of steps it took you to start a GKE cluster, except with Cloud Run you don't have to manage a cluster after you set it up.

Cloud run is a cloud service similar to other services GCP makes available. Therefore, you need to first enable the Cloud Run API. You could do this using the GCP console, or using the CLI/SDK:

```
gcloud services enable run.googleapis.com
```

As with the GKE clusters, you need to set a compute region where your resources will get created in:

```
gcloud config set compute/region us-central1
```

You then need to 



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