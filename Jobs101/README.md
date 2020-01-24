# Creating Your First Kubernetes Job


Non-parallel job

## Create a job using following command:

``` $ kubectl create -f non-parallel-job.yml ```

## Look at the job:

``` $ kubectl get jobs ```

##  Watch the pod status:

``` $ kubectl get -w pods ```

## Delete a job:

``` $ kubectl delete -f non-parallel-job.yml ```
