#!/bin/sh

function ssh_keygen() {
    local email=$1
    local save_path=$2
expect <<EOF
set timeout 1
spawn ssh-keygen -t rsa -b 2048 -C $email
expect "Enter file in which to save the key"
send "$save_path\n"
expect "Enter passphrase"
send "\n"
expect "Enter same passphrase again:"
send "\n"
expect eof
EOF
}

function register_ssh_key() {
    local name=$1
    local url=$2
    local private_token=$3

    local ssh_path="$HOME/.ssh/id_rsa_$name"
    local title="$USER_$name"
    local ssh_key=$(cat ssh_path)

    if [[ $url == *"github.com"* ]] ; then
        echo "add ssh key to $url"
        curl -u "username:$private_token" "https://api.github.com/user/keys?title=$title&key=ssh_key"
    elif [[ $url == *"gitlab"* ]] ; then
        echo "add ssh key to $url"
        curl --header "Private-Token: $private_token" "https://$url/api/v4/users/keys?title=$title&key=$ssh_key"
    else
        echo "[add ssh key] not supported : $url"
    fi
    #FIXME 실패했을 때는 git 과 관련된 부분은 다 실패할 것.. 재시도나 끊거나 등 대응 필요
}

function create_git_config() {
    # not support bitbucket && [ $url != "bitbucket.org" ] 
    local name=$1
    local url=$2
    local user_name=$3
    local user_email=$4
    local include_paths=$5

    local file_name=".gitconfig_$name"
    local config_path="$HOME/$file_name"

    # create .gitconfig_$name
    if [ -f"$config_path" ] ; then
        rm $config_path
    fi
    echo "[user]" >> $config_path
    echo "\temail = $user_email" >> $config_path
    echo "\tname = $user_name" >> $config_path
    if [ $url != "github.com" ] && [ $url != "gitlab.com" ] ; then
        echo "[url \"git@$url:\"]" >> $config_path
        echo "\tinsteadof = https://$url/" >> $config_path
    fi

    # add includeIf path to .gitconfig
    local gitconfig_path="$HOME/.gitconfig"
    for p in $include_paths; do
        mkdir -p p
        local include_info="[includeIf \"gitdir:$p/\"]"
        local count=$(grep -c "$include_info" $gitconfig_path)
        if [ $count -eq 0 ] ; then
            echo $include_info >> $gitconfig_path
            echo "\tpath = $file_name" >> $gitconfig_path
        fi
    done

    # add Host info to ~/.ssh/config
    local sshconfig_path="$HOME/.ssh/config"
    local host_info="Host $url"
    local count=$(grep -c "$host_info" $sshconfig_path)
    if [ $count -eq 0 ] ; then
        echo $host_info >> $sshconfig_path
        echo "\tHostname $url" >> $sshconfig_path
        echo "\tUser git" >> $sshconfig_path
        echo "\tIdentityFile ~/.ssh/id_rsa_$name" >> $sshconfig_path
        echo "\tIdentitiesOnly=yes" >> $sshconfig_path
    fi
}


function install_process_git_organization() {
    local config_path=$1

    local git_names=`cat $config_path | jq -r ".git_organization | .[].name"`
    for n in $git_names; do
        local url=`cat $config_path | jq -r ".git_organization | .[] | select(.name==\"${n}\") | .url"`
        local user_name=`cat $config_path | jq -r ".git_organization | .[] | select(.name==\"${n}\") | .user_name"`
        local user_email=`cat $config_path | jq -r ".git_organization | .[] | select(.name==\"${n}\") | .user_email"`
        local private_token=`cat $config_path | jq -r ".git_organization | .[] | select(.name==\"${n}\") | .private_token"`
        local include_paths=`cat $config_path | jq -r ".git_organization | .[] | select(.name==\"${n}\") | .include_paths"`
        # create git config
        create_git_config $n $url $user_name $user_email $include_paths

        # ssh keygen
        local save_path="$HOME/.ssh/id_rsa_$n"
        ssh_keygen $user_email $save_path

        # register ssh key
        register_ssh_key $n $url $private_token
    done
}
