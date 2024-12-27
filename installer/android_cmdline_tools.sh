#!/bin/sh

# source ../util.sh
#|| log_error $error_msg

function install_jdk_by_temurin() {
    local jdk_version=$1

    # install temurin
    local is_temurin_installed=$(is_installed_by_brew temurin)
    if [[ $is_temurin_installed != "installed" ]]; then
        echo_title "Install jdk (temurin)"
        brew install --cask temurin
    fi
    
    # install jdk for latest cmdline tools
    local is_jdk_installed=$(is_installed_by_brew temurin@$jdk_version)
    if [[ $is_jdk_installed != "installed" ]]; then
        echo_title "Install jdk (temurin@$jdk_version)"
        brew install --cask temurin@$jdk_version
    fi
}

function add_jdk_settings_to_config_by_temurin() {
    local jdk_version=$1
    
    # add settings to shell config
    local shell_config_file=$(get_shell_config_file)
    local latest_config="export JAVA_${jdk_version}_HOME=\$(/usr/libexec/java_home -v${jdk_version})"
    local home_config="export JAVA_HOME=\$JAVA_${jdk_version}_HOME"
    local path_config="export PATH=\"\$JAVA_HOME/bin:\$PATH\""
    safe_append_config "$latest_config" $shell_config_file
    safe_append_config "$home_config" $shell_config_file
    safe_remove_config "$path_config" $shell_config_file
    safe_append_config "$path_config" $shell_config_file
    
    # Restart shell
    source $shell_config_file
}

function install_jdk_by_openjdk() {
    local jdk_version=$1

    # install openjdk
    local is_openjdk_installed=$(is_installed_by_brew openjdk)
    if [[ $is_openjdk_installed != "installed" ]]; then
        echo_title "Install jdk (openjdk)"
        brew install openjdk
    fi
    
    # install jdk for latest cmdline tools
    local is_jdk_installed=$(is_installed_by_brew openjdk@$jdk_version)
    if [[ $is_jdk_installed != "installed" ]]; then
        echo_title "Install jdk (openjdk@$jdk_version)"
        brew install openjdk@$jdk_version
    fi
}

function add_jdk_settings_to_config_by_openjdk() {
    local jdk_version=$1

    # add settings to shell config
    local shell_config_file=$(get_shell_config_file)
    local latest_config="export JAVA_${jdk_version}_HOME=\"/opt/homebrew/opt/openjdk@${jdk_version}\""
    local home_config="export JAVA_HOME=\$JAVA_${jdk_version}_HOME"
    local path_config="export PATH=\"\$JAVA_HOME/bin:\$PATH\""
    safe_append_config "$latest_config" $shell_config_file
    safe_append_config "$home_config" $shell_config_file
    safe_remove_config "$path_config" $shell_config_file
    safe_append_config "$path_config" $shell_config_file
    
    # Restart shell
    source $shell_config_file
}

function install_process_android_cmdline_tools() {
    local config_path=$1
    local pw=$2

    echo_title "Install Process android_cmdline_tools"

    local use_temurin=`cat $config_path | jq -r "if .android_cmdline_tools | .jdk_use_temurin then 1 else 0 end"`
    local jdk_for_latest_cmdline_tools=`cat $config_path | jq -r ".android_cmdline_tools | .jdk_for_latest_cmdline_tools"`
    local latest_download_url=`cat $config_path | jq -r ".android_cmdline_tools | .latest_download_url"`
    local target_cmdline_tools=`cat $config_path | jq -r ".android_cmdline_tools | .target_cmdline_tools"`
    local jdk_for_target_cmdline_tools=`cat $config_path | jq -r ".android_cmdline_tools | .jdk_for_target_cmdline_tools"`
    local sdk_api_list=`cat $config_path | jq -r ".android_cmdline_tools | .sdk_api[]"`
    local build_tools_list=`cat $config_path | jq -r ".android_cmdline_tools | .build_tools[]"`
    local ndk_list=`cat $config_path | jq -r ".android_cmdline_tools | .ndk[]"`
    
    # install jdk for latest cmdline tools
    if [ $use_temurin -eq 1 ]; then
        install_jdk_by_temurin $jdk_for_latest_cmdline_tools
        add_jdk_settings_to_config_by_temurin $jdk_for_latest_cmdline_tools
    else
        install_jdk_by_openjdk $jdk_for_latest_cmdline_tools
        add_jdk_settings_to_config_by_openjdk $jdk_for_latest_cmdline_tools
    fi

    # install latest cmdline tools
    local dest_path=$HOME/Downloads/cmdline_tools.zip
    echo_title "Download cmdline tools from $latest_download_url to $dest_path"
    curl -L $latest_download_url -o $dest_path
    
    local cmdline_tools_root=$HOME/Library/Android/sdk/cmdline-tools
    local cmdline_tools_path=$cmdline_tools_root/latest
    echo_title "Unzip cmdline tools to $cmdline_tools_root"
    mkdir -p $cmdline_tools_root
    unzip $dest_path -d $cmdline_tools_root;mv $cmdline_tools_root/cmdline-tools $cmdline_tools_path

    # install target cmdline tools
    echo_title "Install target cmdline tools"
    local latest_sdkmanager=$cmdline_tools_path/bin/sdkmanager
    yes | $latest_sdkmanager --licenses
    $latest_sdkmanager "cmdline-tools;${target_cmdline_tools}"
    
    # install jdk for target cmdline tools
    if [ $use_temurin -eq 1 ]; then
        install_jdk_by_temurin $jdk_for_target_cmdline_tools
        add_jdk_settings_to_config_by_temurin $jdk_for_target_cmdline_tools
    else
        install_jdk_by_openjdk $jdk_for_target_cmdline_tools
        add_jdk_settings_to_config_by_openjdk $jdk_for_target_cmdline_tools
    fi

    # install platform-tools, sdk_api, build_tools, ndk
    local target_sdkmanager=$HOME/Library/Android/sdk/cmdline-tools/$target_cmdline_tools/bin/sdkmanager
    yes | $target_sdkmanager --licenses
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
