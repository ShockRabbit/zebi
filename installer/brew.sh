#!/bin/sh

function cmd_with_expect_pw() {
    local cmd=$(eval echo $1)
    local pw=$2
expect <<EOF
set timeout 120
spawn $cmd
expect "Password:" { send "$pw\n"; expect eof }
EOF
}

function install_process_brew() {
    local config_path=$1
    local pw=$2

    # cat $config_path | jq -c '.brew | .taps[]' | while read t; do
    local brew_taps=`cat $config_path | jq -r ".brew | .taps[]"`
    for t in $brew_taps; do
        echo "-----------------------------------------"
        echo "brew tab $t"
        echo "-----------------------------------------"
        brew tap $t
    done
    # cat $config_path | jq -c '.brew | .casks[]' | while read c; do
    local brew_casks=`cat $config_path | jq -r ".brew | .casks[]"`
    for c in $brew_casks; do
        echo "-----------------------------------------"
        echo "brew cask install : $c"
        echo "-----------------------------------------"
        cmd_with_expect_pw "brew cask install $c" $pw
    done
    # cat $config_path | jq -c '.brew | .brews[]' | while read b; do
    local brew_brews=`cat $config_path | jq -r ".brew | .brews[]"`
    for b in $brew_brews; do
        echo "-----------------------------------------"
        echo "brew install : $b"
        echo "-----------------------------------------"
        cmd_with_expect_pw "brew install $b" $pw
    done
}

#install_process_brew ../config.json TEST_PASSWORD
