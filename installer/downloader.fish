#!/usr/bin/env fish


#source ../util.sh

function install_process_downloader
    set -l config_path $argv[1]

    echo_title "Install Process downloader"

    # download by curl
    set -l urls (cat $config_path | jq -r ".downloader | .[].url")
    for u in $urls
        set -l dest_path (cat $config_path | jq -r ".downloader | .[] | select(.url==\"$u\") | .dest_path")
        set -l use_redirect (cat $config_path | jq -r "if .downloader | .[] | select(.url==\"$u\") | .use_redirect then 1 else 0 end")
        log "Download(use redirect: $use_redirect) from $u to $dest_path"
        if [ $use_redirect -eq 1 ]
            curl -L $u -o (eval echo $dest_path)
        else
            curl $u -o (eval echo $dest_path)
        end
    end
end

##install_process_downloader ../config.json
