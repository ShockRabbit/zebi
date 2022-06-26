#!/bin/sh

#source util.sh
#|| log_error $error_msg
function install_with_expect_pw() {
    local params=$1
    local pw=$2
expect <<EOF
set timeout 120
spawn brew install $(eval echo $params)
expect "Password:" { send "$pw\n"; expect eof }
EOF
}

function cask_install_with_expect_pw() {
    local params=$1
    local pw=$2
expect <<EOF
set timeout 120
spawn brew install --cask $(eval echo $params)
expect "Password:" { send "$pw\n"; expect eof }
EOF
}

function install_process_brew() {
    local config_path=$1
    local pw=$2

    echo_title "Install Process brew :: brew tap"
    local brew_taps=`cat $config_path | jq -r ".brew | .taps[]"`
    for t in $brew_taps; do
        log "brew tap $t"
        brew tap $t || log_error "[brew] fail brew tap $t"
    done
    echo_title "Install Process brew :: brew install --cask"
    local brew_casks=`cat $config_path | jq -r ".brew | .casks[]"`
    for c in $brew_casks; do
        log "brew install --cask $c"
        cask_install_with_expect_pw "${c}" $pw
    done
    echo_title "Install Process brew :: brew install"
    local brew_brews=`cat $config_path | jq -r ".brew | .brews[]"`
    for b in $brew_brews; do
        log "brew install $b"
        install_with_expect_pw "${b}" $pw
    done
}

#install_process_brew ../config.json TEST_PASSWORD
