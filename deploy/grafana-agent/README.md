# grafana-agent

```
$ docker run -d \ 
    -e AGENT_MODE=flow \
    -v $(pwd)/config.river:/etc/agent/config.river \
    -v WAL_DATA_DIRECTORY:/etc/agent/data \
    -v CONFIG_FILE_PATH:/etc/agent/ \
    -p 12345:12345 \
    grafana/agent:v0.40.2 \
    run --server.http.listen-addr=0.0.0.0:12345 /etc/agent/config.river
```
