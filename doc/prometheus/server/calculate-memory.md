# 計算記憶體用量



記憶體使用量的總和計算，分為兩個區塊，分別是[*記憶體基數*](#記憶體基數)和[*攝取記憶體*](#攝取記憶體)。

```
total = cardinality + ingest
```

## 記憶體基數（Cardinality Memory）

```
cardinality = (
    ts_num 
    * (732
        + avg_labels(ts) * 32
        + avg_labels(ts) * avg_labels_size * 2
        ) + 120 * unique_labels_num
    ) * 2 / 1024^2
```

### 時間序的數量

獲取 prometheus 一天內的所有時間序中，一次刮取（scrape）最多指標（metrics）的數量。使用下面所示的 PromQL，以獲取該資訊：

```
max_over_time(prometheus_tsdb_head_series[1d])
```

> ts_num

### 時間序的平均標籤（Average Labels Per Time Series）

> avg_labels(ts)

### 標籤對的平均字節

標籤對的平均字節（Average Bytes per Label Pair）

> avg_labels_size

### 不重複的標籤對數量

在所有刮取（scrape）的指標（metrics）中，

```
$ ./tsdb analyze /data/monitor/prometheus/ | head -n 6 -
Block ID: 01F44F81NATPRZC0E5T1WZQFZY
Duration: 2h0m0s
Series: 2031
Label names: 61
Postings (unique label pairs): 1217
Postings entries (total label pairs): 9876
```

> unique_labels_num

## 攝取記憶體


```
ingest = 
    ts_num(day)
    * sample_byte
    / scrape_interval
    * 3600 * 3 * 2 / 1024^2
```

### 樣本字節數

計算平均一個樣本所佔的字節數。使用下面所示的 PromQL，以獲取該資訊：

```
rate(prometheus_tsdb_compaction_chunk_size_bytes_sum[1d])
/ rate(prometheus_tsdb_compaction_chunk_samples_sum[1d])
```

> sample_byte

### 刮取間隔

查看 [`prometheus.yml`][scrape]，就能知道預設的刮取間隔：

```
global:
  scrape_interval:     15s
```

> scrape_interval

## 每秒樣本數

利用 [`ts_num`](#時間序的數量) 除以 [`scrape_interval`](#刮取間隔)，以獲取平均每秒傳輸（KB/s）的樣本大小：

```
sample_num(k/s) = 
    ts_num
    / scrape_interval 
    / 1000
```

> sample_num

### 

[scrape]: https://github.com/48763/prometheus-monitor/blob/master/deploy/prometheus/server/prometheus.yml#L3 "prometheus.yml"