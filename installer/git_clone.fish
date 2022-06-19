#!/usr/bin/env fish


#source util.sh

function git_clone_with_expect
    set -l cmd (eval echo $argv[1])
expect <<EOF
set timeout 120
spawn $cmd
expect "Are you sure you want to continue connecting (yes/no)?" { send "yes\n"; expect eof }
EOF
end

function git_clone
    set -l url $argv[1]
    set -l branch $argv[2]
    set -l recursive $argv[3]  # 1(true) or 0(false)
    set -l dest_path $argv[4]

    set -l recursive_opt ""
    if [ $recursive -eq 1 ]
        recursive_opt="--recursive"
    end
    set -l branch_opt "-b $branch"

    log "git clone $recursive_opt $branch_opt $url $dest_path"

    # expect 써야해서 log_error 는 포기 ..
    #git clone $(eval echo $recursive_opt) $(eval echo $branch_opt) $url $dest_path || log_error "[git_clone] fail git clone $recursive_opt $branch_opt $url $dest_path"
    set -l cmd (git clone (eval echo $recursive_opt) (eval echo $branch_opt) $url $dest_path)
    git_clone_with_expect $cmd
end


function install_process_git_clone
    set -l config_path $argv[1]

    echo_title "Install Process git_clone"

    set -l git_repo_urls (cat $config_path | jq -r ".git_clone | .[].ssh_url")
    for u in $git_repo_urls
        set -l branch (cat $config_path | jq -r ".git_clone | .[] | select(.ssh_url==\"${u}\") | .branch")
        set -l recursive (cat $config_path | jq -r "if .git_clone | .[] | select(.ssh_url==\"${u}\") | .recursive than 1 else 0 end")
        set -l dest_path (cat $config_path | jq -r ".git_clone | .[] | select(.ssh_url==\"${u}\") | .dest_path")

        git_clone $u $branch $recursive (eval echo $dest_path)
    end
end

#install_process_git_clone ../config.json
