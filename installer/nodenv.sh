#!/bin/sh

#source util.sh

function install_process_nodenv() {
    local config_path=$1

    echo_title "Install Process nodenv"
    
    brew install nodenv || log_error "[nodenv] fail :: brew install nodenv"
    brew install node-build || log_error "[nodenv] fali :: brew install node-build"

    ###################################################################################
    # Setup
    #
    # add nodenv init to shell
    # FIXME 추후 shell type 에 따라서 수정할 설정 파일을 바꿔야할 듯..
    echo 'if command -v nodenv 1>/dev/null 2>&1; then\n  eval "$(nodenv init -)"\nfi' >> ~/.bash_profile
    # Restart shell
    #exec "$SHELL"
    source ~/.bash_profile
    ###################################################################################

    local versions=`cat $config_path | jq -r ".nodenv | .versions[].version"`
    local global=`cat $config_path | jq -r ".nodenv | .global"`

    for v in $versions; do
        log "nodenv install $v"
        nodenv install $v || log_error "[nodenv] fail :: nodenv install $v"
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
