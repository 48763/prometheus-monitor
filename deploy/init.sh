#!/bin/sh
if [ ! ${#} -eq 0 ] && [ ! ${#} -eq 2 ]; then
    echo "Usage: ${0} [current_domain_name] [replace_domain_name]"
    exit 1
fi

if command -v command > /dev/null 2>&1; then
    CHECK_CMD="command -v"
elif which which > /dev/null 2>&1; then
    CHECK_CMD="which which"
else
    echo "Cannot find commnad nor which. Please install one."
    exit 1
fi

sh_c="sh -c"
## Set execute command prefix.
if [ "${user}" != "root" ]; then
    if ${CHECK_CMD} sudo; then
        sh_c="sudo -E sh -c"
    elif ${CHECK_CMD} su; then
        sh_c="su -c"
    else
        cat >&2 <<-'EOF'
        Error: this installer needs the ability to run commands as root.
        We are unable to find either "sudo" or "su" available to make this happen.
		EOF
        exit 1
    fi
fi

if ! ${CHECK_CMD} docker > /dev/null 2>&1; then 
    echo "Please install docker..."
    echo ""
elif ! ${CHECK_CMD} docker-compose > /dev/null 2>&1; then
    echo "Please install docker-compose..."
    echo ""
fi

WORKDIR=$(pwd)

## nginx
if [ ! -z ${2} ]; then 
    cd nginx/conf.d
    ${sh_c} 'sed -i 's/fans.io/chainss.io/g' *.conf'
    shift 2
    cd ${WORKDIR}
fi

${sh_c} "docker images" | grep -P 'nginx[[:space:]]*prom' > /dev/null 2>&1
if [ 1 -eq ${?} ]; then
    cd nginx
    ${sh_c} "docker build . -t nginx:prom"
    cd ${WORKDIR}
fi

## grafana
if [ ! "472" -eq "$(stat -c %u ./grafana/grafana.db)" ]; then
    ${sh_c} "chown 472:${USER} ./grafana/grafana.db"
fi

## monitor
if [ ! -e /data/monitor ]; then
    ${sh_c} "mkdir -p /data/monitor"
fi

## prometheus
if [ ! -e /data/monitor/prometheus ]; then
    ${sh_c} "mkdir /data/monitor/prometheus"
    ${sh_c} "chown 65534:65534 /data/monitor/prometheus"
elif [ "6553465534" -eq "$(stat -c %u%g /data/monitor/prometheus)" ]; then
    ${sh_c} "chown -R 65534:65534 /data/monitor/prometheus"
fi

## alertmanager
if [ ! -e /data/monitor/alertmanager ]; then
    ${sh_c} "mkdir /data/monitor/alertmanager"
    ${sh_c} "chown 65534:65534 /data/monitor/alertmanager"
elif [ "6553465534" -eq "$(stat -c %u%g /data/monitor/alertmanager)" ]; then
    ${sh_c} "chown -R 65534:65534 /data/monitor/alertmanager"
fi

## Change mode
${sh_c} "docker-compose up -d"
