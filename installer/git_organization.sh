#!/bin/sh

#source util.sh

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

    log "generate ssh key (${email}) : ${save_path}"
expect <<EOF
set timeout 1
spawn ssh-keygen -t ed25519 -C $email
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

    local ssh_path=$HOME/.ssh/id_ed25519_$name.pub
    local title="${USER}_${name}"
    local ssh_key=$(cat $ssh_path)

    if [[ $url == *"github.com"* ]]; then
        log "-----------------------------------------------------"
        log "register ssh key to $url (title: $title)"
        log "private token : $private_token"
        log "ssh key : $ssh_key"
        log "-----------------------------------------------------"
        ssh_key_data=$(create_ssh_key_data $title "${ssh_key}")
        curl -f -i -H "Authorization: token $private_token" -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "$ssh_key_data" "https://api.github.com/user/keys" || log_error "[git_organization] fail register ssh key to $url (title: $title)"
    elif [[ $url == *"gitlab"* ]]; then
        log "-----------------------------------------------------"
        log "register ssh key to $url (title: $title)"
        log "private token : $private_token"
        log "ssh key : $ssh_key"
        log "-----------------------------------------------------"
        ssh_key_data=$(create_ssh_key_data $title "${ssh_key}")
		curl -f -i -H "Private-Token: $private_token" -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "$ssh_key_data" "https://$url/api/v4/user/keys" || log_error "[git_organization] fail register ssh key to $url (title: $title)"
    else
        log_error "[git_organization] register ssh key not supported : $url"
    fi
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

    log "create ${file_name} & add Host info to ~/.ssh/config"

    # create .gitconfig_$name
    safe_delete $config_path
    echo "[user]" >> $config_path
    echo "\temail = $user_email" >> $config_path
    echo "\tname = $user_name" >> $config_path
    if [ $url != "github.com" ] && [ $url != "gitlab.com" ]; then
        echo "[url \"git@$url:\"]" >> $config_path
        echo "\tinsteadof = https://$url/" >> $config_path
    fi

    # add includeIf path to .gitconfig
    local gitconfig_path=$HOME/.gitconfig
    if [ ! -f $gitconfig_path ]; then
        touch $gitconfig_path
    fi
    for p in $include_paths; do
        local real_path=$(eval echo $p)
        log "include path : $real_path"
        mkdir -p $real_path
        local include_info="[includeIf \"gitdir:$real_path/\"]"
        log "include info: $include_info"
        local count=$(grep -cF "$include_info" $gitconfig_path)
        if [ $count -eq 0 ]; then
            log "add include_info : $include_info"
            echo $include_info >> $gitconfig_path
            echo "\tpath = $file_name" >> $gitconfig_path
        fi
    done

    # add Host info to ~/.ssh/config
    if [ ! -d $HOME/.ssh ]; then
        mkdir $HOME/.ssh
    fi
    local sshconfig_path=$HOME/.ssh/config
    local host_info="Host $url"
    local is_contains=false
    if [ -f $sshconfig_path ]; then
        local count=$(grep -c "$host_info" $sshconfig_path)
        if [ $count -eq 0 ]; then
            is_contains=false
        else
            is_contains=true
        fi
    else
        touch $sshconfig_path
        is_contains=false
    fi
    if [ $is_contains = false ]; then
        echo $host_info >> $sshconfig_path
        echo "\tHostname $url" >> $sshconfig_path
        echo "\tUser git" >> $sshconfig_path
        echo "\tIdentityFile ~/.ssh/id_ed25519_$name" >> $sshconfig_path
        echo "\tIdentitiesOnly=yes" >> $sshconfig_path
    else
        local new_host_info="Host $url_$name"
        echo "$host_info is already exist. add $new_host_info instead of $host_info"

        echo $new_host_info >> $sshconfig_path
        echo "\tHostname $url" >> $sshconfig_path
        echo "\tUser git" >> $sshconfig_path
        echo "\tIdentityFile ~/.ssh/id_ed25519_$name" >> $sshconfig_path
        echo "\tIdentitiesOnly=yes" >> $sshconfig_path
    fi
}


function install_process_git_organization() {
    local config_path=$1

    echo_title "Install Process git_organization"

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
        local save_path="$HOME/.ssh/id_ed25519_$n"
        ssh_keygen $user_email $save_path

        # register ssh key
        register_ssh_key $n $url $private_token
    done
}

#install_process_git_organization ../config.json
