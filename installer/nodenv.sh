#!/bin/sh

function install_process_nodenv() {
    local config_path=$1
    
    brew install nodenv
    nodenv init

    local versions=`cat $config_path | jq -r ".nodenv | .versions[].version"`
    local global=`cat $config_path | jq -r ".nodenv | global"`

    for v in $versions; do
        nodenv install $v
        nodenv local $v
        local packages=`cat $config_path | jq -r ".nodenv | .versions[] | select(.version==\"${v}\") | .packages[]"`
        for p in $packages; do
            npm install $p -g
        done
    done
    nodenv global $global
    nodenv local $global
}
