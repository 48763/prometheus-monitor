# BlackBox

```
$ docker run --name blackbox_exporter \
    -p 9115:9115 \
    --restart always \
    -v $(pwd):/config \
    -d quay.io/prometheus/blackbox-exporter:latest \
        --config.file=/config/blackbox.yml
```
