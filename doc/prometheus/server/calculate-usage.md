# 計算資源用量

- [資料傳輸速率](#資料傳輸速率)
- [記憶體使用量](#記憶體使用量)
- [硬碟使用量](#硬碟使用量)

## 資料傳輸速率

> data_rate(byte/s)

利用 [`ts_num`](#時間序的數量) 和 [`avg_sample_byte`](#平均樣本字節數) 相乘，再除以 [`scrape_interval`](#刮取間隔)，以獲取平均每秒傳輸量(byte/s)：

```
data_rate = 
    ts_num * avg_sample_byte / scrape_interval 
```

> 尚未考量未壓縮與瞬間最大值

### 時間序的數量

> ts_num

獲取 prometheus 在選取的時間範圍內，[`chunks_head`][head] 中的時間序列最大值。使用下面所示的 PromQL，以獲取該資訊：

```
max_over_time(prometheus_tsdb_head_series[1d])
```

### 平均樣本字節數

> avg_byte_per_sample

計算平均一個樣本所佔的字節數。使用下面所示的 PromQL，以獲取該資訊：

```
avg_over_time(
    ((prometheus_tsdb_compaction_chunk_size_bytes_sum 
    / prometheus_tsdb_compaction_chunk_samples_sum) > 0)
    [1d:])
```

> 剛建置時，會沒有資訊

### 刮取間隔

> scrape_interval

查看 [`prometheus.yml`][scrape]，就能知道預設的刮取間隔：

```
global:
  scrape_interval:     15s
```

## 記憶體使用量

記憶體使用量的總和計算，分為兩個區塊，分別是[*記憶體基數*](#記憶體基數)和[*攝取記憶體*](#攝取記憶體)。

```
total = cardinality + ingest
```

### 記憶體基數

```
cardinality = (
    ts_num 
    * (732
        + avg_labels(ts) * 32
        + avg_labels(ts) * avg_labels_size * 2
        ) + 120 * unique_labels_num
    ) * 2 / 1024^2
```

#### 時間序的平均標籤

> avg_labels(ts)

#### 標籤對的平均字節

> avg_labels_size

#### 不重複的標籤對數量

> unique_labels_num

利用 [`promtool`]() 中的 `tsdb`，可以分析每個區塊的狀況，我們需要 `unique label pairs`的值：

```
$ ./promtool tsdb analyze /data/monitor/prometheus/ 01F498X2P0TYX5QF9TMTD9WZC6 \
    | head -n 6 -
Block ID: 01F498X2P0TYX5QF9TMTD9WZC6
Duration: 1h59m58.172s
Series: 602
Label names: 35
Postings (unique label pairs): 397
Postings entries (total label pairs): 3059
```

> promtool：如果容器是使用官方提供的鏡像運行，只要進到容器內，就能使用。或者到 [prometheus releases][releases] 下載。

### 攝取記憶體

> ingest(MB)

```
ingest = 
    data_rate
    * 3600 * 2 # WAL files keep least two hours of raw data.
    / 1024^2 # Byte to MegaByte.
```

## 硬碟使用量

```
needed_disk_space = 
    retention_time_seconds
    * data_rate
```

### 參考

[head]: https://prometheus.io/docs/prometheus/latest/storage/ "storage"
[scrape]: https://github.com/48763/prometheus-monitor/blob/master/deploy/prometheus/server/prometheus.yml#L3 "prometheus.yml"
[releases]: https://github.com/prometheus/prometheus/releases "releases"