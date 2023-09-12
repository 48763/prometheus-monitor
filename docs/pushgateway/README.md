# Pushgateway


## Delete metrics

```bash
# Delete all metrics from same group.
$ curl -X DELETE http://pushgateway.example.org:9091/metrics/job/<job_name>
# Delete all metrics under the job.
$ curl -X DELETE http://pushgateway.example.org:9091/metrics/job/<job_name>/instance/<instance_name>
```