#/bin/bash
init() {
    if [ -e "config" ]; then
        source config
    fi
    
    check=$(get_subscriptions_json)
    
    if [ "[]" = "${check}" ]; then


        az login --service-principal \
        -t ${AZURE_TENANT_ID} \
        -u ${AZURE_CLIENT_ID} \
        -p ${AZURE_CLIENT_SECRET} &> /dev/null

        if [ $? -ne 0 ]; then
            echo "Failed to login"
            exit 1
        fi

    fi

    az extension list | jq -r .[].name | grep resource-graph &> /dev/null
    if [ 0 -ne ${?} ]; then
        az extension add --name resource-graph &> /dev/null
    fi
}

# (key) return value
get_json_val() {
    echo -e "${json}" | jq -r ".$@" 2> /dev/null
}

# (key, value)
set_json_val() {

    json=$(echo ${json} | jq ".${1} |= \"${2}\"" )
}

# (plan.sku_name)
set_server_plan() {

    case ${1} in
        b1|s1)
            core=1
            memory=1.75
        ;;
        b2|s2)
            core=2
            memory=3.50
        ;;
        b3|s3)
            core=4
            memory=7.00
        ;;
        p0v3)
            core=1
            memory=4
        ;;
        p1v3)
            core=2
            memory=8
        ;;
        p1mv3)
            core=2
            memory=16
        ;;
        p2v3)
            core=4
            memory=16
        ;;
        p2mv3)
            core=4
            memory=32
        ;;
        p3v3)
            core=8
            memory=32
        ;;
        p3mv3)
            core=8
            memory=64
        ;;
        p4mv3)
            core=16
            memory=128
        ;;
        p5mv3)
            core=32
            memory=256
        ;;
        p1v2)
            core=1
            memory=3.50
        ;;
        p2v2)
            core=2
            memory=7.00
        ;;
        p3v2)
            core=4
            memory=14.00
        ;;
        i1v2)
            core=2
            memory=8.00
        ;;
        i1mv2)
            core=2
            memory=16.00
        ;;
        i2v2)
            core=4
            memory=16.00
        ;;
        i2mv2)
            core=4
            memory=32.00
        ;;
        i3v2)
            core=8
            memory=32.00
        ;;
        i3mv2)
            core=8
            memory=64.00
        ;;
        i4v2)
            core=16
            memory=64.00
        ;;
        i4mv2)
            core=16
            memory=128.00
        ;;
        i5v2)
            core=32
            memory=128.00
        ;;
        i5mv2)
            core=32
            memory=256.00
        ;;
        i6v2)
            core=64
            memory=256.00
        ;;
        y1|d1)
            core=1
            memory=1
        ;;
        *)
            core=-1
            memory=-1
        ;;
    esac

    set_json_val memory ${memory}
    set_json_val cpu ${core}
}

# (app.kind)
set_app_type() {

    case ${1} in
        app)
            type="app"
        ;;
        app,linux,container)
            type="container"
        ;;
        functionapp,linux)
            type="function"
        ;;
        *)
            type="unknown"
        ;;
    esac

    set_json_val type ${type}
}

# () return json
get_subscriptions_json() {
    az account list 2> /dev/null
}

# (subscription) return json
get_plans_info_json() {
    az graph query --first 100 \
    --graph-query \
    "resources
        | where type == 'microsoft.web/serverfarms'
        | where subscriptionId == '${1}'
        | project name, subscriptionId, resourceGroup, sku, kind, tags
            , numberOfSites=properties.numberOfSites, status=properties.status" \
    | tr '[:upper:]' '[:lower:]'
}

# () return json
gen_plan_metrics() {

    # {
    #   "kind": "",
    #   "name": "",
    #   "numberOfSites": 0,
    #   "sku": {
    #     "capacity": 0,
    #     "family": "",
    #     "name": "",
    #     "size": "",
    #     "tier": "",
    #   },
    #   "status": "",
    #   "subscriptionId": "",
    #   "tags": {
    #     "createat": "",
    #     "createby": "",
    #     "product": ""
    #   }
    # }
    metrics=""

    metrics="${metrics}azure_web_serverfarms_node_number{
        resourceGroup=\"$(get_json_val resourcegroup)\", 
        resourceName=\"$(get_json_val name)\",
        subscriptionID=\"$(get_json_val subscriptionid)\", 
        product=\"$(get_json_val tags.product)\",
        env=\"$(get_json_val tags.env)\"
        } $(get_json_val sku.capacity)\n"

    metrics="${metrics}azure_web_serverfarms_cpu_cores{
        resourceGroup=\"$(get_json_val resourcegroup)\", 
        resourceName=\"$(get_json_val name)\",
        subscriptionID=\"$(get_json_val subscriptionid)\", 
        product=\"$(get_json_val tags.product)\",
        env=\"$(get_json_val tags.env)\"
        } $(get_json_val cpu)\n"

    metrics="${metrics}azure_web_serverfarms_memory_total_gigabyte{
        resourceGroup=\"$(get_json_val resourcegroup)\", 
        resourceName=\"$(get_json_val name)\",
        subscriptionID=\"$(get_json_val subscriptionid)\", 
        product=\"$(get_json_val tags.product)\",
        env=\"$(get_json_val tags.env)\"
        } $(get_json_val memory)\n"
    
    metrics="${metrics}azure_web_serverfarms_app_number{
        resourceGroup=\"$(get_json_val resourcegroup)\", 
        resourceName=\"$(get_json_val name)\",
        subscriptionID=\"$(get_json_val subscriptionid)\", 
        product=\"$(get_json_val tags.product)\",
        env=\"$(get_json_val tags.env)\"
        } $(get_json_val numberofsites)\n"

    echo ${metrics}

}

# (subscription) return json
get_sites_info_json() {
    az graph query --first 100 \
    --graph-query \
    "resources 
        | where type == 'microsoft.web/sites'
        | where subscriptionId == '${1}'
        | extend appServicePlan 
            = extract('serverfarms/([^/]+)', 1, tostring(properties.serverFarmId)) 
        | project name, resourceGroup, subscriptionId, appServicePlan, kind, tags"  \
    | tr '[:upper:]' '[:lower:]'
}

# () return json
gen_site_metrics() {

    #  {
    #   "appServicePlan": "",
    #   "kind": "",
    #   "name": "",
    #   "subscriptionId": "",
    #   "tags": {
    #     "product": ""
    #   }
    # }

    metrics="azure_web_sites_app_state{
        resourceGroup=\"$(get_json_val resourcegroup)\", 
        resourceName=\"$(get_json_val name)\",
        subscriptionID=\"$(get_json_val subscriptionid)\", 
        subjection=\"$(get_json_val appserviceplan)\", 
        product=\"$(get_json_val tags.product)\",
        env=\"$(get_json_val tags.env)\",
        type=\"$(get_json_val type)\"
        } 1\n"

    echo ${metrics}

}

post_metrics() {
    curl -fsSL -X POST -H "Host: push.test.com" --data-binary @log "http://4.190.9.45/metrics/job/azure-web-monitor-patch"
}

delete_metrics() {
    curl -fsSL -X DELETE -H "Host: push.test.com" "http://4.190.9.45/metrics/job/azure-web-monitor-patch"
}

main() {
    init
    subscriptions=$([ "${SUBSCRIBES}" ] && echo "${SUBSCRIBES}" || get_subscriptions_json | jq -r ".[].id")

    for subscription in ${subscriptions};
    do
        metrics=""

        plans=$(get_plans_info_json "${subscription}")

        count=$(echo ${plans} | jq -r .count)
        for i in $(seq 0 $(( ${count} - 1 )) );
        do

            json=$(echo ${plans} | jq -r .data.[${i}])

            set_server_plan $(get_json_val sku.name)

            metrics=${metrics}$(gen_plan_metrics) 
        done

        sites=$(get_sites_info_json "${subscription}")

        count=$(echo ${sites} | jq -r .count)
        for i in $(seq 0 $(( ${count} - 1 )) );
        do

            json=$(echo ${sites} | jq -r .data.[${i}])

            set_app_type $(get_json_val kind)

            metrics=${metrics}$(gen_site_metrics "${site}")

        done

        echo -e "${metrics}" | sort | tail +2
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
