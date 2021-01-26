# 記憶體計算

### fieldname2

時間序的數量（Number of Time Series）：
```
max_over_time(prometheus_tsdb_head_series[1d])
```

### fieldname3 

每個時間序的平均標籤（Average Labels Per Time Series）


### fieldname4 

唯一的標間對數量（Number of Unique Label Pairs）

### fieldname5

每個標籤對的平均字節（Average Bytes per Label Pair）

### fieldname9

記憶體基數（Cardinality Memory）

```
(fieldname2 * (732 + fieldname3 * 32 + fieldname3 * fieldname5 * 2) + 120 * fieldname4) * 2 / 1024 / 1024)
```

### fieldname7

抓取間隔（Scrape Interval(s)）

### fieldname8

樣本字節數（Bytes per Sample）

```
rate(prometheus_tsdb_compaction_chunk_size_bytes_sum[1d]) / rate(prometheus_tsdb_compaction_chunk_samples_sum[1d])
```

### fieldname13

每秒樣本數（Samples per Second）

(fieldname2 / fieldname7 / 1000)

### fieldname1

攝取記憶體（Ingestion Memory）

(fieldname2 * fieldname8 / fieldname7 * 3600 * 3 * 2 / 1024 / 1024)

### fieldname10

記憶體總和（Combined Memory）

(fieldname1 + fieldname9)
