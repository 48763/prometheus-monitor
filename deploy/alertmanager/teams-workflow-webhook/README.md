# Teams-Workflow-Webhook

這是一個自製的簡易 workflow webhook 代理器，可以接受 alertmanager 的告警訊息，然後修改 payload，再重新發送至 workflow webhook。

## Alertmanager 的告警 payload

下面是 alertmanager 發送告警時，其 payload 的格式:

```
'{
    "@context": "http://schema.org/extensions",
    "type": "MessageCard",
    "title": "[FIRING:1] InstanceDown (OpenTelemetry OpenTelemetry:9100 main instance)",
    "summary": "[FIRING:1] InstanceDown (OpenTelemetry OpenTelemetry:9100 main instance)",
    "text": "\n\n# Alerts Firing:\n\nLabels:\n  - alertname = InstanceDown\n  - app = OpenTelemetry\n  - instance = OpenTelemetry:9100\n  - job = main\n  - severity = instance\n\nAnnotations:\n  - description = OpenTelemetry:9100 of job main has been down for more than 1 minutes.\n  -   summary = Instance OpenTelemetry:9100 down\n\down\n\nSource: http://local-prom.test.com/graph?g0.expr=up+%3D%3D+0&g0.tab=1\n\n\n\n\n",
    "themeColor": "8C1A1A"
}'
```

### 訪問 Workflow Webhook

直接訪問 workflow webhook，資料格式至少要像下面一樣:

```
curl -X POST <workflow-webhook-url> \
    -H 'Content-Type: application/json' \
    -d '{
        "type": "message",
        "attachments": [
            {
                "contentType": "application/vnd.microsoft.card.adaptive",
                "contentUrl": null,
                "content": {
                    "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                    "type": "AdaptiveCard",
                    "version": "1.2",
                    "body": [
                        {
                            "type": "TextBlock",
                            "text": "我是直接打 webhook 的訊息。"
                        }
                    ]
                }
            }
        ]
    }'
```


### 訪問自建的 Webhook

訪問自建的 webhook agent，然後帶上 alertmanager 的告警 payload:

```
curl -X POST localhost:8000 \
    -H 'Content-Type: application/json' \
    -d '{
        "@context": "http://schema.org/extensions",
        "type": "MessageCard",
        "title": "[FIRING:1] InstanceDown (OpenTelemetry OpenTelemetry:9100 main instance)",
        "summary": "[FIRING:1] InstanceDown (OpenTelemetry OpenTelemetry:9100 main instance)",
        "text": "\n\n# Alerts Firing:\n\nLabels:\n  - alertname = InstanceDown\n  - app = OpenTelemetry\n  - instance = OpenTelemetry:9100\n  - job = main\n  - severity = instance\n\nAnnotations:\n  - description = OpenTelemetry:9100 of job main has been down for more than 1 minutes.\n  -   summary = Instance OpenTelemetry:9100 down\n\nSource: http://local-prom.test.com:9090/graph?g0.expr=up+%3D%3D+0&g0.tab=1\n\n\n\n\n",
        "themeColor": "8C1A1A"
    }'
```
