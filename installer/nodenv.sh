#!/bin/sh

#source util.sh

function install_process_nodenv() {
    local config_path=$1

    echo_title "Install Process nodenv"
    
    brew install node || log_error "[nodenv] fail :: brew install node"
    brew install nodenv || log_error "[nodenv] fail :: brew install nodenv"
    brew install node-build || log_error "[nodenv] fali :: brew install node-build"

    ###################################################################################
    # Setup
    #
    nodenv init
    
    # add settings to shell config
    shell_config_file=$(get_shell_config_file)
    safe_append_config 'if command -v nodenv 1>/dev/null 2>&1; then\n  eval "$(nodenv init -)"\nfi' $shell_config_file
    safe_append_config 'export PATH="$HOME/.nodenv/bin:$PATH"' $shell_config_file
    safe_append_config 'export PATH="$HOME/.nodenv/shims:$PATH"' $shell_config_file
    # Restart shell
    #exec "$SHELL"
    source $shell_config_file
    ###################################################################################

    local versions=`cat $config_path | jq -r ".nodenv | .versions[].version"`
    local global=`cat $config_path | jq -r ".nodenv | .global"`

    for v in $versions; do
        log "nodenv install $v"
        if [ -d "$HOME/.nodenv/versions/${v}" ]; then
            log "already has node version ${v}"
        else
            nodenv install $v || log_error "[nodenv] fail :: nodenv install $v"
        fi
        nodenv local $v
        local packages=`cat $config_path | jq -r ".nodenv | .versions[] | select(.version==\"${v}\") | .packages[]"`
        for p in $packages; do
            log "npm install $p -g"
            npm install $p -g || log_error "[nodenv] fail :: npm install $p -g"
        done
    done
    log "nodenv global $global"
    nodenv global $global || log_error "[nodenv] fail :: nodenv global $global"
    nodenv local $global
}

# install_process_nodenv ../config.json
