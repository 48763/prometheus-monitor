#!/bin/bash
init() {
    if [ -e "config" ]; then
        source config
    fi

    if [ "" = "${AC_LIST}" ]; then
        echo "AC_LIST is empty."
        exit 1
    fi

}

# (key) return value
get_json_val() {
    echo "${json}" | jq  ".$@" #2> /dev/null
}

# (key, value)
set_json_val() {
    json=$(echo ${json} | jq ".${1} |= \"${2}\"" )
}

get_stats_overview_json() {
    curl -X GET -s "https://api.sendgrid.com/v3/stats?start_date=$(date +"%Y-%m-%d")&aggregated_by=day" \
        --header "Authorization: Bearer ${!1}" \
        | jq .

}

# (id, key) return json
gen_stats_metrics() {

    metrics="sendgrid_daily_${2}{
        account_id=\"${1}\"
        } $(get_json_val ${2})\n"

    echo ${metrics}
}

post_metrics() {
    curl -fsSLk -X POST -H "Host: ${HOST}" --data-binary @metrics.log "${PUSHGATEWAY}/metrics/job/sendgrid"
}

delete_metrics() {
    curl -fsSLk -X DELETE -H "Host: ${HOST}" "${PUSHGATEWAY}/metrics/job/sendgrid"
}

main() {
    init
    :> metrics.log

    for ac in ${AC_LIST};
    do
        metrics=""

        json=$(get_stats_overview_json ${ac} | jq -r ".[0].stats.[0].metrics")

        keys=$(echo ${json} | jq -r ". | keys | .[]" )
        for key in ${keys};
        do
            metrics=${metrics}$(gen_stats_metrics "${ac}" "${key}")
        done

        echo -e "${metrics}" | sort >> metrics.log
    done
}

if [ -e "/tmp/${0##*/}" ]; then
    pid=$(cat /tmp/${0##*/})

    ps | grep -v grep | grep ${pid} &> /dev/null

    if [ 0 -eq ${?} ]; then
        exit 0
    fi

fi 

echo $$ > /tmp/${0##*/}

case ${1} in 
    gen)
        main
        delete_metrics
        post_metrics
    ;;
    *)
        $@
    ;;
esac

rm /tmp/${0##*/}
