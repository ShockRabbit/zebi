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
    # add settings to shell config
    shell_config_file=$(get_shell_config_file)

    safe_append_config 'export PYENV_ROOT="$HOME/.pyenv"' $shell_config_file
    safe_append_config 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' $shell_config_file
    safe_append_config 'eval "$(pyenv init -)"' $shell_config_file

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
        if [ -d "$HOME/.pyenv/versions/${v}" ]; then
            log "already has python version ${v}"
        else
            log "install python version ${v}"
            pyenv install $v || log_error "[pyenv] fail :: create pyenv python version ${v}"
        fi
        
        local names=`cat $config_path | jq -r ".pyenv | .versions[] | select(.version==\"${v}\") | .envs[].name"`
        for n in $names; do
            log "create env ${n} in python version ${v}"

            if [ -d "$HOME/.pyenv/versions/${v}/envs/${n}" ]; then
                log "already has env ${n}"
            else
                log "create env ${n}"
                pyenv virtualenv $v $n || log_error "[pyenv] fail :: create env ${n} in python version ${v}"
            fi

            log "activate env ${n}"
            pyenv local $n || log_error "[pyenv] fail :: pyenv local $n"
            
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
    pyenv local $global # brew install 은 항상 default env 에서 이뤄져야 하므로 activate 한다.
}

#install_process_pyenv ../config.json
