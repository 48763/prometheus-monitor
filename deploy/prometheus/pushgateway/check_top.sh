#!/bin/bash
ps="$(ps -eo pid,%cpu,%mem,cmd --sort %cpu,%mem | tail -n 1)"

metrics="$(echo ${ps} \
     | awk '{
          printf "node_process_cpu_usage{pid=\"%s\", proc=\"%s\"} %s\\n", $1, $4, $2 
          printf "node_process_memory_usage{pid=\"%s\", proc=\"%s\"} %s\\n", $1, $4, $3
     }')"

echo -e ${metrics} | curl --data-binary @- "http://localhost/metrics/job/lab/instance/some_instance"
