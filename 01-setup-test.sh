#!/bin/sh

source util.sh

function request_login_mas() {
    # Request login to Mac App Store
    echo_title "Login to Mac App Store"
    echo "you must login to Mac App Store"
    open -a "App Store"
    read -p "Press enter to continue after Login to Mac App Store"
}

function prepare_install() {
    local config_path=$1
    
    # 설치를 위해 필요한 것들을 설치한다. (brew, git, jq)
    # install Homebrew
    [ X`which brew` = X/usr/local/bin/brew ] || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

    # install git
    brew install git

    # install jq
    brew install jq

    # if order contains mas -> install mas
    order=`cat $config_path | jq -r ".order[]"`
    for o in $order; do
        if [[ $o == "mas" ]] ; then
            # install mas
            brew install mas
            request_login_mas
        fi
    done

}

# import all installer script
for entry in ./installer/*; do
    source $entry
done

echo_title "enter config file path for install automation"
read -ep "config file path:" config_path
echo "\n"

echo_title "enter password for install automation"
read -rsp "password:" pw
echo "\n"

prepare_install $config_path

# execute install process by order
order=`cat $config_path | jq -r ".order[]"`
for o in $order; do
    if [[ $o == *".sh" ]] ; then
        sh $o
    else
        install_process_$o $config_path $pw
    fi
done
