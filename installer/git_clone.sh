#!/bin/sh

function git_clone() {
    local url=$1
    local branch=$2
    local recursive=$3
    local dest_path=$4

    local recursive_opt=""
    if [ $recursive==true ] ; then
        recursive_opt="--recursive"
    fi
    local branch_opt="-b ${branch}"

    echo "-----------------------------------------------------------------------"
    echo "git clone ${recursive_opt} ${branch_opt} ${url} ${dest_path}"
    echo "-----------------------------------------------------------------------"

    git clone $(eval echo $recursive_opt) $(eval echo $branch_opt) $url $dest_path
}


function install_process_git_clone() {
    local config_path=$1

    local git_repo_urls=`cat $config_path | jq -r ".git_clone | .[].ssh_url"`
    for u in $git_repo_urls; do
        local branch=`cat $config_path | jq -r ".git_clone | .[] | select(.ssh_url==\"${u}\") | .branch"`
        local recursive=`cat $config_path | jq -r ".git_clone | .[] | select(.ssh_url==\"${u}\") | .recursive"`
        local dest_path=`cat $config_path | jq -r ".git_clone | .[] | select(.ssh_url==\"${u}\") | .dest_path"`

        git_clone $u $branch $recursive $(eval echo $dest_path)
    done
}

#install_process_git_clone ../config.json
