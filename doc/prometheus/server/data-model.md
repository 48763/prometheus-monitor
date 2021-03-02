# 數據模型

*Prometheus* 從根本上將所有數據存儲為時間序列（time series） ：屬於同一個 *指標（metrics）* 時間戳值的數據流和相同的集合標籤維度。除了存儲的時間序列之外， *Prometheus* 還可以生成臨時導出的時間序列作為查詢的結果。

## 指標名稱和標籤

指標的名稱和鍵值對（也稱為標籤 - labels）的集合，在每一個時間序列都是唯一標識。

### 名稱

指標名稱指定被測量的系統一般特徵（例如， `http_requests_total` - 接收到的 *HTTP* 請求的總數）。它可以包含 *ASCII* 字母和數字，以及下劃線和冒號，即必須匹配正則表達式 `[a-zA-Z_:][a-zA-Z0-9_:]*`。

### 標籤

標籤啟用 *Prometheus* 的多維度數據模型：相同指標名稱給予任意的標籤組合，都能標示指標的特定維度實例（如：所有使用 `POST` 方法到 `/api/tracks` 處理程序的 *HTTP* 請求）。查詢語言允許基於這些維度進行篩选和聚合。更改任何標籤值（包括添加或刪除標籤）將創建新的時間序列。

標籤名稱可以包含 *ASCII* 字母，數字以及下劃線。它們必須匹配正則表達式 `[a-zA-Z_][a-zA-Z0-9_]*` 。以 `__` 開頭的標籤名稱保留供內部使用。

標籤值可能包含任何 *Unicode* 字符。

另請參閱命名指標和標籤的[最佳實踐](https://prometheus.io/docs/practices/naming/)。

## 樣本

樣本形成實際的時間序列數據。每個樣品包括：
- 一個 float64 值
- 一個毫秒精度的時間戳

## 符號

給定一個指標名稱和標籤組合，時間序列通常用這個標記來標識：

```
<metric name>{<label name>=<label value>, ...}
```

例如，指標名稱為 `api_http_requests_total`，以及標籤 `method="POST"` 和 `handler="/messages"` 的時間序列可以這樣寫：

```
api_http_requests_total{method="POST", handler="/messages"}
```

這與 OpenTSDB 使用的符號相同。
