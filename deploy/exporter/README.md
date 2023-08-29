# Exporter


## Blackbox

```bash
$ docker run \
    -p 9115:9115 \
    --name blackbox_exporter \
    -v $(pwd)/blackbox:/config \
    -d quay.io/prometheus/blackbox-exporter:latest \
        --config.file=/config/blackbox.yml
```