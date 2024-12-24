#!/bin/sh

#source util.sh

function install_process_android_ndk() {
    is_wget_exist=$(is_exist_cmd wget)
    if [[ $is_wget_exist != "exist" ]]; then
        brew install wget
    fi

    local config_path=$1

    local location_str=`cat $config_path | jq -r ".android_ndk | .location"`
    local location=$(eval echo $location_str)
    local download_url=`cat $config_path | jq -r ".android_ndk | .download_url"`
    local temp_path=./temp_for_install
    local ndk_temp_path=$temp_path/android_ndk
    local ndk_zip_path=$ndk_temp_path/ndk.zip
    if [ ! -d "$ndk_temp_path" ]; then
        mkdir -p $ndk_temp_path
    fi
    if [ ! -d "$location" ]; then
        mkdir -p $location
    fi

    echo_title "Install Process android_ndk"
    log "Download Android NDK from ${download_url} to ${location}"

    wget -O $ndk_zip_path $download_url || log_error "[android_ndk] download fail :: $download_url to $ndk_zip_path"
    unzip $ndk_zip_path -d $location || log_error "[android_ndk] unzip fail :: $ndk_zip_path to $location_str"
}

#install_process_android_ndk ../config.json
