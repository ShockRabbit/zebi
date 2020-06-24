#!/bin/sh

function install_process_pyenv() {
    local config_path=$1
    
    # install pyenv & pyenv-virtualenv
    brew install pyenv
    brew install pyenv-virtualenv

    # pyenv_env_infos.json file 읽어들여 environments 생성 및 packages 설치
    local global=`cat $config_path | jq -r ".pyenv | .global"`
    local versions=`cat $config_path | jq -r ".pyenv | .versions[].version"`
    for v in $versions; do
        echo "-------------------------------------------------"
        echo "create pyenv python version ${v}"
        echo "-------------------------------------------------"
        pyenv install $v
        
        local names=`cat $config_path | jq -r ".pyenv | .versions[] | select(.version==\"${v}\") | .envs[].name"`
        for n in $names; do
            echo "-------------------------------------------------"
            echo "create env ${n} in python version ${v}"
            echo "-------------------------------------------------"
            pyenv virtualenv $v $n
            source activate $n
            
            local packages=`cat $config_path | jq -r ".pyenv | .versions[] | select(.version==\"${v}\") | .envs[] | select(.name==\"${n}\") | .packages[]"`
            for p in $packages; do
                echo "install ${p}"
                pip install $p
            done
        done
    done
    # check and set default env
    echo "-------------------------------------------------"
    echo "set default version : ${global}"
    echo "-------------------------------------------------"
    pyenv global $global
    source activate $global # brew install 은 항상 default env 에서 이뤄져야 하므로 activate 한다.
}

#install_process_pyenv ../config.json
