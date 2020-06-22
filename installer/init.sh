#!/bin/sh

function install_process_init() {
    local config_path=$1
    
    # 설치를 위해 필요한 것들을 설치한다. (brew, git, jq)
    # install Homebrew
    [ X`which brew` = X/usr/local/bin/brew ] || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

    # install git
    brew install git

    # install jq
    brew install jq

    # install mas
    brew install mas

    # Request login to Mac App Store
    echo_title "Login to Mac App Store"
    echo "you must login to Mac App Store"
    open -a "App Store"
}
