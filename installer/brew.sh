#!/bin/sh

function install_process_brew() {
    local config_path=$1

    local brew_tabs=`cat $config_path | jq -r ".brew | .tabs[]"`
    for t in $brew_tabs; do
        brew tab $t
    done
    local brew_brews=`cat $config_path | jq -r ".brew | .brews[]"`
    for b in $brew_brews; do
        brew install $b
    done
    local brew_casks=`cat $config_path | jq -r ".brew | .casks[]"`
    for c in $brew_casks; do
        brew cask install $c
    done
}
