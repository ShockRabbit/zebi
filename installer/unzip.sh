#!/bin/sh

#source ../util.sh

function install_process_unzip() {
    local config_path=$1

    echo_title "Install Process unzip"

    # mkdir and unzip
    local src_paths=`cat $config_path | jq -r ".unzip | .[].src_path"`
    for s in $src_paths; do
        local dest_path=`cat $config_path | jq -r ".unzip | .[] | select(.src_path==\"${s}\") | .dest_path"`
        log "unzip ${s} to ${dest_path}"
        mkdir -p $(eval echo $dest_path)
        unzip $(eval echo $s) -d $(eval echo $dest_path)
    done
}

#install_process_unzip ../config.json
