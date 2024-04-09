# azure-metrics-exporter

[RobustPerception/azure-metrics-exporter](https://github.com/RobustPerception/azure_metrics_exporter?tab=readme-ov-file#azure-metrics-exporter)

## 快速運行

使用下面指令，利用 docker 運行 `azure-metrics-exporter`：

```
$ docker run --name azure-metrics-exporter \
    -v $(pwd)/azure.yml:/azure.yml \
    -p 9276:9276 \
    -d robustperception/azure_metrics_exporter \
```
