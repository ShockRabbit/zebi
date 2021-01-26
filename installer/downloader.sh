#!/bin/sh

#source ../util.sh

function install_process_downloader() {
    local config_path=$1

    echo_title "Install Process downloader"

    # download by curl
    local urls=`cat $config_path | jq -r ".downloader | .[].url"`
    for u in $urls; do
        local dest_path=`cat $config_path | jq -r ".downloader | .[] | select(.url==\"${u}\") | .dest_path"`
        local use_redirect=`cat $config_path | jq -r "if .downloader | .[] | select(.url==\"${u}\") | .use_redirect then 1 else 0 end"`
        log "Download(use redirect: ${use_redirect}) from ${u} to ${dest_path}"
        if [ $use_redirect -eq 1 ]; then
            curl -L $u -o $(eval echo $dest_path)
        else
            curl $u -o $(eval echo $dest_path)
        fi
    done
}

##install_process_downloader ../config.json
