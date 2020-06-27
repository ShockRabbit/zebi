#!/bin/sh

#source util.sh

function install_process_pyenv() {
    local config_path=$1

    echo_title "Install Process pyenv"
    
    # install pyenv & pyenv-virtualenv
    brew install pyenv || log_error "[pyenv] fail :: brew install pyenv"
    brew install pyenv-virtualenv || log_error "[pyenv] fail :: brew install pyenv-virtualenv"

    ###################################################################################
    # Setup
    #
    # add pyenv init to shell
    # FIXME 추후 shell type 에 따라서 수정할 설정 파일을 바꿔야할 듯..
    shell_config_file=$(get_shell_config_file)
    echo 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> $shell_config_file
    # Restart shell
    #exec "$SHELL"
    source $shell_config_file
    # install python build dependencies (optional, but recommended)
    brew install openssl || log_error "[pyenv] fail :: brew install openssl"
    brew install readline || log_error "[pyenv] fail :: brew install readline"
    brew install sqlite3 || log_error "[pyenv] fail :: brew install sqlite3"
    brew install xz || log_error "[pyenv] fail :: brew install xz"
    brew install zlib || log_error "[pyenv] fail :: brew install zlib"
    ###################################################################################

    # pyenv_env_infos.json file 읽어들여 environments 생성 및 packages 설치
    local global=`cat $config_path | jq -r ".pyenv | .global"`
    local versions=`cat $config_path | jq -r ".pyenv | .versions[].version"`
    for v in $versions; do
        log "create pyenv python version ${v}"
        pyenv install $v || log_error "[pyenv] fail :: create pyenv python version ${v}"
        
        local names=`cat $config_path | jq -r ".pyenv | .versions[] | select(.version==\"${v}\") | .envs[].name"`
        for n in $names; do
            log "create env ${n} in python version ${v}"
            pyenv virtualenv $v $n || log_error "[pyenv] fail :: create env ${n} in python version ${v}"
            pyenv activate $n || log_error "[pyenv] fail :: pyenv activate $n"
            
            local packages=`cat $config_path | jq -r ".pyenv | .versions[] | select(.version==\"${v}\") | .envs[] | select(.name==\"${n}\") | .packages[]"`
            for p in $packages; do
                log "pip install ${p}"
                pip install $p || log_error "[pyenv] fail :: pip install $p"
            done
        done
    done
    # check and set default env
    log "set default version : ${global}"
    pyenv global $global || log_error "[pyenv] fail :: pyenv global $global"
    pyenv activate $global # brew install 은 항상 default env 에서 이뤄져야 하므로 activate 한다.
}

#install_process_pyenv ../config.json
