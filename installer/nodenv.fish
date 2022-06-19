#!/usr/bin/env fish


#source util.sh

function install_process_nodenv
    set -l config_path $argv[1]

    echo_title "Install Process nodenv"
    
    brew install nodenv || log_error "[nodenv] fail :: brew install nodenv"
    brew install node-build || log_error "[nodenv] fali :: brew install node-build"

    ###################################################################################
    # Setup
    #
    # add nodenv init to shell
    # FIXME 추후 shell type 에 따라서 수정할 설정 파일을 바꿔야할 듯..
    set -l shell_config_file (get_shell_config_file)
    echo 'if command -v nodenv 1>/dev/null 2>&1; then\n  eval "$(nodenv init -)"\nfi' >> $shell_config_file
    # Restart shell
    #exec "$SHELL"
    source $shell_config_file
    ###################################################################################

    set -l versions (cat $config_path | jq -r ".nodenv | .versions[].version")
    set -l global (cat $config_path | jq -r ".nodenv | .global")

    for v in $versions
        log "nodenv install $v"
        nodenv install $v || log_error "[nodenv] fail :: nodenv install $v"
        nodenv local $v
        set -l packages (cat $config_path | jq -r ".nodenv | .versions[] | select(.version==\"${v}\") | .packages[]")
        for p in $packages
            log "npm install $p -g"
            npm install $p -g || log_error "[nodenv] fail :: npm install $p -g"
        end
    end
    log "nodenv global $global"
    nodenv global $global || log_error "[nodenv] fail :: nodenv global $global"
    nodenv local $global
end

# install_process_nodenv ../config.json
