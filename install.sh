#!/bin/sh

SCRIPT_DIR=$(dirname "$(realpath "$0")")
source $SCRIPT_DIR/util.sh

function request_login_mas() {
    # Request login to Mac App Store
    echo_title "Login to Mac App Store"
    echo "you must login to Mac App Store"
    open -a "App Store"
    read -p "Press enter to continue after Login to Mac App Store"
}

function expect_install_rosetta2() {
    local pw=$1
    has_rosetta=$(/usr/bin/pgrep -q oahd && echo Yes || echo No)
    if [[ $has_rosetta == "No" ]]; then
expect <<EOF
set timeout 12000
spawn sudo softwareupdate --install-rosetta
expect "assword:"
send "$pw\n"
expect "Type A and press return to agree:"
send "A\n"
expect eof
EOF
    fi
}

function prepare_install() {
    local config_path=$1
    local pw=$2
    
    # 설치를 위해 필요한 것들을 설치한다. (brew, git, jq)
    # install Homebrew
    is_brew_exist=$(is_exist_cmd brew)
    if [[ $is_brew_exist != "exist" ]]; then
        [ X`which brew` = X/usr/local/bin/brew ] || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

    fi

    # install rosetta2
    local cpu_type=$(uname -m)
    if [[ "$cpu_type" == "arm64" ]]; then
        log "Install rosetta 2"
        expect_install_rosetta2 $pw
        # apple silicon 의 경우 따로 PATH 등록이 필요하다
        shell_config_file=$(get_shell_config_file)
        safe_append_config 'export PATH="/opt/homebrew/bin:$PATH"' $shell_config_file
        source $shell_config_file
    fi

    # install git
    is_git_exist=$(is_exist_cmd git)
    if [[ $is_git_exist != "exist" ]]; then
        brew install git
    fi

    # install jq
    is_jq_exist=$(is_exist_cmd jq)
    if [[ $is_jq_exist != "exist" ]]; then
        brew install jq
    fi

    # if order contains mas -> install mas
    order=`cat $config_path | jq -r ".order[]"`
    for o in $order; do
        if [[ $o == "mas" ]] ; then
            # install mas
            is_mas_exist=$(is_exist_cmd mas)
            if [[ $is_mas_exist != "exist" ]]; then
                brew install mas
            fi
            request_login_mas
        fi
    done

}

# import all installer script
for entry in $SCRIPT_DIR/installer/*; do
    source $entry
done

echo_title "enter config file path for install automation"
read -ep "config file path:" config_path_str
echo "\n"

echo_title "enter password for install automation"
read -rsp "password:" pw
echo "\n"

config_path=$(eval echo $config_path_str)
prepare_install $config_path $pw

# execute install process by order
order=`cat $config_path | jq -r ".order[]"`
for o in $order; do
    if [[ $o == *".sh" ]] ; then
        sh_path=$(eval echo $o)
        sh $sh_path
    elif [[ $o == *".fish" ]] ; then
        fish_path=$(eval echo $o)
        fish $fish_path
    else
        install_process_$o $config_path $pw
    fi
done
