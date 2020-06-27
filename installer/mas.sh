#!/bin/sh

#source util.sh

function install_process_mas() {
    local config_path=$1
    
    echo_title "Install Process mas"

    # app name 에 띄어쓰기가 있을 수 있어 아래와 같이 loop 를 돌려야한다.
    cat $config_path | jq -c '.mas[]' | while read app_name; do
        log "[mas] install $app_name"
        mas lucky "$app_name" || log_error "[mas] install fail :: $app_name"
    done
}

# install_process_mas ../config.json
