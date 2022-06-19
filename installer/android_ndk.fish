#!/usr/bin/env fish

#source util.sh

function install_process_android_ndk
    set -l config_path $argv[1]

    set -l location_str (cat $config_path | jq -r ".android_ndk | .location")
    set -l location (eval echo $location_str)
    set -l download_url=(cat $config_path | jq -r ".android_ndk | .download_url")
    set -l temp_path ./temp_for_install
    set -l ndk_temp_path $temp_path/android_ndk
    set -l ndk_zip_path $ndk_temp_path/ndk.zip
    if [ ! -d "$ndk_temp_path" ]
        mkdir -p $ndk_temp_path
    end
    if [ ! -d "$location" ]
        mkdir -p $location
    end

    echo_title "Install Process android_ndk"
    log "Download Android NDK from $download_url to $location"

    wget -O $ndk_zip_path $download_url || log_error "[android_ndk] download fail :: $download_url to $ndk_zip_path"
    unzip $ndk_zip_path -d $location || log_error "[android_ndk] unzip fail :: $ndk_zip_path to $location_str"
end

#install_process_android_ndk ../config.json
