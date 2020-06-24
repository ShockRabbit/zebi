#!/bin/sh

function install_process_android_sdk() {
    local config_path=$1

    if [ ! -d "$JAVA_HOME" ]; then
        brew tap AdoptOpenJDK/openjdk
        brew cask install adoptopenjdk8
    fi

    local sdktools_temp_path=$temp_path/android_sdk_tools
    local sdktools_zip_path=$sdktools_temp_path/sdk-tools.zip
    local location_str=`cat $config_path | jq -r ".android_sdk | .location"`
    local location=$(eval echo $location_str)
    local download_url=`cat $config_path | jq -r ".android_sdk | .download_url"`
    local sdk_api=`cat $config_path | jq -r ".android_sdk | .sdk_api"`
    local build_tools=`cat $config_path | jq -r ".android_sdk | .build_tools"`

    local sdkmanager=$location/tools/bin/sdkmanager
    if [ ! -d "$sdktools_temp_path" ]; then
        mkdir $sdktools_temp_path
    fi
    if [ ! -d "$location" ]; then
        mkdir $location
    fi
    wget -O $sdktools_zip_path $download_url
    unzip $sdktools_zip_path -d $location
    yes | $sdkmanager --licenses
    $sdkmanager "platform-tools" "platforms;android-$sdk_api" "build-tools;$build_tools"
}
