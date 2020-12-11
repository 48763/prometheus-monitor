#!/bin/bash
while true
do
    metrics=""

    while read output
    do

        metrics="${metrics}$(echo ${output} | awk '{
            printf "node_process_cpu_usage{pid=\"%s\", process=\"%s\"} %s\\n",  $1, $4, $2
            printf "node_process_memory_usage{pid=\"%s\", process=\"%s\"} %s\\n",  $1, $4, $3
        }')"

    done < <(ps -eo pid,%cpu,%mem,cmd --sort %cpu | tail)

    echo -e ${metrics} | curl --data-binary @metrics http://192.168.0.1:9091/metrics/job/$(hostname)/ip/172.16.0.1

    sleep 5
done