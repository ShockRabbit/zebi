#!/usr/local/bin/fish


source util.fish

# function install_brew_with_expect_pw
#     set -l pw $argv[1]
#     set -l cmd ([ X`which brew` = X/usr/local/bin/brew ] || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)")
# expect <<EOF
# set timeout 120
# spawn $cmd
# expect "Password:" { send "$pw\n"; expect eof }
# expect "Press RETURN to continue" { send "\n"; expect eof }
# expect "Password:" { send "$pw\n"; expect eof }
# EOF
# end

function request_login_mas
    # Request login to Mac App Store
    echo_title "Login to Mac App Store"
    echo "you must login to Mac App Store"
    open -a "App Store"
    read -p "Press enter to continue after Login to Mac App Store"
end

function prepare_install
    set -l config_path $argv[1]
    set -l pw $argv[2]
    
    # 설치를 위해 필요한 것들을 설치한다. (brew, git, jq)
    # install Homebrew
    #install_brew_with_expect_pw $pw
    # 왜인지 잘 모르겠지만 expect 가 안먹는다 ... 별 수 없이 처음에는 비번 넣고 엔터키 쳐준다.

    set -l brew_path (which brew)
    if [ $brew_path != /usr/local/bin/brew ]
        # not exist, install brew
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    end

    # install git
    brew install git

    # install jq
    brew install jq

    # if order contains mas -> install mas

    set order (cat $config_path | jq -r ".order[]")
    for o in $order
        if [ $o = "mas" ]
            # install mas
            brew install mas
            request_login_mas
        end
    end
end

# import all installer script
for entry in ./installer/*
    source $entry
end

echo_title "enter config file path for install automation"
read -ep "config file path:" config_path
echo "\n"

echo_title "enter password for install automation"
read -rsp "password:" pw
echo "\n"

prepare_install $config_path $pw

# execute install process by order
set order (cat $config_path | jq -r ".order[]")
for o in $order
    if [ $o = *".fish" ] ; then
        /usr/bin/env fish $o
    else
        install_process_$o $config_path $pw
    fi
end
