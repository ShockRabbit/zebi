#!/bin/sh

function expect_install_unity() {
    local version=$1
    local parms=$2
    local pw=$3

    echo "------------------------"
    echo $parms
    echo $pw
    echo "------------------------"
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

    # install unity
    brew tap sttz/homebrew-tap
    brew install install-unity

    local versions=`cat $config_path | jq -r ".unity3d | .[].version"`
    for v in $versions; do
        local platforms=`cat $config_path | jq -r ".unity3d | .[] | select(.version==\"${v}\") | .platforms[]"`
        local parms="Unity"
        for p in $platforms; do
            parms="${parms} ${p}"
        done
        echo "--------------------------------------------"
        echo "Install Unity3d $v : $parms"
        echo "--------------------------------------------"
        expect_install_unity $v "${parms}" $pw
    done

    # install unity hub
    local temp_path=./temp_for_installer
    local unityhub_temp_path=$temp_path/unityhub
    local unityhub_dmg_path=$unityhub_temp_path/unityhub.dmg
    if [ ! -d "$unityhub_temp_path" ]; then
        mkdir $unityhub_temp_path
    fi
    wget -O $unityhub_dmg_path https://public-cdn.cloud.unity3d.com/hub/prod/UnityHubSetup.dmg?_ga=2.94759900.1548080849.1564613839-779318739.1514968130
    hdiutil attach $unityhub_dmg_path

    for entry in /Volumes/*; do
        if [[ "$entry" == *"Unity Hub"* ]]; then
            echo "$entry"
            #FIXME 미리 root pw 받아서 막히지 않도록 처리 필요
            echo "--------------------------------------------"
            echo "Install Unity Hub"
            echo "--------------------------------------------"
            expect_install_unityhub "${entry}" $pw
            hdiutil unmount "${entry}"
        fi
    done
}

#install_process_unity3d ../config.json TEST_PASSWORD
