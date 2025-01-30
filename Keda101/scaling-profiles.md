# Auto-scaling profiles

To get the best use of auto-scaling, proper scaling profiles need to be defined. This means that the scaling should only happen when the existing replicas cannot handle the load. This means that you need to know exactly when to start scaling up and when to scale down. There are several ways to get these metrics, but to be accurate, it's best to get the metric from the source that will be used for the actual scaling. In our case, since we will be querying prometheus we should use that to build our scaling profile.

If you have no idea what level of traffic you will be getting as a starting point, it's best to overprovision and have a static number of replicas handle the load. While this is going on, you need to start gathering metrics from prometheus so that you can begin auto-scaling at some point. The following section will focus on creating an automatic means of collecting these metrics.

## Gathering metrics from prometheus

We will create a single pod whose job is to poll the Prometheus endpoint and get metrics from it at a 5-minute interval. These metrics will then be written to a CSV file so that it can be retrieved and used to create a scaling profile. You could also alternatively create a CronJob that runs at 5-minute intervals and does the same function. Let's look at what the bash script will look like:

```bash
if [ ! -f /mnt/efs/metrics-application.csv ]; then echo "Timestamp,Value" > /mnt/efs/metrics-application.csv; fi; \
while true; do \
  result=$(curl -G 'http://kube-prometheus-prometheus.monitoring.svc.cluster.local:9090/api/v1/query' \
  --data-urlencode 'query=sum(rate(request_total{app="your-application", job="linkerd-proxy", authority=~"yourdomain.com|application.namespace.svc.cluster.local:8080"}[5m])) by (app)' | jq -r '.data.result[0].value[1]'); \
  echo "$(date --iso-8601=seconds),$result" >> /mnt/efs/metrics-application.csv
  sleep 300;  # Sleep for 5 minutes (300 seconds)
done
```

Let's break down the above bash script. We first check if the csv already exists and if it doesn't we create it and add the headers. Next, we start a loop that runs every 5 minutes and performs a curl to the prometheus endpoint with this query:

```
sum(rate(request_total{app="your-application", job="linkerd-proxy", authority=~"yourdomain.com|application.namespace.svc.cluster.local:8080"}[5m])) by (app)
```

To break down this query, this calculates the per-second rate of increase for the request_total time series over the last 5 minutes. `request_total` is a custom metric provided by Linkerd that gives the total request count. We look at this count and compare it against time to get the rate of increase with the timespan being a sliding window of 5 minutes. We then filter the requests by specifying only the requests coming from our application, and captured by the linkerd proxy. Regarding requests, the `request_total` metric captures all requests, including the requests that come from health checks. Since we don't want this metric to be used for scaling, we want to filter those out and only scale based on user requests. This means logs from the internet-facing domain (yourdomain.com) and other applications talking to the module via Kubernetes DNS (application.namespace.svc.cluster.local:8080).

Once the query has run, we use `jq` to parse the result and get only the value (the request count) out of it. This value is then passed to the result variable which eventually gets written into a csv file.

Now that you have an idea of what the process is, let's take a look at the full deployment file:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: metrics-store-pvc
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: gp3
  resources:
    requests:
      storage: 5Gi

---

apiVersion: v1
kind: PersistentVolume
metadata:
  name: metrics-store-pv
spec:
  capacity:
    storage: 5Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: gp3
  csi:
    driver: efs.csi.aws.com
    volumeHandle: <file-system>::<access-point>

---

apiVersion: v1
kind: Pod
metadata:
  name: application-prometheus-query-pod
spec:
  containers:
  - name: prometheus-query
    image: curl-kubectl
    resources:
      requests:
        memory: "64Mi"
        cpu: "10m"
      limits:
        memory: "64Mi"
    command: 
      - /bin/sh
      - -c
      - |
        if [ ! -f /mnt/efs/metrics-application.csv ]; then echo "Timestamp,Value" > /mnt/efs/metrics-application.csv; fi; \
        while true; do \
          result=$(curl -G 'http://kube-prometheus-prometheus.monitoring.svc.cluster.local:9090/api/v1/query' \
          --data-urlencode 'query=sum(rate(request_total{app="your-application", job="linkerd-proxy", authority=~"yourdomain.com|application.namespace.svc.cluster.local:8080"}[5m])) by (app)' | jq -r '.data.result[0].value[1]'); \
          echo "$(date --iso-8601=seconds),$result" >> /mnt/efs/metrics-application.csv
          sleep 300;  # Sleep for 5 minutes (300 seconds)
        done
    volumeMounts:
    - name: efs-storage
      mountPath: /mnt/efs  # Mount path for EFS where the CSV will be written
  restartPolicy: Always  # Ensure that the pod will restart if it crashes or fails
  volumes:
  - name: efs-storage
    persistentVolumeClaim:
      claimName: metrics-store-pvc  # PVC for EFS storage
```