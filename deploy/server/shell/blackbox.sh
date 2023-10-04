#!/bin/bash
pull_script_path="/data/script/tools/pull_domian.py"
prometheus_confs_path="/opt/prometheus/server/config/blackbox"
domains_stored_path="/opt/prometheus/server/config/url"

exec_pull_script() {
    cd ${pull_script_path%/*}
    ${pull_script_path}
    cd - &> /dev/null
}

type_map() {

    case ${1%-*} in
        # Return 1<module_name> 2<scheme> 3<redirect> 4<test_path>
        homepage)
            echo "${1#*-}_http_2xx https on"
        ;;
        api)
            echo "api_http_2xx https off /ping"
        ;;
        *)
            echo "http_2xx https off"
        ;;
    esac
}

f_echo() {
    echo "${1}" >> ${config_stored_path}
}

generate() {
    config_stored_path=${prometheus_confs_path}/next/${1}.yml

    f_echo "- labels:"
    f_echo "    module: ${2}"
    f_echo "    scheme: ${3}"
    f_echo "    redirect: ${4}"
    f_echo "    filename: ${1}.yml"
    f_echo "    env: ${1%-*}.yml"
    f_echo "    app: ${1#*-}.yml"

    f_echo "  targets:"
    while read line
    do
        f_echo "  - ${line}${5}"
    done < <(cat ${domains_stored_path}/${1})

    f_echo ""
}

iterate_domains() {
    rm ${domains_stored_path}/*
    exec_pull_script

    for f in $(ls -1 ${domains_stored_path})
    do
        mtype=$(type_map ${f})
        generate ${f} ${mtype}
    done
}

check_config() {

    docker exec prometheus promtool check config /etc/prometheus/config/${1} &> /dev/null
    if [ ${?} -eq 0 ]; then 
        true
    else
        false
    fi
}

check_container() {

    state=$(docker inspect prometheus -f '{{ .State.Running }}')
    if [ "${state}" = "true" ]; then 
        true
    else
        false
    fi
}

restart_container() {
    docker restart prometheus
}

update() {

    rm ${prometheus_confs_path}/next/*.yml &> /dev/null
    iterate_domains

    if check_config blackbox/next/next; then
        rm ${prometheus_confs_path}/prev/*.yml &> /dev/null
        mv ${prometheus_confs_path}/*.yml ${prometheus_confs_path}/prev/ &> /dev/null
        mv ${prometheus_confs_path}/next/*.yml ${prometheus_confs_path} &> /dev/null
    else
        echo "Generate Config Failed."
        exit 1
    fi

    if check_container; then
        echo "Done."
    else
        rollback
        restart_container
        echo "Update Failed."
    fi
}

rollback() {

    if check_config blackbox/prev/prev; then
        rm ${prometheus_confs_path}/*.yml &> /dev/null
        cp ${prometheus_confs_path}/prev/*.yml ${prometheus_confs_path}/ &> /dev/null
        echo "Done."
    else
        echo "RollBack Failed."
        exit 1
    fi
}

case ${1} in

    *)
        ${@}
    ;;

esac
