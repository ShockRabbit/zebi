#!/bin/sh

#source util.sh

function expect_install_rosetta2() {
    local pw=$1
    has_rosetta=$(/usr/bin/pgrep -q oahd && echo Yes || echo No)
    if [[ $has_rosetta == "No" ]]; then
expect <<EOF
set timeout 12000
spawn sudo softwareupdate --install-rosetta
expect "assword:"
send "$pw\n"
expect "Type A and press return to agree:"
send "A\n"
expect eof
EOF
    fi
}

function expect_install_unity() {
    local install_unity_cmd=$1
    local version=$2
    local parms=$3
    local pw=$4

expect <<EOF
set timeout 12000
spawn $(eval echo $install_unity_cmd) install $v -p $(eval echo $parms)
expect "Do you agree to the above EULA"
send "y"
expect "assword:"
send "$pw\n"
expect eof
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

function install_install_unity_from_github() {
    local temp_path=./temp_for_installer
    local installer_temp_path=$temp_path/unity_installer
    local installer_zip_path=$installer_temp_path/unity_installer.zip
    local unity_installer=$installer_temp_path/install-unity
    if [ ! -d "$installer_temp_path" ]; then
        mkdir -p $installer_temp_path
    fi

    wget -O $installer_zip_path https://github.com/sttz/install-unity/releases/download/2.10.2/install-unity-2.10.2.zip
    unzip -q $installer_zip_path -d $installer_temp_path    # quiet 옵션을 안넣으면 unzip 관련 로그까지 return 되어버린다
    echo $unity_installer
}

function install_install_unity_from_brew() {
    # brew tap sttz/homebrew-tap || log_error "[unity3d] fail :: brew tap sttz/homebrew-tap"
    brew install sttz/tap/install-unity || log_error "[unity3d] fail :: brew install sttz/tap/install-unity"
    # brew install --cask sttz/tap/install-unity || log_error "[unity3d] fail :: brew install --cask sttz/tap/install-unity"
    echo "install-unity"
}

function install_process_unity3d() {
    is_wget_exist=$(is_exist_cmd wget)
    if [[ $is_wget_exist != "exist" ]]; then
        brew install wget
    fi

    local config_path=$1
    local pw=$2

    echo_title "Install Process unity3d"

    # install unity
    local cpu_type=$(uname -m)
    if [[ "$cpu_type" == "arm64" ]]; then
        # apple silicon
        # 근데 이렇게까지 했는데도 안된다 .. apple silicon 은 당분간은 포기하는걸로 ..
        install_unity_cmd=$(install_install_unity_from_github)
    else
        install_unity_cmd=$(install_install_unity_from_brew)
    fi
    echo "------------------------------------"
    echo $install_unity_cmd
    echo "------------------------------------"

    local versions=`cat $config_path | jq -r ".unity3d | .[].version"`
    for v in $versions; do
        local apple_silicon=`cat $config_path | jq -r ".unity3d | .[] | select(.version==\"${v}\") | .apple_silicon then 1 else 0 end"`
        local platforms=`cat $config_path | jq -r ".unity3d | .[] | select(.version==\"${v}\") | .platforms[]"`
        local parms="Unity"
        for p in $platforms; do
            parms="${parms} ${p}"
        done
        
        if [[ "$cpu_type" == "arm64" ]]; then
            if [ $apple_silicon -eq 1 ]; then
                parms="${parms} --platform macOSArm"
            else
                log "Install rosetta 2"
                expect_install_rosetta2 $pw
                parms="${parms} --platform macOSIntel"
            fi
        else
            if [ $apple_silicon -eq 1 ]; then
                log "apple_silicon option is true but your cpu type is not apple silicon then will install with macOSIntel option"
            fi
            parms="${parms} --platform macOSIntel"
        fi
        log "Install Unity3d $v : $parms"
        expect_install_unity $install_unity_cmd $v "${parms}" $pw
    done

    if [ -d "/Applications/Unity Hub.app" ]; then
        log "Already installed Unity Hub"
    else
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
                if [[ "$cpu_type" == "arm64" ]]; then
                    log "Install rosetta 2"
                    expect_install_rosetta2 $pw
                fi
                log "Install Unity Hub"
                expect_install_unityhub "${entry}" $pw
                hdiutil unmount "${entry}"
            fi
        done
    fi

}

#install_process_unity3d ../config.json TEST_PASSWORD
