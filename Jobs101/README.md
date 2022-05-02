# Why Jobs?
There are already a host of different controllers Kubernetes provides that are built to handle pods. So why do Jobs exist? One thing to note here is that all other types of controllers share a common goal: ensuring that pods don't stay dead. If a pod was to terminate, the controller will ensure another pod is quickly created to fill in the gap.

But consider this situation: you want to run a pod that initializes a database, and then terminates. There is no point in running the pod forever since it's only supposed to run once, but if you were to use something like a Deployment, the pod would start right back up the second it terminated.

This is where jobs come into play. They ensure that pods run their specified commands **after which they terminate**. 

## Types of jobs
### Non-parallel Jobs
In the case of Non-parallel jobs, only one pod is started. The pod is then run to completion upon which it terminates. The termination of the pod also results in the completion of the job.

### Create a Non-parallel job using the following command:

``` $ kubectl create -f non-parallel-job.yml ```

This job starts up a pod, issues the command to sleep for 20 seconds, and then terminates the pod, which results in the job being completed.

### Look at the job:

``` $ kubectl get jobs ```

###  Watch the pod status:

``` $ kubectl get -w pods ```

### Delete a job:

``` $ kubectl delete -f non-parallel-job.yml ```


# Multiple Parallel Jobs (Work Queue)

Parallel job

### Create a job using following command:

``` $ kubectl create -f parallel-job.yml ```

### Look at the job:

``` $ kubectl get jobs ```

### Watch the pod status

``` $ kubectl get -w pods ```

### Delete a job:

``` $ kubectl delete -f parallel-job.yml ```

# Contributors

[Sangam Biradar](https://twitter.com/BiradarSangam)
