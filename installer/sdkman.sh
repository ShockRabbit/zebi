#!/bin/sh

#source util.sh

function install_process_sdkman() {
    local config_path=$1

    echo_title "Install Process sdkman"

    # install SDKMAN
    curl -s "https://get.sdkman.io" | bash
    source "$HOME/.sdkman/bin/sdkman-init.sh"

    # install sdks by sdkman
    local sdk_names=`cat $config_path | jq -r ".sdkman[].name"`
    for n in $sdk_names; do
        local default=`cat $config_path | jq -r ".sdkman[] | select(.name==\"${n}\") | .default"`
        local versions=`cat $config_path | jq -r ".sdkman[] | select(.name==\"${n}\") | .versions[]"`
        for v in $versions; do
            log "Install ${n}::${v}"
            sdk install $n $v || log_error "[sdkman] fail :: sdk install $n $v"
        done
        log "$set ${n}'s default version: ${v}"
        sdk default $n $default || log_error "[sdkman] fail :: sdk default $n $default"
    done
}

#install_process_sdkman ../config.json
