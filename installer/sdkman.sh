#!/bin/sh

function install_process_sdkman() {
    local config_path=$1

    # install SDKMAN
    curl -s "https://get.sdkman.io" | bash
    source "$HOME/.sdkman/bin/sdkman-init.sh"

    # install sdks by sdkman
    local sdk_names=`cat $config_path | jq -r ".sdkman[].name"`
    for n in $sdk_names; do
        local default=`cat $config_path | jq -r ".sdkman[] | select(.name==\"${n}\") | .default"`
        local versions=`cat $config_path | jq -r ".sdkman[] | select(.name==\"${n}\") | .versions[]"`
        for v in $versions; do
            sdk install $n $v
        done
        sdk default $n $default
    done
}
