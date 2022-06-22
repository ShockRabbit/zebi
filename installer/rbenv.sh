#!/bin/sh

#source util.sh

function install_process_rbenv() {
    local config_path=$1
    
    echo_title "Install Process rbenv"

    brew install rbenv || log_error "[rbenv] fail :: brew install rbenv"
    brew install ruby-build || log_error "[rbenv] fail :: brew install ruby-build"
    
    ###################################################################################
    # Setup
    #
    # add rbenv init to shell
    rbenv init

    # add settings to shell config
    shell_config_file=$(get_shell_config_file)
    safe_append_config 'if command -v rbenv 1>/dev/null 2>&1; then\n  eval "$(rbenv init -)"\nfi' $shell_config_file
    safe_append_config 'export PATH="$HOME/.rbenv/bin:$PATH"' $shell_config_file

    # Restart shell
    source $shell_config_file
    ###################################################################################

    local versions=`cat $config_path | jq -r ".rbenv | .versions[].version"`
    local global=`cat $config_path | jq -r ".rbenv | .global"`

    for v in $versions; do
        log "rbenv install $v"
        if [ -d "$HOME/.rbenv/versions/${v}" ]; then
            log "already has ruby version ${v}"
        else
            rbenv install $v || log_error "[rbenv] fail :: rbenv install $v"
        fi
        rbenv local $v || log_error "[rbenv] fail :: rbenv local $v"
        local packages=`cat $config_path | jq -r ".rbenv | .versions[] | select(.version==\"${v}\") | .packages[]"`
        for p in $packages; do
            log "gem install $p"
            gem install $p || log_error "[rbenv] fail :: gem install $p"
        done
    done
    rbenv global $global || log_error "[rbenv] fail :: rbenv global $global"
    rbenv local $global
}

# install_process_rbenv ../config.json
