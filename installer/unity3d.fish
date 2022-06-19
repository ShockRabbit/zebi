#!/usr/bin/env fish


#source util.sh

function expect_install_unity
    set -l version $argv[1]
    set -l parms $argv[2]
    set -l pw $argv[3]

expect <<EOF
set timeout 12000
spawn install-unity install $v -p (eval echo $parms)
expect "assword:" { send "$pw\n"; expect eof }
EOF
end

function expect_install_unityhub
    set -l unity_hub_volume $argv[1]
    set -l pw $argv[2]
expect <<EOF
set timeout 360
spawn sudo cp -r "$unity_hub_volume/Unity Hub.app" /Applications/
expect "assword:" { send "$pw\n"; expect eof }
EOF
end

function install_process_unity3d
    set -l config_path $argv[1]
    set -l pw $argv[2]

    echo_title "Install Process unity3d"

    # install unity
    brew tap sttz/homebrew-tap || log_error "[unity3d] fail :: brew tap sttz/homebrew-tap"
    brew install install-unity || log_error "[unity3d] fail :: brew install install-unity"

    set -l versions (cat $config_path | jq -r ".unity3d | .[].version")
    for v in $versions
        set -l platforms (cat $config_path | jq -r ".unity3d | .[] | select(.version==\"$v\") | .platforms[]")
        set -l parms "Unity"
        for p in $platforms
            parms="$parms $p"
        end
        log "Install Unity3d $v : $parms"
        expect_install_unity $v "$parms" $pw
    end

    # install unity hub
    set -l temp_path ./temp_for_installer
    set -l unityhub_temp_path $temp_path/unityhub
    set -l unityhub_dmg_path $unityhub_temp_path/unityhub.dmg
    if [ ! -d "$unityhub_temp_path" ]
        mkdir $unityhub_temp_path
    end
    wget -O $unityhub_dmg_path https://public-cdn.cloud.unity3d.com/hub/prod/UnityHubSetup.dmg?_ga=2.94759900.1548080849.1564613839-779318739.1514968130 || log_error "[unity3d] fail :: fail download unityhub dmg"
    hdiutil attach $unityhub_dmg_path

    for entry in /Volumes/*
        if [ (string match "*Unity Hub*" $entry) ]
            echo "$entry"
            log "Install Unity Hub"
            expect_install_unityhub "$entry" $pw
            hdiutil unmount "$entry"
        end
    end
end

#install_process_unity3d ../config.json TEST_PASSWORD
