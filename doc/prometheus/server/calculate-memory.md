# 計算記憶體用量

記憶體計算分為兩個區塊，分別是[*記憶體基數*](#記憶體基數)和[*攝取記憶體*](#攝取記憶體)。

## 記憶體基數

Cardinality Memory

> cardinality

```
(ts_num * (732 + avg_labels(ts) * 32 + 
    avg_labels(ts) * avg_labels_size * 2) +
    120 * unique_labels_num) * 2 / 1024^2
```

> [`cardinality`](#記憶體基數) = ([`ts_num`](#) * 
>
> (732 + [`avg_labels`](#時間序的平均標籤)(ts) * 32 + [`avg_labels`](#時間序的平均標籤)(ts) * [`avg_labels_size`](#標籤對的平均字節) * 2)
>
> \+ 120 * [`unique_labels_num`](#唯一的標籤對數量)) * 2 / 1024^2

## 攝取記憶體

Ingestion Memory

> ingest

```
ts_num(day) * sample_byte / scrape_interval * 3600 * 3 * 2 / 1024^2
```

#### 樣本字節數（Bytes per Sample）

> sample_byte

```
rate(prometheus_tsdb_compaction_chunk_size_bytes_sum[1d])
/ rate(prometheus_tsdb_compaction_chunk_samples_sum[1d])
```

#### 抓取間隔（Scrape Interval(s)）

> scrape_interval

## 每秒樣本數（Samples per Second）

> sample_num(k/s)

```
ts_num / scrape_interval / 1000
```

### 記憶體基數（Cardinality Memory）

> cardinality

```
(ts_num * (732 + avg_labels(ts) * 32 + 
    avg_labels(ts) * avg_labels_size * 2) +
    120 * unique_labels_num) * 2 / 1024^2
```

#### 時間序的數量（Number of Time Series）

> ts_num

```
max_over_time(prometheus_tsdb_head_series[1d])
```

#### 時間序的平均標籤

> Average Labels Per Time Series
>
> avg_labels(ts)

#### 標籤對的平均字節

> Average Bytes per Label Pair）
>
> avg_labels_size

#### 唯一的標籤對數量

> Number of Unique Label Pairs
>
> unique_labels_num

## 記憶體總和（Combined Memory）

```
ingest + cardinality
```