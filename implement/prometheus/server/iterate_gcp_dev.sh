#!/bin/sh
## set -x
ts=`TZ='Asia/Taipei' date "+%Y%m%d%H%M"`

for proj in `gcloud projects list --format="[no-heading](PROJECT_ID)"`
do

    gcloud compute instances list --format="[no-heading](NAME,INTERNAL_IP,STATUS)" --project $proj \
        | grep -v ^gke > list.tmp

    cat list.tmp | while read output
    do
        HOST=$(echo $output | awk '{ print $1".gcp.silkrode.com.tw" }')
        IP=$(echo $output | awk '{ print $2 }')
        STATUS=$(echo $output | awk '{ print $3 }')

        if [ "$STATUS" = "TERMINATED" ]; then
            echo "$HOST($IP) TERMINATED."
            continue
        fi

        nc -z -w 1 $IP 22 > /dev/null 2>&1
        if [ 0 -eq $? ]; then
            ssh $IP "
                curl -s 192.168.0.1 -m 1 -o dev.sh
                if [ 0 -eq \$? ]; then
                    sh dev.sh $IP
                    rm dev.sh
                else
                    echo \"$HOST($IP) can't got script.\\n\"
                fi
            " < /dev/null >> dev.log 2>/dev/null
            echo "$HOST($IP) connection."
        else 
            echo "$HOST($IP) can't arrived."
        fi

    done

    rm list.tmp

done
