# Grafana

## 運行

### 本機

```
wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_5.2.4_amd64.deb 
sudo dpkg -i grafana_5.2.4_amd64.deb 
```

### Docker

```
$ docker run -d --name grafana -p 3000:3000 grafana/grafana
```

## 配置環境變數

```
GF_<SectionName>_<KeyName>
```

### Docker 配置

```
$ docker run --name grafana\
    -p 3000:3000 \
    --name=grafana \
    -e "GF_SERVER_DOMAIN=http://monitor.yukifans.com" \
    -e "GF_SECURITY_ADMIN_PASSWORD=P@s2W0rD" \
    -d grafana/grafana
```

## Variable syntax

### Query

```
up{job="sit"}
```

### Regex

```
/.*instance="([^"]*).*/
```

## Password change

```
$ grafana-cli --config "/etc/configuration/" admin reset-admin-password mynewpassword
```

## 參考 

- [Grafana-cli-command-syntax](https://grafana.com/docs/grafana/latest/administration/cli/#grafana-cli-command-syntax)
- [Configuration](https://grafana.com/docs/grafana/latest/administration/configuration/)