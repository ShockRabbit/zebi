#!/bin/sh

#source util.sh

function install_process_android_sdk() {
    is_wget_exist=$(is_exist_cmd wget)
    if [[ $result != "exist" ]]; then
        brew install wget
    fi

    local config_path=$1

    if [ ! -d "$JAVA_HOME" ]; then
        brew tap AdoptOpenJDK/openjdk
        brew install --cask adoptopenjdk8
    fi

    local temp_path=./temp_for_install
    local sdktools_temp_path=$temp_path/android_sdk_tools
    local sdktools_zip_path=$sdktools_temp_path/sdk-tools.zip
    local location_str=`cat $config_path | jq -r ".android_sdk | .location"`
    local location=$(eval echo $location_str)
    local download_url=`cat $config_path | jq -r ".android_sdk | .download_url"`
    local sdk_api=`cat $config_path | jq -r ".android_sdk | .sdk_api"`
    local build_tools=`cat $config_path | jq -r ".android_sdk | .build_tools"`

    local sdkmanager=$location/tools/bin/sdkmanager
    if [ ! -d "$sdktools_temp_path" ]; then
        mkdir -p $sdktools_temp_path
    fi
    if [ ! -d "$location" ]; then
        mkdir -p $location
    fi

    echo_title "Install Process android_sdk"
    log "Download Android SDK from ${download_url} to ${location}"

    wget -O $sdktools_zip_path $download_url || log_error "[android_sdk] sdktools download fail :: $download_url to $sdk_zip_path"
    unzip $sdktools_zip_path -d $location || log_error "[android_ndk] unzip fail :: $sdktools_zip_path to $location_str"
    yes | $sdkmanager --licenses
    $sdkmanager "platform-tools" "platforms;android-$sdk_api" "build-tools;$build_tools" "cmdline-tools;latest" || log_error "[android_sdk] install fail \(platform-tools, platforms;android-$sdk_api, build_tools;$build_tools\)"
}

#install_process_android_sdk ../config.json
