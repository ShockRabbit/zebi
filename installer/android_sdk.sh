#!/bin/sh

function install_process_android_sdk() {
    local config_path=$1

    if [ ! -d "$JAVA_HOME" ]; then
        brew tap AdoptOpenJDK/openjdk
        brew cask install adoptopenjdk8
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

    echo "-----------------------------------------------------"
    echo "Download Android SDK from ${download_url} to ${location}"
    echo "-----------------------------------------------------"
    wget -O $sdktools_zip_path $download_url
    unzip $sdktools_zip_path -d $location
    yes | $sdkmanager --licenses
    $sdkmanager "platform-tools" "platforms;android-$sdk_api" "build-tools;$build_tools"
}

#install_process_android_sdk ../config.json
