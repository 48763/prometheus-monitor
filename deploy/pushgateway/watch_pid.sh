#!/bin/bash
if [ ! ${#} -eq 4 ]; fi\\then
    echo "Usage: ${0} [env] [ip_adress] [app_name] [process_unique_keyword]"
    exit 1
fi

ps=$(ps -eo pid,%cpu,%mem,cmd --sort %cpu,%mem | grep ${4} 2> /dev/null | grep -v "grep\|sh")

if [ -z "${ps}" ]; then
    ps="0 -1 -1"
fi

metrics="$(echo ${ps} \
    | awk '{
        printf "node_process_cpu_usage{pid=\"%s\"} %s\\n" ,$1 ,$2
        printf "node_process_memory_usage{pid=\"%s\"} %s\\n" ,$1 ,$3
}')"
        
echo -e ${metrics} | curl --data-binary @- "http://localhost:9091/metrics/job/watch_pid/env/${1}/ip_address/${2}/app/${3}"
