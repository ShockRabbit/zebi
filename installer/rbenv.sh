#!/bin/sh

function install_process_rbenv() {
    local config_path=$1
    
    brew install rbenv ruby-build
    
    ###################################################################################
    # Setup
    #
    # add rbenv init to shell
    # FIXME 추후 shell type 에 따라서 수정할 설정 파일을 바꿔야할 듯..
    echo 'if command -v rbenv 1>/dev/null 2>&1; then\n  eval "$(rbenv init -)"\nfi' >> ~/.bash_profile
    # Restart shell
    source ~/.bash_profile
    ###################################################################################

    local versions=`cat $config_path | jq -r ".rbenv | .versions[].version"`
    local global=`cat $config_path | jq -r ".rbenv | .global"`

    for v in $versions; do
        echo "---------------------------------"
        echo "rbenv install $v"
        echo "---------------------------------"
        rbenv install $v
        rbenv local $v
        local packages=`cat $config_path | jq -r ".rbenv | .versions[] | select(.version==\"${v}\") | .packages[]"`
        for p in $packages; do
            echo "---------------------------------"
            echo "gem install $p"
            echo "---------------------------------"
            gem install $p
        done
    done
    rbenv global $global
    rbenv local $global
}

# install_process_rbenv ../config.json
