#!/usr/bin/env fish


#source util.sh
#|| log_error $error_msg
function cmd_with_expect_pw
    set -l cmd (eval echo $argv[1])
    set -l pw $argv[2]
expect <<EOF
set timeout 120
spawn $cmd
expect "Password:" { send "$pw\n"; expect eof }
EOF
end

function install_process_brew
    set -l config_path $argv[1]
    set -l pw $argv[2]

    echo_title "Install Process brew :: brew tap"
    set -l brew_taps (cat $config_path | jq -r ".brew | .taps[]")
    for t in $brew_taps
        log "brew tap $t"
        brew tap $t || log_error "[brew] fail brew tap $t"
    end
    echo_title "Install Process brew :: brew install --cask"
    set -l brew_casks (cat $config_path | jq -r ".brew | .casks[]")
    for c in $brew_casks
        log "brew install --cask : $c"
        cmd_with_expect_pw "brew install --cask $c" $pw
    end
    echo_title "Install Process brew :: brew install"
    set -l brew_brews (cat $config_path | jq -r ".brew | .brews[]")
    for b in $brew_brews
        log "brew install : $b"
        cmd_with_expect_pw "brew install $b " $pw
    end
end

#install_process_brew ../config.json TEST_PASSWORD
