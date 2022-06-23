#!/bin/sh

#source util.sh

function expect_install_unity() {
    local version=$1
    local parms=$2
    local pw=$3

expect <<EOF
set timeout 12000
spawn install-unity install $v -p $(eval echo $parms)
expect "assword:" { send "$pw\n"; expect eof }
EOF
}

function expect_install_unityhub() {
    local unity_hub_volume=$1
    local pw=$2
expect <<EOF
set timeout 360
spawn sudo cp -r "${unity_hub_volume}/Unity Hub.app" /Applications/
expect "assword:" { send "$pw\n"; expect eof }
EOF
}

function install_process_unity3d() {
    local config_path=$1
    local pw=$2

    echo_title "Install Process unity3d"

    # install unity
    brew tap sttz/homebrew-tap || log_error "[unity3d] fail :: brew tap sttz/homebrew-tap"
    brew install install-unity || log_error "[unity3d] fail :: brew install install-unity"

    local versions=`cat $config_path | jq -r ".unity3d | .[].version"`
    for v in $versions; do
        local platforms=`cat $config_path | jq -r ".unity3d | .[] | select(.version==\"${v}\") | .platforms[]"`
        local parms="Unity"
        for p in $platforms; do
            parms="${parms} ${p}"
        done
        log "Install Unity3d $v : $parms"
        expect_install_unity $v "${parms}" $pw
    done

    # install unity hub
    local temp_path=./temp_for_installer
    local unityhub_temp_path=$temp_path/unityhub
    local unityhub_dmg_path=$unityhub_temp_path/unityhub.dmg
    if [ ! -d "$unityhub_temp_path" ]; then
        mkdir -p $unityhub_temp_path
    fi
    wget -O $unityhub_dmg_path https://public-cdn.cloud.unity3d.com/hub/prod/UnityHubSetup.dmg?_ga=2.94759900.1548080849.1564613839-779318739.1514968130 || log_error "[unity3d] fail :: fail download unityhub dmg"
    hdiutil attach $unityhub_dmg_path

    for entry in /Volumes/*; do
        if [[ "$entry" == *"Unity Hub"* ]]; then
            echo "$entry"
            log "Install Unity Hub"
            expect_install_unityhub "${entry}" $pw
            hdiutil unmount "${entry}"
        fi
    done
}

#install_process_unity3d ../config.json TEST_PASSWORD
