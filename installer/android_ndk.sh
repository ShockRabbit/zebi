#!/bin/sh

function install_process_android_ndk() {
    local config_path=$1

    local location=`cat $config_path | jq -r ".android_ndk | .location"`
    local download_url=`cat $config_path | jq -r ".android_ndk | .download_url"`
    local ndk_temp_path=$temp_path/android_ndk
    local ndk_zip_path=$ndk_temp_path/ndk.zip
    if [ ! -d "$ndk_temp_path" ]; then
        mkdir $ndk_temp_path
    fi
    if [ ! -d "$location" ]; then
        mkdir $location
    fi
    wget -O $ndk_zip_path $download_url
    unzip $ndk_zip_path -d $location
}
