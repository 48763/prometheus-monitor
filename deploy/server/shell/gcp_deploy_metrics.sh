#!/bin/sh
## set -x
ts=`TZ='Asia/Taipei' date "+%Y%m%d%H%M"`

get_distribution() {
    lsb_dist=""
    # Every system that we officially support has /etc/os-release
    if [ -r /etc/os-release ]; then
        lsb_dist="$(. /etc/os-release && echo "$ID")"
    fi
    # Returning an empty string here should be alright since the
    # case statements don't act unless you provide an actual value
    echo "$lsb_dist"
}

command_exists() {
    command -v "$@" > /dev/null 2>&1
}

docker_exporter() {

    if command_exists docker; then

        if [ ! -f /etc/docker/daemon.json ]; then
            $sh_c "echo { \
            } > /etc/docker/daemon.json"
        fi

        $sh_c "md5sum /etc/docker/daemon.json > /etc/docker/md5"
        $sh_c "mv /etc/docker/daemon.json /etc/docker/daemon.json.tmp"

        $sh_c "jq \". += {
            \\\"metrics-addr\\\" : \\\"$1:9400\\\",
            \\\"experimental\\\": true }\" \
            /etc/docker/daemon.json.tmp > /etc/docker/daemon.json"

        $sh_c "md5sum -c /etc/docker/md5 > /dev/null 2>&1"
        if [ 0 -ne $? ]; then

            echo "Restart..."

            $sh_c "systemctl restart docker"            
            if [ 0 -eq $? ]; then
                $sh_c "rm /etc/docker/daemon.json.tmp"
                $sh_c "docker start \$(docker ps -aq) > /dev/null 2>&1"
            else
                $sh_c "rm /etc/docker/daemon.json"
                $sh_c "mv /etc/docker/daemon.json.tmp /etc/docker/daemon.json"
                $sh_c "systemctl restart docker"
                $sh_c "docker start \$(docker ps -aq) > /dev/null 2>&1"
                echo "Docker configure failed, already restore daemon.json."
            fi
        else
            $sh_c "rm /etc/docker/daemon.json.tmp"
        fi

        $sh_c "rm /etc/docker/md5"
        echo "Docker done."
    fi
}

elasticsearch_exporter() {

    local WORKPATH="/usr/share/elasticsearch/bin/elasticsearch-plugin" 
    if [ -f $WORKPATH ]; then
        el_version=$(curl -s localhost:9200 | jq -r .version.number)
        $sh_c "$WORKPATH list | grep prometheus-exporter > /dev/null"
        if [ 0 -ne $? ] && [ -n $el_version ]; then
            echo "Install plugin..."
            $sh_c "$WORKPATH install -b \
                https://github.com/vvanholl/elasticsearch-prometheus-exporter/releases/download/$el_version.0/prometheus-exporter-$el_version.0.zip > /dev/null"
            $sh_c "systemctl restart elasticsearch"
        fi
    fi
}

main() {
    sh_c='sh -c'
    ## Set execute command prefix.
    if [ "$user" != 'root' ]; then
        if command_exists sudo; then
            sh_c='sudo -E sh -c'
        elif command_exists su; then
            sh_c='su -c'
        else
            cat >&2 <<-'EOF'
            Error: this installer needs the ability to run commands as root.
            We are unable to find either "sudo" or "su" available to make this happen.
			EOF
            exit 1
        fi
    fi

    ## Set linux distribution name
    lsb_dist=$(get_distribution)
    lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"

    ## Check linux version
    case "$lsb_dist" in

        ubuntu)
            if command_exists lsb_release; then
                dist_version="$(lsb_release --codename | cut -f2)"
            fi
            if [ -z "$dist_version" ] && [ -r /etc/lsb-release ]; then
                dist_version="$(. /etc/lsb-release && echo "$DISTRIB_CODENAME")"
            fi
        ;;

        centos)
            if [ -z "$dist_version" ] && [ -r /etc/os-release ]; then
                dist_version="$(. /etc/os-release && echo "$VERSION_ID")"
            fi
        ;;

    esac

    echo "Host's($1) system is $lsb_dist"

    ## Deploy
    case "$lsb_dist" in

        ubuntu)
            
            ## Depends
            dpkg -s jq > /dev/null 2>&1
            if [ 0 -ne $? ]; then
                echo "Install..."
                $sh_c "apt-get install -qq jq > /dev/null"
            fi
            echo "Depends done."

            ## Docker 
            docker_exporter $1

            ## Elasticsearch
            dpkg -s elasticsearch > /dev/null 2>&1
            if [ 0 -eq $? ]; then
                elasticsearch_exporter
                echo "Elasticsearch done."
            fi

            ## Prometheus
            dpkg -s prometheus-node-exporter > /dev/null 2>&1
            if [ 0 -ne $? ]; then
                echo "Install..."

                $sh_c "apt-get update -qq"
                $sh_c "apt-get install -qq prometheus-node-exporter > /dev/null"
            fi
            
            $sh_c "systemctl start prometheus-node-exporter"
            if [ 0 -eq $? ]; then
                echo "Prometheus done."
            else
                echo "Prometheus start failed."
            fi
        ;;

        centos)

            ## depends
            $sh_c "yum list installed jq -q > /dev/null 2>&1"
            if [ 0 -ne $? ]; then
                echo "Install..."
                $sh_c "yum install -y jq -q > /dev/null 2>&1"
            fi
            echo "Depends done."

            ## Docker
            docker_exporter $1

            ## Elasticsearch 
            $sh_c "yum list installed elasticsearch -q > /dev/null 2>&1"
            if [ 0 -eq $? ]; then
                elasticsearch_exporter
                echo "Elasticsearch done."
            fi

            ## Prometheus
            $sh_c "yum list node_exporter -q > /dev/null 2>&1"
            if ! command_exists node_exporter; then
                echo "Install..."
                $sh_c "curl -sLo /etc/yum.repos.d/prometheus-exporters.repo \
                    https://copr.fedorainfracloud.org/coprs/ibotty/prometheus-exporters/repo/epel-7/ibotty-prometheus-exporters-epel-7.repo"
                $sh_c "yum install -y node_exporter -q > /dev/null 2>&1"
                $sh_c "systemctl start node_exporter"
                $sh_c "systemctl enable node_exporter"
            fi

            $sh_c "systemctl start node_exporter"
            if [ 0 -eq $? ]; then
                echo "Prometheus done."
            else
                echo "Prometheus start failed."
            fi
        ;;

    esac

}

## Entrypoint
echo "$ts"
main $1
echo "" 
