# CronJobs101: Scheduled Jobs in Kubernetes

## What are Kubernetes CronJobs?

- CronJobs are Kubernetes objects that create Jobs on a repeating schedule
- They use the same cron format as Unix/Linux cron jobs
- CronJobs are useful for periodic and recurring tasks like backups, report generation, and data cleanup
- Each CronJob creates a Job object approximately once per execution time of its schedule
- CronJobs are designed for running tasks at specific times or intervals

## Why Use CronJobs?

CronJobs solve several important use cases:

- **Automated Backups**: Schedule database or volume backups at regular intervals
- **Report Generation**: Create daily, weekly, or monthly reports automatically
- **Data Cleanup**: Remove old logs, temporary files, or expired data
- **Health Checks**: Periodically verify system health and send alerts
- **Batch Processing**: Run batch jobs at off-peak hours
- **Certificate Renewal**: Automate certificate rotation and renewal

## CronJob vs Job

The key differences:

| Feature | Job | CronJob |
|---------|-----|---------|
| Execution | One-time | Scheduled/Recurring |
| Schedule | Manual/Immediate | Cron expression |
| Use Case | Ad-hoc tasks | Periodic tasks |
| Management | Single completion | Creates multiple Jobs |

## Understanding Cron Schedule Format

The cron schedule format has 5 fields:

```
# ┌───────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌───────────── day of the month (1 - 31)
# │ │ │ ┌───────────── month (1 - 12)
# │ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday)
# │ │ │ │ │
# │ │ │ │ │
# * * * * *
```

### Common Schedule Examples

- `*/1 * * * *` - Every minute
- `*/5 * * * *` - Every 5 minutes
- `0 * * * *` - Every hour (at minute 0)
- `0 0 * * *` - Every day at midnight
- `0 2 * * *` - Every day at 2:00 AM
- `0 0 * * 0` - Every Sunday at midnight
- `0 0 1 * *` - First day of every month at midnight
- `0 0 1 1 *` - January 1st at midnight (yearly)

## Pre-requisite

- Running Kubernetes cluster
- kubectl configured
- Basic understanding of Kubernetes Jobs

## Creating Your First CronJob

Let's create a simple CronJob that runs every minute and prints the current date.

### Step 1: Create the CronJob YAML

Save this as `cronjob-hello.yaml`:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello-cronjob
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox:latest
            imagePullPolicy: IfNotPresent
            command:
            - /bin/sh
            - -c
            - date; echo "Hello from Kubernetes CronJob"
          restartPolicy: OnFailure
```

### Step 2: Apply the CronJob

```bash
kubectl apply -f cronjob-hello.yaml
```

**Expected Output:**
```
cronjob.batch/hello-cronjob created
```

### Step 3: Verify CronJob Creation

```bash
kubectl get cronjobs
```

**Expected Output:**
```
NAME            SCHEDULE      SUSPEND   ACTIVE   LAST SCHEDULE   AGE
hello-cronjob   */1 * * * *   False     0        <none>          10s
```

### Step 4: Watch Jobs Being Created

Wait for about a minute and check the jobs:

```bash
kubectl get jobs --watch
```

**Expected Output:**
```
NAME                       COMPLETIONS   DURATION   AGE
hello-cronjob-28391820     1/1           5s         65s
hello-cronjob-28391821     1/1           4s         5s
```

### Step 5: View Job Logs

```bash
kubectl logs -l job-name=hello-cronjob-28391820
```

**Expected Output:**
```
Fri Dec 13 10:30:00 UTC 2024
Hello from Kubernetes CronJob
```

### Step 6: Describe the CronJob

```bash
kubectl describe cronjob hello-cronjob
```

**Expected Output:**
```
Name:                          hello-cronjob
Namespace:                     default
Labels:                        <none>
Annotations:                   <none>
Schedule:                      */1 * * * *
Concurrency Policy:            Allow
Suspend:                       False
Successful Job History Limit:  3
Failed Job History Limit:      1
Starting Deadline Seconds:     <unset>
Selector:                      <unset>
Parallelism:                   <unset>
Completions:                   <unset>
Active Deadline Seconds:       <unset>
Backoff Limit:                 6
Events:
  Type    Reason            Age   From                Message
  ----    ------            ----  ----                -------
  Normal  SuccessfulCreate  2m    cronjob-controller  Created job hello-cronjob-28391820
  Normal  SuccessfulCreate  1m    cronjob-controller  Created job hello-cronjob-28391821
  Normal  SuccessfulCreate  5s    cronjob-controller  Created job hello-cronjob-28391822
```

## CronJob Configuration Options

### 1. Concurrency Policy

Controls how to handle concurrent job executions:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: concurrency-example
spec:
  schedule: "*/1 * * * *"
  concurrencyPolicy: Forbid  # Allow | Forbid | Replace
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: task
            image: busybox
            command: ["sleep", "90"]  # Runs longer than schedule
          restartPolicy: OnFailure
```

**Concurrency Policy Options:**
- `Allow` (default): Allows concurrent jobs to run
- `Forbid`: Skips the new job if previous is still running
- `Replace`: Replaces the currently running job with a new one

### 2. Suspend a CronJob

Temporarily disable a CronJob without deleting it:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: suspended-cronjob
spec:
  schedule: "*/5 * * * *"
  suspend: true  # Set to true to suspend
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: task
            image: busybox
            command: ["echo", "This won't run while suspended"]
          restartPolicy: OnFailure
```

Or suspend via kubectl:
```bash
kubectl patch cronjob hello-cronjob -p '{"spec":{"suspend":true}}'
```

### 3. Job History Limits

Control how many completed and failed jobs to keep:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: history-limit-example
spec:
  schedule: "0 */6 * * *"
  successfulJobsHistoryLimit: 5  # Keep last 5 successful jobs
  failedJobsHistoryLimit: 3      # Keep last 3 failed jobs
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: task
            image: busybox
            command: ["echo", "Managing job history"]
          restartPolicy: OnFailure
```

### 4. Starting Deadline

Set a deadline for starting the job:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: deadline-example
spec:
  schedule: "*/1 * * * *"
  startingDeadlineSeconds: 100  # Job must start within 100s of scheduled time
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: task
            image: busybox
            command: ["echo", "Started on time"]
          restartPolicy: OnFailure
```

## Real-World Example: Database Backup CronJob

Create a CronJob that backs up a PostgreSQL database daily at 2 AM:

Save as `cronjob-db-backup.yaml`:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: postgres-backup
  labels:
    app: database-backup
spec:
  schedule: "0 2 * * *"  # Daily at 2:00 AM
  concurrencyPolicy: Forbid
  successfulJobsHistoryLimit: 7  # Keep 7 days of backups
  failedJobsHistoryLimit: 3
  jobTemplate:
    spec:
      template:
        metadata:
          labels:
            app: postgres-backup
        spec:
          containers:
          - name: backup
            image: postgres:15-alpine
            env:
            - name: PGHOST
              value: "postgres-service"
            - name: PGUSER
              value: "backup_user"
            - name: PGPASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: password
            - name: BACKUP_DATE
              value: "$(date +%Y%m%d_%H%M%S)"
            command:
            - /bin/sh
            - -c
            - |
              echo "Starting backup at $(date)"
              pg_dump -Fc mydatabase > /backup/backup_${BACKUP_DATE}.dump
              echo "Backup completed at $(date)"
            volumeMounts:
            - name: backup-storage
              mountPath: /backup
          restartPolicy: OnFailure
          volumes:
          - name: backup-storage
            persistentVolumeClaim:
              claimName: backup-pvc
```

## Real-World Example: Log Cleanup CronJob

Clean up old logs every Sunday at midnight:

Save as `cronjob-log-cleanup.yaml`:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: log-cleanup
spec:
  schedule: "0 0 * * 0"  # Every Sunday at midnight
  concurrencyPolicy: Forbid
  successfulJobsHistoryLimit: 4
  failedJobsHistoryLimit: 2
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: cleanup
            image: busybox:latest
            command:
            - /bin/sh
            - -c
            - |
              echo "Starting log cleanup at $(date)"
              find /logs -name "*.log" -mtime +30 -delete
              echo "Deleted logs older than 30 days"
              echo "Cleanup completed at $(date)"
            volumeMounts:
            - name: log-storage
              mountPath: /logs
          restartPolicy: OnFailure
          volumes:
          - name: log-storage
            hostPath:
              path: /var/log/myapp
              type: Directory
```

## Managing CronJobs

### List All CronJobs

```bash
kubectl get cronjobs
```

Or with more details:
```bash
kubectl get cronjobs -o wide
```

### Describe a CronJob

```bash
kubectl describe cronjob <cronjob-name>
```

### View All Jobs Created by a CronJob

```bash
kubectl get jobs -l job-name=<cronjob-name>
```

Or:
```bash
kubectl get jobs --selector=cronjob-name=hello-cronjob
```

### Manually Trigger a CronJob

Create a job manually from a CronJob:

```bash
kubectl create job --from=cronjob/hello-cronjob manual-job-1
```

### Edit a CronJob

```bash
kubectl edit cronjob hello-cronjob
```

### Suspend/Resume a CronJob

Suspend:
```bash
kubectl patch cronjob hello-cronjob -p '{"spec":{"suspend":true}}'
```

Resume:
```bash
kubectl patch cronjob hello-cronjob -p '{"spec":{"suspend":false}}'
```

## Troubleshooting CronJobs

### Check CronJob Status

```bash
kubectl get cronjob hello-cronjob -o yaml
```

### View Recent Jobs

```bash
kubectl get jobs --sort-by=.status.startTime
```

### Check Pod Logs from CronJob

```bash
# Get the latest job
JOB=$(kubectl get jobs --sort-by=.status.startTime -o jsonpath='{.items[-1].metadata.name}')

# Get logs from the job
kubectl logs job/$JOB
```

### Common Issues and Solutions

**Issue: Jobs not being created**
```bash
# Check if CronJob is suspended
kubectl get cronjob hello-cronjob -o jsonpath='{.spec.suspend}'

# Check CronJob events
kubectl describe cronjob hello-cronjob
```

**Issue: Too many old jobs**
```bash
# Delete old jobs manually
kubectl delete jobs --field-selector status.successful=1

# Or update history limits
kubectl patch cronjob hello-cronjob -p '{"spec":{"successfulJobsHistoryLimit":1}}'
```

**Issue: Jobs failing**
```bash
# Check failed job logs
kubectl get jobs --field-selector status.successful=0
kubectl logs job/<failed-job-name>
```

## Best Practices

1. **Set Appropriate History Limits**: Keep only necessary job history to avoid cluster bloat
2. **Use Concurrency Policy**: Prevent resource contention with appropriate concurrency settings
3. **Set Starting Deadline**: Avoid delayed job execution pile-up
4. **Monitor CronJob Execution**: Set up alerts for failed jobs
5. **Use Secrets for Sensitive Data**: Never hardcode passwords or keys
6. **Test Schedules**: Start with frequent schedules for testing, then adjust
7. **Resource Limits**: Set resource requests and limits for predictable performance
8. **Idempotent Jobs**: Design jobs to be safely re-runnable
9. **Logging**: Ensure adequate logging for debugging
10. **Cleanup**: Regularly review and remove unused CronJobs

## Advanced Example: Multi-Step Backup with Notifications

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: advanced-backup
spec:
  schedule: "0 3 * * *"
  concurrencyPolicy: Forbid
  startingDeadlineSeconds: 300
  successfulJobsHistoryLimit: 7
  failedJobsHistoryLimit: 3
  jobTemplate:
    spec:
      template:
        metadata:
          labels:
            app: backup
            type: automated
        spec:
          containers:
          - name: backup
            image: alpine:latest
            resources:
              requests:
                memory: "256Mi"
                cpu: "250m"
              limits:
                memory: "512Mi"
                cpu: "500m"
            command:
            - /bin/sh
            - -c
            - |
              set -e
              echo "=== Backup started at $(date) ==="
              
              # Step 1: Create backup
              echo "Creating backup..."
              tar -czf /backup/backup-$(date +%Y%m%d).tar.gz /data
              
              # Step 2: Verify backup
              echo "Verifying backup..."
              tar -tzf /backup/backup-$(date +%Y%m%d).tar.gz > /dev/null
              
              # Step 3: Upload to remote storage (example)
              echo "Uploading to remote storage..."
              # aws s3 cp /backup/backup-$(date +%Y%m%d).tar.gz s3://my-bucket/
              
              # Step 4: Cleanup old backups
              echo "Cleaning up old backups..."
              find /backup -name "backup-*.tar.gz" -mtime +7 -delete
              
              echo "=== Backup completed successfully at $(date) ==="
            volumeMounts:
            - name: data
              mountPath: /data
              readOnly: true
            - name: backup
              mountPath: /backup
          restartPolicy: OnFailure
          volumes:
          - name: data
            persistentVolumeClaim:
              claimName: app-data-pvc
          - name: backup
            persistentVolumeClaim:
              claimName: backup-pvc
```

## Cleaning Up

Delete all resources created in this tutorial:

```bash
# Delete specific CronJob
kubectl delete cronjob hello-cronjob

# Delete all CronJobs in namespace
kubectl delete cronjobs --all

# Delete jobs created by CronJobs
kubectl delete jobs --all

# Delete using file
kubectl delete -f cronjob-hello.yaml
```

## Time Zone Considerations

**Important**: CronJobs use the time zone of the Kubernetes control plane (usually UTC).

To work with different time zones (requires Kubernetes 1.25+):

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: timezone-aware
spec:
  schedule: "0 9 * * *"  # 9 AM
  timeZone: "America/New_York"  # EST/EDT
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: task
            image: busybox
            command: ["date"]
          restartPolicy: OnFailure
```

## Next Steps

- Explore [Jobs101](../Jobs101/README.md) for one-time job execution
- Learn about [StatefulSets101](../StatefulSets101/README.md) for stateful applications
- Check [Secrets101](../Secrets101/README.md) for managing sensitive data

## Contributors

[Ajeet Singh Raina](https://twitter.com/ajeetsraina)
