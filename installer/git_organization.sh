#!/bin/sh

function safe_delete() {
    local path=$1
    if [ -f $path ]; then
        rm $path
    fi
}

function ssh_keygen() {
    local email=$1
    local save_path=$2
    local pub_file=$save_path.pub
    safe_delete $save_path
    safe_delete $pub_file

    echo "-----------------------------------------------------"
    echo "generate ssh key (${email}) : ${save_path}"
    echo "-----------------------------------------------------"
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

function create_ssh_key_data() {
    JSON_STRING=$( jq -n \
                      --arg t "$1" \
                      --arg k "$2" \
					  '{ title: $t, key: $k }' )
	echo $JSON_STRING
}

function register_ssh_key() {
    local name=$1
    local url=$2
    local private_token=$3

    local ssh_path=$HOME/.ssh/id_rsa_$name.pub
    local title="${USER}_${name}"
    local ssh_key=$(cat $ssh_path)

    if [[ $url == *"github.com"* ]] ; then
        echo "-----------------------------------------------------"
        echo "register ssh key to $url (title: $title)"
        echo "private token : $private_token"
        echo "ssh key : $ssh_key"
        echo "-----------------------------------------------------"
        ssh_key_data=$(create_ssh_key_data $title "${ssh_key}")
        curl -i -H "Authorization: token $private_token" -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "$ssh_key_data" "https://api.github.com/user/keys"
    elif [[ $url == *"gitlab"* ]] ; then
        echo "-----------------------------------------------------"
        echo "register ssh key to $url (title: $title)"
        echo "private token : $private_token"
        echo "ssh key : $ssh_key"
        echo "-----------------------------------------------------"
        ssh_key_data=$(create_ssh_key_data $title "${ssh_key}")
		curl -i -H "Private-Token: $private_token" -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "$ssh_key_data" "https://$url/api/v4/user/keys"
    else
        echo "-----------------------------------------------------"
        echo "[register ssh key] not supported : $url"
        echo "-----------------------------------------------------"
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

    local file_name=.gitconfig_$name
    local config_path=$HOME/$file_name

    echo "------------------------------------------------------------"
    echo "create ${file_name} & add Host info to ~/.ssh/config"
    echo "------------------------------------------------------------"

    # create .gitconfig_$name
    safe_delete $config_path
    echo "[user]" >> $config_path
    echo "\temail = $user_email" >> $config_path
    echo "\tname = $user_name" >> $config_path
    if [ $url != "github.com" ] && [ $url != "gitlab.com" ] ; then
        echo "[url \"git@$url:\"]" >> $config_path
        echo "\tinsteadof = https://$url/" >> $config_path
    fi

    # add includeIf path to .gitconfig
    local gitconfig_path=$HOME/.gitconfig
    for p in $include_paths; do
        local real_path=$(eval echo $p)
        echo "---------------------------"
        echo "include path : $real_path"
        echo "---------------------------"
        mkdir -p $real_path
        local include_info="[includeIf \"gitdir:$real_path/\"]"
        echo "include info: $include_info"
        echo "---------------------------"
        local count=$(grep -cF "$include_info" $gitconfig_path)
        if [ $count -eq 0 ] ; then
            echo "add include_info : $include_info"
            echo "---------------------------"
            echo $include_info >> $gitconfig_path
            echo "\tpath = $file_name" >> $gitconfig_path
        fi
    done

    # add Host info to ~/.ssh/config
    local sshconfig_path=$HOME/.ssh/config
    local host_info="Host $url"
    local is_contains=false
    if [ -f $sshconfig_path ] ; then
        local count=$(grep -c "$host_info" $sshconfig_path)
        if [ $count -eq 0 ] ; then
            is_contains=false
        else
            is_contains=true
        fi
    else
        is_contains=false
    fi
    if [ $is_contains = false ] ; then
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
        local include_paths=`cat $config_path | jq -r ".git_organization | .[] | select(.name==\"${n}\") | .include_paths[]"`
        
        # create git config
        create_git_config $n $url $user_name $user_email "${include_paths[@]}"

        # ssh keygen
        local save_path="$HOME/.ssh/id_rsa_$n"
        ssh_keygen $user_email $save_path

        # register ssh key
        register_ssh_key $n $url $private_token
    done
}

#install_process_git_organization ../config.json
