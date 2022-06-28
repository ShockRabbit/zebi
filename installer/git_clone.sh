#!/bin/sh

#source util.sh

function git_clone_with_expect() {
    local cmd=$(eval echo $1)
expect <<EOF
set timeout 120
spawn $cmd
expect "(yes/no" { send "yes\n"; expect eof }
EOF
}

function git_clone() {
    local url=$1
    local branch=$2
    local recursive=$3  # 1(true) or 0(false)
    local dest_path=$4

    local recursive_opt=""
    if [ $recursive -eq 1 ]; then
        recursive_opt="--recursive"
    fi
    local branch_opt="-b ${branch}"

    log "git clone ${recursive_opt} ${branch_opt} ${url} ${dest_path}"

    # expect 써야해서 log_error 는 포기 ..
    #git clone $(eval echo $recursive_opt) $(eval echo $branch_opt) $url $dest_path || log_error "[git_clone] fail git clone $recursive_opt $branch_opt $url $dest_path"
    local cmd=$(git clone $(eval echo $recursive_opt) $(eval echo $branch_opt) $url $dest_path)
    git_clone_with_expect $cmd
}

function gitlab_group_clone() {
    local group_id=$1
    local private_token=$2
    local root_url=$3
    local branch=$4
    local recursive=$5
    local dest_path=$6

    local recursive_opt=""
    if [ $recursive -eq 1 ]; then
        recursive_opt="--recursive"
    fi
    local branch_opt="-b ${branch}"

    repos=$(curl -s --header "PRIVATE-TOKEN:${private_token}" $root_url/api/v4/groups/$group_id | jq ".projects[].ssh_url_to_repo" | tr -d '"')
    pushd $dest_path
    for repo in $repos ; do
        log "git clone ${recursive_opt} ${branch_opt} ${repo} ${dest_path}"
        local cmd=$(git clone $(eval echo $recursive_opt) $(eval echo $branch_opt) $repo)
        git_clone_with_expect $cmd
    done
    popd
}

function github_user_clone() {
    local user_name=$1
    local private_token=$2
    local branch=$3
    local recursive=$4
    local dest_path=$5

    local recursive_opt=""
    if [ $recursive -eq 1 ]; then
        recursive_opt="--recursive"
    fi
    local branch_opt="-b ${branch}"

    name_len=${#user_name}
    name_len=$((name_len+1))    # slash(/) 까지 고려해서 길이 계산
    repos=$(curl -s -H "Authorization: token ${private_token}" "https://api.github.com/user/repos" | jq -r ".[] | select(.full_name[:${name_len}]==\"${user_name}/\") | .ssh_url")
    pushd $dest_path
    for repo in $repos ; do
        log "git clone ${recursive_opt} ${branch_opt} ${repo} ${dest_path}"
        local cmd=$(git clone $(eval echo $recursive_opt) $(eval echo $branch_opt) $repo)
        git_clone_with_expect $cmd
    done
    popd
}

function install_process_git_clone() {
    local config_path=$1

    echo_title "Install Process git_clone"

    local names=`cat $config_path | jq -r ".git_clone | .[].name"`
    for n in $names; do
        local type=`cat $config_path | jq -r ".git_clone | .[] | select(.name==\"${n}\") | .type"`
        if [[ $type == "repository" ]]; then
            local ssh_url=`cat $config_path | jq -r ".git_clone | .[] | select(.name==\"${n}\") | .ssh_url"`
            local branch=`cat $config_path | jq -r ".git_clone | .[] | select(.name==\"${n}\") | .branch"`
            local recursive=`cat $config_path | jq -r "if .git_clone | .[] | select(.name==\"${n}\") | .recursive then 1 else 0 end"`
            local dest_path=`cat $config_path | jq -r ".git_clone | .[] | select(.name==\"${n}\") | .dest_path"`
            git_clone $ssh_url $branch $recursive $(eval echo $dest_path)
        elif [[ $type == "gitlab-group" ]]; then
            local group_id=`cat $config_path | jq -r ".git_clone | .[] | select(.name==\"${n}\") | .group_id"`
            local private_token=`cat $config_path | jq -r ".git_clone | .[] | select(.name==\"${n}\") | .private_token"`
            local root_url=`cat $config_path | jq -r ".git_clone | .[] | select(.name==\"${n}\") | .root_url"`
            local branch=`cat $config_path | jq -r ".git_clone | .[] | select(.name==\"${n}\") | .branch"`
            local recursive=`cat $config_path | jq -r "if .git_clone | .[] | select(.name==\"${n}\") | .recursive then 1 else 0 end"`
            local dest_path=`cat $config_path | jq -r ".git_clone | .[] | select(.name==\"${n}\") | .dest_path"`
            gitlab_group_clone $group_id $private_token $root_url $branch $recursive $(eval echo $dest_path)
        elif [[ $type == "github-user" ]]; then
            local user_name=`cat $config_path | jq -r ".git_clone | .[] | select(.name==\"${n}\") | .user_name"`
            local private_token=`cat $config_path | jq -r ".git_clone | .[] | select(.name==\"${n}\") | .private_token"`
            local branch=`cat $config_path | jq -r ".git_clone | .[] | select(.name==\"${n}\") | .branch"`
            local recursive=`cat $config_path | jq -r "if .git_clone | .[] | select(.name==\"${n}\") | .recursive then 1 else 0 end"`
            local dest_path=`cat $config_path | jq -r ".git_clone | .[] | select(.name==\"${n}\") | .dest_path"`
            github_user_clone $user_name $private_token $branch $recursive $(eval echo $dest_path)
        else
            log_error "[git_clone] fail :: not supported type (${type}). only support [repository, gitlab-group, github-user]"
        fi
    done
}

#install_process_git_clone ../config.json
