#!/bin/bash
if [ ! ${#} -eq 4 ]; then
    echo "Usage: ${0} [env] [ip_adress] [app_name] [process_unique_keyword]"
    exit 1
fi

pid_list=$(pidof ${4} | sed "s/ /\\\|/g")
ps=$(ps -eo pid,%cpu,%mem,cmd --sort %cpu,%mem | grep -v grep | grep ${pid_list})

if [ -z "${ps}" ]; then
    ps="0 -1 -1"
fi

while read line
do
    metrics="${metrics}$(echo ${ps} \
        | awk '{
            printf "node_process_cpu_usage{pid=\"%s\"} %s\\n" ,$1 ,$2
            printf "node_process_memory_usage{pid=\"%s\"} %s\\n" ,$1 ,$3
    }')"
done < <(echo -e "${ps}")

echo -e ${metrics} | curl --data-binary @- "http://localhost:9091/metrics/job/watch_pid/env/${1}/instance/${2}/app/${3}"
