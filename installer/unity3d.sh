#!/bin/sh

function install_process_unity3d() {
    local config_path=$1

    ## install unity
    local installer_temp_path=$temp_path/unity_installer
    local installer_zip_path=$installer_temp_path/unity_installer.zip
    local unity_installer=$installer_temp_path/install-unity
    if [ ! -d "$installer_temp_path" ]; then
        mkdir $installer_temp_path
    fi

    wget -O $installer_zip_path https://github.com/sttz/install-unity/releases/download/2.7.2/install-unity-2.7.2.zip
    unzip $installer_zip_path -d $installer_temp_path

    local versions=`cat $config_path | jq -r ".unity3d | .[].version"`
    for v in $versions; do
        local platforms=`cat $config_path | jq -r ".unity3d | .[] | select(.version==\"${v}\") | .platforms[]"`
        local parms="Unity"
        for p in $platforms; do
            $parms=" $parms $p"
        done
        $unity_installer install $v -p $parms
    done

    ## install unity hub
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
            sudo cp -r "${entry}/Unity Hub.app" /Applications/
            hdiutil unmount "${entry}"
        fi
    done
}
