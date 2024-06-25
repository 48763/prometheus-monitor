# Prometheus

Prometheus 是一個開源系統監控和警示的工具包。

Prometheus 在 2016 加入 **Cloud Native Computing Foundation**，成為其第二個託管的專案。

## 目錄

- [架構](#架構)
- [詞彙解釋](./glossary.md)
- [Prometheus](./docs)
    - [Server](./docs/server)
    - [Alertmanager](./docs/alertmanager)
    - [Pushgateway](./docs/pushgateway)
- [Exporters](https://github.com/48763/prom-client-ex)
- [Grafana](./docs/grafana)

## 前言

Prometheus 相關的服務啟用與配置，路徑都與服務名稱相對應：

```bash
$ git clone https://github.com/48763/prometheus-monitor.git
$ cd prometheus-monitor/deploy
$ tree
.
├── grafana
├── nginx
└── prometheus
    ├── alertmanager
    ├── pushgateway
    └── server
```

## 架構

![](images/introduction-01.png)

### 指標收集

Prometheus 服務器（*Server*）（圖的中間），它可以從 *Pushgateway* 或目標的 *Exporter* 拉取（pull）測量指標（圖的左邊）；對於目標本身，只需透過下列方式，就能讓服務器拉取：

- 安裝服務所需的 *exporter* ，就能將指標曝露給外部
- 或是撰寫腳本將指標推送（push）到 *Pushgateway*，使其收集和曝露

### 數據儲存

服務器會將收集的測量指標與時間序列，透過 *預寫式日誌（WAL, write-ahead-log）* 的方式，先保存在記憶體當中，而不會立即寫入到資料庫（levelDB）。預寫式日誌以 128MB 為一個分段，儲存在目錄 `wal` 下。預寫的檔案會以兩個小時一次，壓縮寫至到資料庫（TSDB）內。

### 觀察數據

想要觀看拉取的儲存測量指標數據時，有下面兩種方式（圖的右下）：

- 利用 Prometheus 服務器（*Server*）的原生介面，以 PromQL（Prometheus Query Language）查詢想要的資訊，系統也會呈現簡易的數據圖表
- 或是使用 *Grafana*，將 prometheus 作為資料來源加入，就可以任意製作儀表板呈現，以方便觀測目標主機的狀態

### 告警

最後，服務器（*Server*）上可以設置告警條件，只要使用 PromQL 查詢想要的指標或聚合的數據，再使用簡易的條件式（`>`, `<`, `=`, `!=`）設置閥值，例如：`up != 1`，當條件符合時，系統將會推送告警至指定的 *Altermanager*（圖的右上）。

Altermanager 收到告警後，會按照設置的 `route` 發送告警訊息至指定的 `receiver`（有通訊軟體或 webhook，如： slack），使相關的負責人員能收到告警訊息，以進行後續處理。
