# Why Jobs?
There are already a host of different controllers Kubernetes provides that are built to handle pods. So why do Jobs exist? One thing to note here is that all other types of controllers share a common goal: ensuring that pods don't stay dead. If a pod was to terminate, the controller will ensure another pod is quickly created to fill in the gap.

But consider this situation: you want to run a pod that initializes a database, and then terminates. There is no point in running the pod forever since it's only supposed to run once, but if you were to use something like a Deployment, the pod would start right back up the second it terminated.

This is where jobs come into play. They ensure that pods run their specified commands **after which they terminate**. 

## Types of jobs
## Non-parallel Jobs
In the case of Non-parallel jobs, only one pod is started. The pod is then run to completion upon which it terminates. The termination of the pod also results in the completion of the job.

### Create a Non-parallel job using the following command:

``` $ kubectl create -f non-parallel-job.yml ```

This job starts up a pod, issues the command to sleep for 20 seconds, and then terminates the pod, which results in the job being completed. The below commands should allow you to see this in action.

### Look at the job:

``` $ kubectl get jobs ```

###  Watch the pod status:

``` $ kubectl get -w pods ```

### Delete a job:

``` $ kubectl delete -f non-parallel-job.yml ```

Note that the jobs and their respective pods get **terminated**, not deleted. This is useful in situations where you might want to get access to the pod logs after the job finishes executing. Running the above command deletes the job, which results in the pod being removed as well.

## Multiple Non-parallel Jobs
Multiple non-parallel jobs, or rather, multiple sequential jobs, are the second type. These are very similar to normal non-parallel jobs except for one key difference, which is that multiple jobs run one after the other. That is to say, the job spins up a pod as usual, but once the pod is terminated, another pod is spun up. This continues until the specified number of iterations is complete. The number of iterations is specified by setting ```completions: 5```. Apart from this line, there are no other differences.

### Create a Multiple Non-parallel jobs using the following command:

``` $ kubectl create -f multiple-non-parallel-job.yml ```

### Look at the job:

``` $ kubectl get jobs ```

###  Watch the pod status:

``` $ kubectl get -w pods ```

Notice how the pods spin up and terminate sequentially for 5 times.

### Delete the job:

``` $ kubectl delete -f multiple-non-parallel-job.yml ```

## Multiple Parallel Jobs (Work Queue)

Multiple single jobs are fine, but what if you want to run several jobs in parallel? Work queue jobs should help you with this. Similar to multiple parallel jobs, ```completions: ``` can be used to specify the number of jobs. However, this is not mandatory. Leaving out this line will result in the completions being set to the number of parallelisms specified. The line ```parallelism: 2```, which specifies how many jobs should run in parallel must be specified to indicate that this is a multiple parallel job.

### Create a job using following command:

``` $ kubectl create -f parallel-job.yml ```

### Look at the job:

``` $ kubectl get jobs ```

### Watch the pod status

``` $ kubectl get -w pods ```

Notice how all the pods spawn at the same time.

### Delete a job:

``` $ kubectl delete -f parallel-job.yml ```

# Contributors

[Sangam Biradar](https://twitter.com/BiradarSangam)

[Mewantha Bandara](https://github.com/Phantom-Intruder)