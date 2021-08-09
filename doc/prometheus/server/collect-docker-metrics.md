# Docker 指標

## 配置 Docker

配置 *Docker daemon*，讓服務曝露觀測指標，你需要指定 `metrics-address`。

> 如果不存在該檔案，請自行生成；檔案不為空時，只要新增下面兩個鍵值，以確保生成正確的 JSON。注意除了最後一行以外，每行都以逗號（`,`）結尾。

### Linux

```bash
$ vi /etc/docker/daemon.json
{
  "metrics-addr" : "192.168.0.1:9100",
  "experimental" : true
}
```

### Mac

在工具欄中點擊 Docker 圖示，選擇 `Preferences`，再選擇 `Daemon`，最後點擊 `Advanced`。

```json
{
  "metrics-addr" : "127.0.0.1:9100",
  "experimental" : true
}
```

### Windows 

檔案路徑：

```
C:\ProgramData\docker\config\daemon.json
```

## Prometheus 配置

在 `prometheus.yml` 裡面的 `scrape_configs` 下添加該配置即可。

```bash
$ vi prometheus.yml
scrape_configs:
- job_name: 'docker'

    static_configs:
    - targets: [‘192.168.200.134:9100’]
```
