#!/usr/bin/env fish


#source util.sh

function install_process_mas
    set -l config_path $argv[1]
    
    echo_title "Install Process mas"

    # app name 에 띄어쓰기가 있을 수 있어 아래와 같이 loop 를 돌려야한다.
    cat $config_path | jq -c '.mas[]' | while read app_name
        log "[mas] install $app_name"
        mas lucky "$app_name" || log_error "[mas] install fail :: $app_name"
    end
end

# install_process_mas ../config.json
