# Alertmanager

## Architecture
<img src="../../images/prometheus/prometheus-04.png" alt="prometheus" height="100%" width="100%">

## Table of contents
- [Installation](./#installation)
- [Config](/implement/prometheus/alertmanager/)

## Installation 
```bash
$ docker run -p 9093:9093 --name alertmanager \
    -v $(pwd)/alertmanager.yml:/etc/alertmanager/alertmanager.yml \
    -d prom/alertmanager
```

**Access web**
```
http://127.0.0.1:9093
```

<img src="../../images/prometheus/prometheus-03.png" alt="prometheus" height="100%" width="100%">
