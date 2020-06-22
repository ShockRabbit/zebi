#!/bin/sh

function install_process_pyenv() {
    local config_path=$1
    
    # install pyenv & pyenv-virtualenv
    brew install pyenv
    brew install pyenv-virtualenv

    # pyenv_env_infos.json file 읽어들여 environments 생성 및 packages 설치
    local versions=`cat $config_path | jq -r ".pyenv | .versions[].version"`
    local global=`cat $config_path | jq -r ".pyenv | .global"`
    for v in $versions; do
        echo_title "create pyenv python version ${v}"
        pyenv install $v
        local names=`cat $config_path | jq -r ".pyenv | .versions[] | select(.version==\"${v}\") | .envs[].name"`
        for n in $names; do
            echo_title "create env ${n} in python version ${v}"
            pyenv virtualenv $v $n
            source activate $n
            
            local pkgs=`cat $config_path | jq -r ".pyenv | .versions[] | select(.version==\"${v}\") | .envs[] | select(.name==\"${n}\") | .packages"`
            echo_title "install python packages by ${pkgs}"
            pip install -r $pkgs
        done
    done
    # check and set default env
    echo_title "set default version : ${global}"
    pyenv global $global
    source activate $global # brew install 은 항상 default env 에서 이뤄져야 하므로 activate 한다.
}
