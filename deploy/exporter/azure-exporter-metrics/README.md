# azure-metrics-exporter

[azure-metrics-exporter](https://github.com/webdevops/azure-metrics-exporter?tab=readme-ov-file#azure-monitor-metrics-exporter)

## 快速運行

```
$ docker run --name azure-exporter \
    --env-files .config \
    -p 8080:8080 \
    -d 48763/azure-metrics-exporter
```

> 
> 如果想要自己創建鏡像，請運行下面指令：
> 
> ```
> $ git clone https://github.com/webdevops/azure-metrics-exporter.git
> $ cd azure-metrics-exporter
> $ docker build -t azure-metrics-exporter .
> ```
>

## HTTP Endpoints

下列所列出的請求路徑，僅描述重要或差異的部分，在請求 Azure 指標時，都必須配置 `subscription`，以及要請求的 `metric` 名稱。

| Endpoint | Description |
| - | - |
| `/metrics`                     | 預設的 golang 指標路徑 |
| `/probe/metrics`               | 基於 `resourceType`，獲取想要的指標 |
| `/probe/metrics/resource`      | 基於 `target`，對指定的目標，獲取想要的指標 |
| `/probe/metrics/list`          | 基於 `resourceType` 或 `filter`，獲取想要的指標 |
| `/probe/metrics/scrape`        | 基於 `resourceType` 或 `filter`，以及 `metricTagName` 和 `aggregationTagName`，獲取想要的指標 |
| `/probe/metrics/resourcegraph` | 功能與 `/probe/metrics` 雷同，但使用 Azure ResoruceGraph API 進行服務探索 |

### Prometheus 配置

下面以 `/probe/metrics` 為範例：

```
- job_name: azure-metrics-redis
  scrape_interval: 1m
  metrics_path: /probe/metrics/resource
  params:
    [ name: ["<String>"] | default = ["azurerm_resource_metric"] ]

    [ template: ["<String>"] | default = ["{name}"] ]

    [ help: ]

    # Azure Subscription ID                                                                                                                                
    subscription:
      [ - <String> ... ]

    [ region:
      [ - <String> ... ] ]

    [ timespan: ["<Timespan>"] | default = ["PT1M"] ]

    [ interval: ["<Timespan>"] ]

    resourceType: [ ["<String>"] ]

    [ metricNamespace: ]

    [ metric:
      [ - Metricname ... ] ]

    [ aggregation:
      [ - Aggregation ... ]  ]

    [ metricFilter: ]

    [ metricTop: ]

    [ metricOrderBy: ]

    [ validateDimensions: ]

    [ cache: ]

  static_configs:
  - targets: ["azure-metrics:8080"]
```

> 實際細節請查閱[文件](https://github.com/webdevops/azure-metrics-exporter/blob/main/README.md#http-endpoints)



azure_vm_available_memory_bytes_average_bytes