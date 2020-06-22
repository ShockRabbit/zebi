#!/bin/sh

function install_process_mas() {
    local config_path=$1

    local mas=`cat $config_path | jq -r ".mas[]"`
    for app_name in $mas; do
        mas lucky $app_name
    done
}
