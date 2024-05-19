#/bin/bash
init() {
    check=$(get_subscriptions_json)
    
    if [ "[]" = "${check}" ]; then

        if [ -e "secret" ]; then
            source secret
        fi

        az login --service-principal \
        -t ${AZURE_TENANT_ID} \
        -u ${AZURE_CLIENT_ID} \
        -p ${AZURE_CLIENT_SECRET} 2> /dev/null

        if [ $? -ne 0 ]; then
            echo "Failed to login"
            exit 1
        fi

    fi

    az extension add --name resource-graph &> /dev/null
}

get_json_val() {
    echo -e "${json}" | jq -r ".$@" 2> /dev/null
}

set_json_val() {
    echo ${json} | jq ".$@"
}

# (sku_name) return json
set_app_service_plan() {
    # ${1} = sku.name

    case ${1} in
        B1,S1)
            core=1
            memory=1.75
        ;;
        B2,S2)
            core=2
            memory=3.50
        ;;
        B3,S3)
            core=4
            memory=7.00
        ;;
        P0v3)
            core=1
            memory=4
        ;;
        P1v3)
            core=2
            memory=8
        ;;
        P1mv3)
            core=2
            memory=16
        ;;
        P2v3)
            core=4
            memory=16
        ;;
        P2mv3)
            core=4
            memory=32
        ;;
        P3v3)
            core=8
            memory=32
        ;;
        P3mv3)
            core=8
            memory=64
        ;;
        P4mv3)
            core=16
            memory=128
        ;;
        P5mv3)
            core=32
            memory=256
        ;;
        P1v2)
            core=1
            memory=3.50
        ;;
        P2v2)
            core=2
            memory=7.00
        ;;
        P3v2)
            core=4
            memory=14.00
        ;;
        I1v2)
            core=2
            memory=8.00
        ;;
        I1mv2)
            core=2
            memory=16.00
        ;;
        I2v2)
            core=4
            memory=16.00
        ;;
        I2mv2)
            core=4
            memory=32.00
        ;;
        I3v2)
            core=8
            memory=32.00
        ;;
        I3mv2)
            core=8
            memory=64.00
        ;;
        I4v2)
            core=16
            memory=64.00
        ;;
        I4mv2)
            core=16
            memory=128.00
        ;;
        I5v2)
            core=32
            memory=128.00
        ;;
        I5mv2)
            core=32
            memory=256.00
        ;;
        I6v2)
            core=64
            memory=256.00
        ;;
        Y1,D1)
            core=0
            memory=0
        ;;
        *)
            core=-1
            memory=-1
        ;;
    esac
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
        | where subscriptionId == '$1'
        | project name, subscriptionId, resourceGroup, sku, kind, tags
            , numberOfSites=properties.numberOfSites, status=properties.status"
}

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

gen_plan_metrics() {
    json=${1}

    metrics="azure_web_serverfarms_info{
        resourceGroup=\"$(get_json_val resourceGroup)\", 
        resourceName=\"$(get_json_val name)\",
        subscriptionName=\"$(get_json_val subscriptionId)\", 
        product=\"$(get_json_val tags.product)\",
        env=\"$(get_json_val tags.env)\"
        } 1\n"

    metrics="${metrics}azure_web_serverfarms_node_number{
        resourceGroup=\"$(get_json_val resourceGroup)\", 
        resourceName=\"$(get_json_val name)\",
        subscriptionName=\"$(get_json_val subscriptionId)\", 
        product=\"$(get_json_val tags.product)\",
        env=\"$(get_json_val tags.env)\"
        } $(get_json_val sku.capacity)\n"
    
    metrics="${metrics}azure_web_serverfarms_app_number{
        resourceGroup=\"$(get_json_val resourceGroup)\", 
        resourceName=\"$(get_json_val name)\",
        subscriptionName=\"$(get_json_val subscriptionId)\", 
        product=\"$(get_json_val tags.product)\",
        env=\"$(get_json_val tags.env)\"
        } $(get_json_val numberOfSites)\n"

    echo -e ${metrics}

}

#  {
#   "appServicePlan": "",
#   "kind": "",
#   "name": "",
#   "subscriptionId": "",
#   "tags": {
#     "product": ""
#   }
# }

gen_site_metrics() {

    json=${1}

    metrics="azure_web_sites_app_state{
        resourceGroup=\"$(get_json_val resourceGroup)\", 
        resourceName=\"$(get_json_val name)\",
        subscriptionName=\"$(get_json_val subscriptionId)\", 
        subjection=\"$(get_json_val appServicePlan)\", 
        product=\"$(get_json_val tags.product)\",
        env=\"$(get_json_val tags.env)\"
        } 1\n"

    echo -e ${metrics}

}

# (subscription) return json
get_sites_info_json() {
    az graph query --first 100 \
    --graph-query \
    "resources 
        | where type == 'microsoft.web/sites'
        | where subscriptionId == '$1'
        | extend appServicePlan 
            = extract('serverfarms/([^/]+)', 1, tostring(properties.serverFarmId)) 
        | project name, subscriptionId, appServicePlan, kind, tags"
}

main() {
    init

    subscriptions=$(get_subscriptions_json)

    while read subscription; 
    do

        echo "- ${subscription}: "

        plans=$(get_plans_info_json "${subscription}")
        # jq -r ".data.[] | .name, .subscriptionId, .sku.name, .kind, .tags, .numberOfSites, .status")

        count=$(echo ${plans} | jq -r .count)

        for i in $(seq 0 $(( ${count} - 1 )) );
        do
            plan=$(echo ${plans} | jq -r .data.[${i}])
            # name=$(echo ${plan} | jq -r .)
            echo "Plan ${i}: $name"

            gen_plan_metrics "${plan}"
        done

        sites=$(get_sites_info_json "${subscription}")
        # jq -r ".data.[] | .name, .subscriptionId, .appServicePlan, .kind, .tags"

        count=$(echo ${sites} | jq -r .count)

        for i in $(seq 0 $(( ${count} - 1 )) );
        do
            site=$(echo ${sites} | jq -r .data.[${i}])
            # name=$(echo ${site} | jq -r .)
            echo "site ${i}: $name"

            gen_site_metrics "${site}"
        done

        echo ""
        break

    done < <(echo ${subscriptions} | jq -r .[].id)
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
    ;;
    *)
        $@
    ;;
esac

rm /tmp/${0##*/}