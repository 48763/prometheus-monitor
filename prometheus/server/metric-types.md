# 指標（metrics）類型

*Prometheus* 的客戶端函式庫提供四種核心指標。目前這些功能僅在客戶端函式庫（使 API 能量身定制以使用特定類型）和有線協議（wire protocol）中有所不同。*Prometheus* 服務端尚未使用指標類型資訊，而是將所有數據展開成無類型的時間序列。這在未來可能會有所改變。

## 計數器（Counter）

**計數器**是一個**累計指標**，意味著它單一且單調的累加計數器，其值只能增加或重新啟動時重置為零。**計數器**通常使用來計數服務的請求、完成的任務、發生的錯誤等等。

> 計數器不應該被用來顯示其數目也可以減少的項目的當前計數，如：當前正在運行的進程的數量，這個用例適合使用[**測量儀**](#測量儀gauge)。

**計數器**的客戶端函式庫使用文檔：
- [Go](https://godoc.org/github.com/prometheus/client_golang/prometheus#Counter)
- [Java](https://github.com/prometheus/client_java#counter)
- [Python](https://github.com/prometheus/client_python#counter)
- [Ruby](https://github.com/prometheus/client_ruby#counter)

## 測量儀（Gauge）

**測量儀**代表一個可以任意上下的單個數值。**測量儀**通常用於測量值，如：溫度或當前的內存使用情況，但也可以上下計數，如正在運行的進程的數量。

**測量儀**的客戶端函式庫使用文檔：
- [Go](https://godoc.org/github.com/prometheus/client_golang/prometheus#Gauge)
- [Java](https://github.com/prometheus/client_java#gauge)
- [Python](https://github.com/prometheus/client_python#gauge)
- [Ruby](https://github.com/prometheus/client_ruby#gauge)

## 直方圖（Histogram）

**直方圖**對觀察結果進行採樣（通常是請求持續時間或響應大小），並將其計入可配置的**貯體（buckets）** 中。它也提供了所有觀測值的總和。

指標名稱為` <basename>` 的直方圖在收集期間公開多個時間序列：
- 觀察貯體的累計計數器顯示為 `<basename>_bucket {le="<upper inclusive bound>"}`
- 所有觀察值的總和，輸出為 `<basename>_sum`
- 觀察的是建數，輸出為 `<basename>_count`（與之相同 `<basename>_bucket{le="+Inf"}`）

使用 `histogram_quantile()` 函數可以根據直方圖或直方圖的聚合來計算分位數。直方圖也適合計算 [Apdex](https://en.wikipedia.org/wiki/Apdex) 得分。在貯體操作時，請記住直方圖是累積的。有關直方圖使用和差異的介紹，請參見[直方圖和介紹](https://prometheus.io/docs/practices/histograms)。

**直方圖**的客戶端函式庫使用文檔：
- [Go](https://godoc.org/github.com/prometheus/client_golang/prometheus#Histogram)
- [Java](https://github.com/prometheus/client_java#histogram)
- [Python](https://github.com/prometheus/client_python#histogram)
- [Ruby](https://github.com/prometheus/client_ruby#histogram)

## 摘要（Summary）

類似*直方圖*，摘要會取樣觀察結果（通常是請求間隔和回應大小）。同時它還提供了觀測值的總數和所有觀測值的總和。在可配置的時間內計算分位數。

指標名稱為 `<basename>` 的摘要，顯示抓取間隔的多個時間序列：

- 觀察事件的串流 *φ-分位數*（0≤φ≤1），顯示為 `<basename> {quantile ="<φ>"}`
- 所有觀察值的*總和（sum）*，顯示為 `<basename>_sum`
- 已觀察的事件*計數（count）*，顯示為 `<basename>_count`

有關 φ-分位數、摘要使用與直方圖差異的詳細說明，參見[直方圖和摘要](https://prometheus.io/docs/practices/histograms)。

**摘要**的客戶端函式庫使用文檔：

- [Go](https://godoc.org/github.com/prometheus/client_golang/prometheus#Summary)
- [Java](https://github.com/prometheus/client_java#summary)
- [Python](https://github.com/prometheus/client_python#summary)
- [Ruby](https://github.com/prometheus/client_ruby#summary)