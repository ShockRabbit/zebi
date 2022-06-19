#!/usr/bin/env fish


#source util.sh

function install_process_rbenv
    set -l config_path $argv[1]
    
    echo_title "Install Process rbenv"

    brew install rbenv || log_error "[rbenv] fail :: brew install rbenv"
    brew install ruby-build || log_error "[rbenv] fail :: brew install ruby-build"
    
    ###################################################################################
    # Setup
    #
    # add rbenv init to shell
    # FIXME 추후 shell type 에 따라서 수정할 설정 파일을 바꿔야할 듯..
    set -l shell_config_file (get_shell_config_file)
    echo 'if command -v rbenv 1>/dev/null 2>&1; then\n  eval "$(rbenv init -)"\nfi' >> $shell_config_file
    # Restart shell
    source $shell_config_file
    ###################################################################################

    set -l versions (cat $config_path | jq -r ".rbenv | .versions[].version")
    set -l global (cat $config_path | jq -r ".rbenv | .global")

    for v in $versions
        log "rbenv install $v"
        rbenv install $v || log_error "[rbenv] fail :: rbenv install $v"
        rbenv local $v || log_error "[rbenv] fail :: rbenv local $v"
        set -l packages (cat $config_path | jq -r ".rbenv | .versions[] | select(.version==\"$v\") | .packages[]")
        for p in $packages
            log "gem install $p"
            gem install $p || log_error "[rbenv] fail :: gem install $p"
        end
    end
    rbenv global $global || log_error "[rbenv] fail :: rbenv global $global"
    rbenv local $global
end

# install_process_rbenv ../config.json
