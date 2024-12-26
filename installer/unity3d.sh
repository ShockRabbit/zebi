#!/bin/sh

#source util.sh


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

function expect_rm_aos_modules() {
    local version=$1

expect <<EOF
set timeout 12000
spawn sudo rm -rf /Applications/Unity/Hub/Editor/{$version}/PlaybackEngines/AndroidPlayer/SDK
expect "assword:"
send "$pw\n"
spawn sudo rm -rf /Applications/Unity/Hub/Editor/{$version}/PlaybackEngines/AndroidPlayer/NDK
expect "assword:"
send "$pw\n"
spawn sudo rm -rf /Applications/Unity/Hub/Editor/{$version}/PlaybackEngines/AndroidPlayer/OpenJDK
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

function install_install_unity_from_brew() {
    brew install --cask sttz/tap/install-unity || log_error "[unity3d] fail :: brew install sttz/tap/install-unity"
    echo "install-unity"
}

function install_process_unity3d() {
    if [ -d "/Applications/Unity Hub.app" ]; then
        log "Already installed Unity Hub"
    else
        # install unity hub
        brew install --cask unity-hub
    fi

    mkdir -p /Applications/Unity/Hub/Editor/

    local config_path=$1
    local pw=$2

    echo_title "Install Process unity3d"

    # install unity
    install_unity_cmd=$(install_install_unity_from_brew)
    echo "------------------------------------"
    echo $install_unity_cmd
    echo "------------------------------------"

    local versions=`cat $config_path | jq -r ".unity3d | .[].version"`
    for v in $versions; do
        local aos_minimal=`cat $config_path | jq -r "if .unity3d | .[] | select(.version==\"${v}\") | .aos_minimal then 1 else 0 end"`
        local platforms=`cat $config_path | jq -r ".unity3d | .[] | select(.version==\"${v}\") | .platforms[]"`
        local parms="Unity"
        for p in $platforms; do
            parms="${parms} ${p}"
        done
        
        log "Install Unity3d $v : $parms"
        expect_install_unity $install_unity_cmd $v "${parms}" $pw
        # rename
        from="/Applications/Unity_${version:0:6}"
        to="/Applications/Unity/Hub/Editor/${version}"
        mv $from $to

        if [ $aos_minimal -eq 1 ]; then
            log "aos_minimal option is true. remove android sdk, ndk, openjdk in unity PlaybackEngines/AndroidPlayer"
            expect_rm_aos_modules $v
        fi
    done
}

#install_process_unity3d ../config.json TEST_PASSWORD
