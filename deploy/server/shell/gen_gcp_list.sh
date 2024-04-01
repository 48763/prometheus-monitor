#!/bin/sh
#set -x
ts="$(date "+%Y%m%d%H")"
PROJ=""
INFO_JSON=""
APP=""
APP_LIST="default elasticsearch docker extension"
CONFIG="/opt/prometheus/server/config/gcp/main.yml"
WORKPATH="/opt/prometheus/server/config/gcp"

set_job() {
    
    echo "
  - job_name: $PROJ-$1
    scrape_interval: $(get_minter)
    metrics_path: $(get_mpath)
    file_sd_configs:
    - refresh_interval: 1m
      files:
      - \"config/gcp/$PROJ/$1.yml\"" >> $CONFIG
}

get_minter () {
    if [ ! $APP = "elasticsearch" ]; then
        echo "10s"
    else
        echo "150s"
    fi
}

get_mpath () {
    if [ ! $APP = "elasticsearch" ]; then
        echo "/metrics"
    else
        echo "/_prometheus/metrics"
    fi
}

set_target() {
    
    APP=$2

    set_config "- targets:"
    set_config "  - $(get_json host).gcp.silkrode.com.tw:$1"
    set_config "  labels:"
    set_config "    ip_address_1: $(get_json ip1)"
    set_config "    cloud : gcp"

    if [ "$(get_json ip2)" != "null" ]; then
        set_config "    ip_address_2: $(get_json ip2)"
    fi

    set_config "    app: $APP"
}

set_config() {
    echo "$1" >> $PROJ/$APP.yml.tmp
}

set_json() {

    INFO_JSON=$(echo $output \
    | awk '{
        printf "{\n  \"host\":\"%s\"" ,$1
        printf ",\n  \"status\":\"%s\"" ,$3

        if ($2~"[0-9]+")
            n=split($2, ip, ",");
        else if ($2!~"[0-9]+") 
            n="";

        for (i = 0; ++i <= n;)
            printf ",\n  \"ip%d\":\"%s\"" ,i ,ip[i]

        printf "}"
    }')
}

get_json() {
    echo $INFO_JSON | jq -r ".$1"
}

test_net() {
    nc -z -w 1 $(get_json host).gcp.silkrode.com.tw $1
    echo $?
}

cat template.yml > prometheus.yml
cd $WORKPATH

for PROJ in `gcloud projects list --format="[no-heading](PROJECT_ID)"`
do

    if [ ! -e $PROJ ]; then
        mkdir $PROJ
    fi

    gcloud compute instances list --format="[no-heading](NAME,INTERNAL_IP,STATUS)" --project $PROJ \
        | grep -v ^gke \
        | while read output
    do
        set_json output
        echo $INFO_JSON

        set_target 9100 default

        if [ "$(get_json status)" = "TERMINATED" ]; then
            set_config "    node_status: off"
            set_config "    gcp_status: $(get_json status)\n"
        elif [ 0 -ne $(test_net 9100) ]; then
            set_config "    node_status: N/A"
            set_config "    gcp_status: $(get_json status)\n"
        else 
            set_config "    node_status: on"
            set_config "    gcp_status: $(get_json status)\n" 
            
            if [ 0 -eq $(test_net 9200) ]; then
                set_target 9200 elasticsearch
                set_config ""
            fi

            if [ 0 -eq $(test_net 9400) ]; then
                set_target 9400 docker
                set_config ""
            fi

            if [ 0 -eq $(test_net 9500) ]; then
                set_target 9500 extension
                set_config ""
            fi
        fi

    done

    ## Add job config
    for i in $APP_LIST
    do
        if [ -e $PROJ/$i.yml.tmp ]; then
            mv $PROJ/$i.yml.tmp $PROJ/$i.yml
            APP=$i
            set_job $i
        fi
    done
    
done
