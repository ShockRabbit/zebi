#!/usr/bin/env fish

#source util.sh

function install_process_android_sdk
    set -l config_path $argv[1]

    if [ ! -d "$JAVA_HOME" ]; then
        brew tap AdoptOpenJDK/openjdk
        brew cask install adoptopenjdk8
    fi

    set -l temp_path ./temp_for_install
    set -l sdktools_temp_path $temp_path/android_sdk_tools
    set -l sdktools_zip_path $sdktools_temp_path/sdk-tools.zip
    set -l location_str (cat $config_path | jq -r ".android_sdk | .location")
    set -l location (eval echo $location_str)
    set -l download_url (cat $config_path | jq -r ".android_sdk | .download_url")
    set -l sdk_api (cat $config_path | jq -r ".android_sdk | .sdk_api")
    set -l build_tools (cat $config_path | jq -r ".android_sdk | .build_tools")

    set -l sdkmanager $location/tools/bin/sdkmanager
    if [ ! -d "$sdktools_temp_path" ]
        mkdir -p $sdktools_temp_path
    end
    if [ ! -d "$location" ]
        mkdir -p $location
    end

    echo_title "Install Process android_sdk"
    log "Download Android SDK from $download_url to $location"

    wget -O $sdktools_zip_path $download_url || log_error "[android_sdk] sdktools download fail :: $download_url to $sdk_zip_path"
    unzip $sdktools_zip_path -d $location || log_error "[android_ndk] unzip fail :: $sdktools_zip_path to $location_str"
    yes | $sdkmanager --licenses
    $sdkmanager "platform-tools" "platforms;android-$sdk_api" "build-tools;$build_tools" "cmdline-tools;latest" || log_error "[android_sdk] install fail \(platform-tools, platforms;android-$sdk_api, build_tools;$build_tools\)"
end

#install_process_android_sdk ../config.json
