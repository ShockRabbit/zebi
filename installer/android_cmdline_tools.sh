#!/bin/sh

# source ../util.sh
#|| log_error $error_msg

function install_process_android_cmdline_tools() {
    local config_path=$1
    local pw=$2

    echo_title "Install Process android_cmdline_tools"

    local jdk_for_latest_cmdline_tools=`cat $config_path | jq -r ".android_cmdline_tools | .jdk_for_latest_cmdline_tools"`
    local latest_download_url=`cat $config_path | jq -r ".android_cmdline_tools | .latest_download_url"`
    local target_cmdline_tools=`cat $config_path | jq -r ".android_cmdline_tools | .target_cmdline_tools"`
    local jdk_for_target_cmdline_tools=`cat $config_path | jq -r ".android_cmdline_tools | .jdk_for_target_cmdline_tools"`
    local sdk_api_list=`cat $config_path | jq -r ".android_cmdline_tools | .sdk_api[]"`
    local build_tools_list=`cat $config_path | jq -r ".android_cmdline_tools | .build_tools[]"`
    local ndk_list=`cat $config_path | jq -r ".android_cmdline_tools | .ndk[]"`
    
    # install temurin
    is_temurin_installed=$(is_installed_by_brew temurin)
    if [[ $is_temurin_installed != "installed" ]]; then
        echo_title "Install jdk (temurin)"
        brew install --cask temurin
    fi
    
    # install jdk for latest cmdline tools
    is_jdk_for_latest_cmdline_tools_installed=$(is_installed_by_brew temurin@$jdk_for_latest_cmdline_tools)
    if [[ $is_jdk_for_latest_cmdline_tools_installed != "installed" ]]; then
        echo_title "Install jdk (temurin@$jdk_for_latest_cmdline_tools) for latest cmdline tools"
        brew install --cask temurin@$jdk_for_latest_cmdline_tools
        
        # add settings to shell config
        shell_config_file=$(get_shell_config_file)
        latest_config="export JAVA_${jdk_for_latest_cmdline_tools}_HOME=$(/usr/libexec/java_home -v${jdk_for_latest_cmdline_tools})"
        home_config="export JAVA_HOME=$JAVA_${jdk_for_latest_cmdline_tools}_HOME"
        safe_append_config "$latest_config" $shell_config_file
        safe_append_config "$home_config" $shell_config_file
        
        # Restart shell
        source $shell_config_file
    fi

    # install latest cmdline tools
    local dest_path=$HOME/Downloads/cmdline_tools.zip
    echo_title "Download cmdline tools from $latest_download_url to $dest_path"
    curl -L $latest_download_url -o $dest_path
    
    local cmdline_tools_path=$HOME/Library/Android/sdk/cmdline-tools/latest
    echo_title "Unzip cmdline tools to $cmdline_tools_path"
    mkdir -p $cmdline_tools_path
    unzip -d $cmdline_tools_path -j $dest_path

    # install target cmdline tools
    echo_title "Install target cmdline tools"
    local latest_sdkmanager=$cmdline_tools_path//bin/sdkmanager
    $latest_sdkmanager "cmdline-tools;${target_cmdline_tools}"
    
    # install jdk for target cmdline tools
    is_jdk_for_target_cmdline_tools_installed=$(is_installed_by_brew temurin@$jdk_for_target_cmdline_tools)
    if [[ $is_jdk_for_target_cmdline_tools_installed != "installed" ]]; then
        echo_title "Install jdk (temurin@$jdk_for_target_cmdline_tools) for target cmdline tools"
        brew install --cask temurin@$jdk_for_target_cmdline_tools
        
        # add settings to shell config
        shell_config_file=$(get_shell_config_file)
        target_config="export JAVA_${jdk_for_target_cmdline_tools}_HOME=$(/usr/libexec/java_home -v${jdk_for_target_cmdline_tools})"
        home_config="export JAVA_HOME=$JAVA_${jdk_for_target_cmdline_tools}_HOME"
        safe_append_config "$target_config" $shell_config_file
        safe_append_config "$home_config" $shell_config_file
        
        # Restart shell
        source $shell_config_file
    fi
    
    # install platform-tools, sdk_api, build_tools, ndk
    local target_sdkmanager=$HOME/Library/Android/sdk/cmdline-tools/$target_cmdline_tools/bin/sdkmanager
    echo_title "Install platform-tools"
    $target_sdkmanager "platform-tools" || log_error "[android_cmdline_tools] install fail platform-tools"
    for api in $sdk_api_list; do
        echo_title "Install platforms;android-$api"
        $target_sdkmanager "platforms;android-$api" || log_error "[android_cmdline_tools] install fail platforms;android-$api"
    done
    for build_tool in $build_tools_list; do
        echo_title "Install build-tools;$build_tool"
        $target_sdkmanager "build-tools;$build_tool" || log_error "[android_cmdline_tools] install fail build-tools;$build_tool"
    done
    for ndk in $ndk_list; do
        echo_title "Install ndk;$ndk"
        $target_sdkmanager "ndk;$ndk" || log_error "[android_cmdline_tools] install fail ndk;$ndk"
    done
}

# install_process_android_cmdline_tools ~/Desktop/config_for_macmini.json TEST_PASSWORD
