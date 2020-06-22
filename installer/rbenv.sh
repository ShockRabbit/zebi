#!/bin/sh

function install_process_rbenv() {
    local config_path=$1
    
    brew install rbenv ruby-build

    local versions=`cat $config_path | jq -r ".rbenv | .versions[].version"`
    local global=`cat $config_path | jq -r ".rbenv | global"`

    for v in $versions; do
        rbenv install $v
        rbenv local $v
        local packages=`cat $config_path | jq -r ".rbenv | .versions[] | select(.version==\"${v}\") | .packages[]"`
        for p in $packages; do
            gem install $p
        done
    done
    rbenv global $global
    rbenv local $global
}
