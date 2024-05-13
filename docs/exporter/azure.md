# Azure

下列是關於 Azure 資源監控的方式：

- [Prometheus `azure_sd_config`](#prometheus-azure_sd_config)
- [webdevops/azure-metrics-exporter](#webdevopsazure-metrics-exporter)
- [RobustPerception/azure_metrics_exporter](#robustperceptionazure_metrics_exporter)
- [Grafana plugin](#grafana-plugin)
- [Grafana agent](#grafana-agent)


### Prometheus `azure_sd_config`

Prometheus 原生自帶的服務探索，但僅限於有安裝 `node-exporter` 的 VM。

### webdevops/azure-metrics-exporter

有持續在更新的第三方專案，透過 Azure sdk 獲取 Azure monitor 的指標，能使用 `resourcegraph` 進行資源過濾。

### RobustPerception/azure_metrics_exporter

已多年未更新的第三方專案，尚未研究測試。

### Grafana plugin

Grafana 原生自帶的插件，透過 api 直接存取 Azure monitor 數據，但需要考量請求費用問題。

### Grafana agent

Grafana 官方的 agent，其透過 [webdevops/azure-metrics-exporter](#webdevopsazure-metrics-exporter) 以獲取 Azure monitor 指標。
