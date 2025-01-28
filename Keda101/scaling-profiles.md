# Auto-scaling profiles

To get the best use of auto-scaling, proper scaling profiles need to be defined. This means that the scaling should only happen when the existing replicas cannot handle the load. This means that you need to know exactly when to start scaling up and when to scale down. There are several ways to get these metrics, but to be accurate, it's best to get the metric from the source that will be used for the actual scaling. In our case, since we will be querying prometheus we should use that to build our scaling profile.

If you have no idea what level of traffic you will be getting as a starting point, it's best to overprovision and have a static number of replicas handle the load. While this is going on, you need to start gathering metrics from prometheus so that you can begin auto-scaling at some point. The following section will focus on creating an automatic means of collecting these metrics.

## Gathering metrics from prometheus

We will create a single pod whose job is to poll the Prometheus endpoint and get metrics from it at a 5-minute interval. These metrics will then be written to a CSV file so that it can be retrieved and used to create a scaling profile. You could also alternatively create a CronJob that runs at 5-minute intervals and does the same function. Let's look at what the bash script will look like:

```bash
if [ ! -f /mnt/efs/metrics-application.csv ]; then echo "Timestamp,Value" > /mnt/efs/metrics-application.csv; fi; \
while true; do \
  result=$(curl -G 'http://kube-prometheus-prometheus.monitoring.svc.cluster.local:9090/api/v1/query' \
  --data-urlencode 'query=sum(rate(request_total{app="inc-prod-application", job="linkerd-proxy", authority=~"yourdomain.com|application.namespace.svc.cluster.local:8080"}[5m])) by (app)' | jq -r '.data.result[0].value[1]'); \
  echo "$(date --iso-8601=seconds),$result" >> /mnt/efs/metrics-application.csv
  sleep 300;  # Sleep for 5 minutes (300 seconds)
done
```