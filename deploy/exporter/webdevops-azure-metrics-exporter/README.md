# webdevops/azure-metrics-exporter

[webdevops/azure-metrics-exporter](https://github.com/webdevops/azure-metrics-exporter?tab=readme-ov-file#azure-monitor-metrics-exporter)

## 快速運行

使用下面指令，利用 docker 運行 `azure-metrics-exporter`：

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
    # Prometheus metric name
    [ name: ["<String>"] | default = ["azurerm_resource_metric"] ]

    # See template format in 
    # https://github.com/webdevops/azure-metrics-exporter/tree/main?tab=readme-ov-file#metric-name-and-help-template-system
    [ template: ["<String>"] | default = ["{name}"] ]

    # See help format in 
    # https://github.com/webdevops/azure-metrics-exporter/tree/main?tab=readme-ov-file#metric-name-and-help-template-system
    [ help: ]

    # Azure Subscription ID                                                                                                                                
    subscription:
      [ - <String> ... ]

    # Azure Regions (eg. `westeurope`, `northeurope`). 
    # If omit, ResourceGrapth will be used to discover regions.
    [ region:
      [ - <String> ... ] ]

    # Metric timespan
    [ timespan: ["<Timespan>"] | default = ["PT1M"] ]

    # Metric timespan
    [ interval: ["<Timespan>"] ]

    # Azure Resource type
    # See resourceType in 
    # https://learn.microsoft.com/en-us/azure/azure-monitor/reference/supported-metrics/metrics-index#supported-metrics-and-log-categories-by-resource-type
    resourceType: [ ["<String>"] ]

    # Metric namespace
    [ metricNamespace: ]

    # Metric name is name in REST API.
    # See metricname in 
    # https://learn.microsoft.com/en-us/azure/azure-monitor/reference/supported-metrics/metrics-index#supported-metrics-and-log-categories-by-resource-type
    [ metric:
      [ - Metricname ... ] ]

    # Metric aggregation (`minimum`, `maximum`, `average`, 
    #   `total`, `count`, multiple possible separated with `,`)
    [ aggregation:
      [ - Aggregation ... ]  ]

    # Prometheus metric filter (dimension support; 
    #   supports only 2 filters in subscription query mode 
    #   as the first filter is used to split by resource id)
    [ metricFilter: ]

    # Prometheus metric dimension count (dimension support)
    [ metricTop: ]

    # Prometheus metric order by (dimension support)
    [ metricOrderBy: ]

    # When set to false, invalid filter parameter values will be ignored.
    [ validateDimensions: ]

    # Use of internal metrics caching.
    [ cache: ]

  static_configs:
  - targets: ["azure-metrics:8080"]
```

> 實際細節請查閱[文件](https://github.com/webdevops/azure-metrics-exporter/blob/main/README.md#http-endpoints)

> Prometheus 的[配置範例](../../server/config/azure/exporter-metrics.yml)
