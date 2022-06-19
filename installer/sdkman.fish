#!/usr/bin/env fish


#source util.sh

function install_process_sdkman
    set -l config_path $argv[1]

    echo_title "Install Process sdkman"

    # install SDKMAN
    curl -s "https://get.sdkman.io" | bash
    source "$HOME/.sdkman/bin/sdkman-init.sh"

    # install sdks by sdkman
    set -l sdk_names (cat $config_path | jq -r ".sdkman[].name")
    for n in $sdk_names
        set -l default (cat $config_path | jq -r ".sdkman[] | select(.name==\"$n\") | .default")
        set -l versions (cat $config_path | jq -r ".sdkman[] | select(.name==\"$n\") | .versions[]")
        for v in $versions
            log "Install $n::$v"
            sdk install $n $v || log_error "[sdkman] fail :: sdk install $n $v"
        end
        log "$set $n's default version: $v"
        sdk default $n $default || log_error "[sdkman] fail :: sdk default $n $default"
    end
end

#install_process_sdkman ../config.json
