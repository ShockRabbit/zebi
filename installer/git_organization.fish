#!/usr/bin/env fish


#source util.sh

function safe_delete
    set -l path $argv[1]
    if [ -f $path ]
        rm $path
    end
end

function ssh_keygen
    set -l email $argv[1]
    set -l save_path $argv[2]
    set -l pub_file $save_path.pub
    safe_delete $save_path
    safe_delete $pub_file

    log "generate ssh key ($email) : $save_path"
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
end

function create_ssh_key_data
    set JSON_STRING ( jq -n \
                      --arg t "$argv[1]" \
                      --arg k "$argv[2]" \
					  '{ title: $t, key: $k }' )
	echo $JSON_STRING
end

function register_ssh_key
    set -l name $argv[1]
    set -l url $argv[2]
    set -l private_token $argv[3]

    set -l ssh_path $HOME/.ssh/id_rsa_$name.pub
    set -l title "$USER_$name"
    set -l ssh_key (cat $ssh_path)

    if [ (string match "*github.com*" $url) ]
        log "-----------------------------------------------------"
        log "register ssh key to $url (title: $title)"
        log "private token : $private_token"
        log "ssh key : $ssh_key"
        log "-----------------------------------------------------"
        set -l ssh_key_data (create_ssh_key_data $title "$ssh_key")
        curl -f -i -H "Authorization: token $private_token" -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "$ssh_key_data" "https://api.github.com/user/keys" || log_error "[git_organization] fail register ssh key to $url (title: $title)"
    else if [ (string match "*gitlab*" $url) ]
        log "-----------------------------------------------------"
        log "register ssh key to $url (title: $title)"
        log "private token : $private_token"
        log "ssh key : $ssh_key"
        log "-----------------------------------------------------"
        set -l ssh_key_data (create_ssh_key_data $title "$ssh_key")
		curl -f -i -H "Private-Token: $private_token" -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "$ssh_key_data" "https://$url/api/v4/user/keys" || log_error "[git_organization] fail register ssh key to $url (title: $title)"
    else
        log_error "[git_organization] register ssh key not supported : $url"
    end
end

function create_git_config
    # not support bitbucket && [ $url != "bitbucket.org" ] 
    set -l name $argv[1]
    set -l url $argv[2]
    set -l user_name $argv[3]
    set -l user_email $argv[4]
    set -l include_paths $argv[5]

    set -l file_name .gitconfig_$name
    set -l config_path $HOME/$file_name

    log "create $file_name & add Host info to ~/.ssh/config"

    # create .gitconfig_$name
    safe_delete $config_path
    echo "[user]" >> $config_path
    echo "\temail = $user_email" >> $config_path
    echo "\tname = $user_name" >> $config_path
    if [ $url != "github.com" ] && [ $url != "gitlab.com" ]
        echo "[url \"git@$url:\"]" >> $config_path
        echo "\tinsteadof = https://$url/" >> $config_path
    end

    # add includeIf path to .gitconfig
    set -l gitconfig_path $HOME/.gitconfig
    for p in $include_paths
        set -l real_path (eval echo $p)
        log "include path : $real_path"
        mkdir -p $real_path
        set -l include_info "[includeIf \"gitdir:$real_path/\"]"
        log "include info: $include_info"
        set -l count (grep -cF "$include_info" $gitconfig_path)
        if [ $count -eq 0 ]
            log "add include_info : $include_info"
            echo $include_info >> $gitconfig_path
            echo "\tpath = $file_name" >> $gitconfig_path
        end
    end

    # add Host info to ~/.ssh/config
    set -l sshconfig_path $HOME/.ssh/config
    set -l host_info "Host $url"
    set -l is_contains false
    if [ -f $sshconfig_path ]
        set -l count (grep -c "$host_info" $sshconfig_path)
        if [ $count -eq 0 ]
            is_contains=false
        else
            is_contains=true
        end
    else
        is_contains=false
    end
    if [ $is_contains = false ]
        echo $host_info >> $sshconfig_path
        echo "\tHostname $url" >> $sshconfig_path
        echo "\tUser git" >> $sshconfig_path
        echo "\tIdentityFile ~/.ssh/id_rsa_$name" >> $sshconfig_path
        echo "\tIdentitiesOnly=yes" >> $sshconfig_path
    end
end


function install_process_git_organization
    set -l config_path $argv[1]

    echo_title "Install Process git_organization"

    set -l git_names (cat $config_path | jq -r ".git_organization | .[].name")
    for n in $git_names
        set -l url (cat $config_path | jq -r ".git_organization | .[] | select(.name==\"$n\") | .url")
        set -l user_name (cat $config_path | jq -r ".git_organization | .[] | select(.name==\"$n\") | .user_name")
        set -l user_email (cat $config_path | jq -r ".git_organization | .[] | select(.name==\"$n\") | .user_email")
        set -l private_token (cat $config_path | jq -r ".git_organization | .[] | select(.name==\"$n\") | .private_token")
        set -l include_paths (cat $config_path | jq -r ".git_organization | .[] | select(.name==\"$n\") | .include_paths[]")
        
        # create git config
        create_git_config $n $url $user_name $user_email "$include_paths"

        # ssh keygen
        set -l save_path "$HOME/.ssh/id_rsa_$n"
        ssh_keygen $user_email $save_path

        # register ssh key
        register_ssh_key $n $url $private_token
    end
end

#install_process_git_organization ../config.json
