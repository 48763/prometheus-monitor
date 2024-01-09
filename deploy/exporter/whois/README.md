# Whois

使用 [domain_exporter](https://github.com/caarlos0/domain_exporter) 協助查詢域名的剩餘有效天數。

> 因為行為與 `whois` 一樣，故這樣取名。

## 運行

```
$ docker run --name whois \
    -p 9222:9222 \
    caarlos0/domain_exporter
```

## 測試

```
$ curl localhost:9222/probe\?target=google.com
```

> 域名只能使用一級域名，如： `yayuyo.yt`。
