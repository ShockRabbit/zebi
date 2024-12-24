#!/bin/sh

# source ../util.sh
#|| log_error $error_msg

function install_process_xcodes() {
    local config_path=$1
    local pw=$2
    
    echo_title "Install Process xcodes"

    # install xcodes
    is_xcodes_exist=$(is_exist_cmd xcodes)
    if [[ $is_xcodes_exist != "exist" ]]; then
        brew install xcodesorg/made/xcodes
    fi

    # install aria2
    is_aria2_exist=$(is_exist_cmd aria2c)
    if [[ $is_aria2_exist != "exist" ]]; then
        brew install aria2
    fi

    cat $config_path | jq -c '.xcodes[]' | while read version; do
        log "[xcodes] install $version"
        xcodes install "$version" || log_error "[xcodes] install fail :: $version"
    done
}

# install_process_xcodes ~/Desktop/config_for_macmini.json TEST_PASSWORD
