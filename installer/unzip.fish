#!/usr/bin/env fish


#source ../util.sh

function install_process_unzip
    set -l config_path $argv[1]

    echo_title "Install Process unzip"

    # mkdir and unzip
    set -l src_paths (cat $config_path | jq -r ".unzip | .[].src_path")
    for s in $src_paths
        set -l dest_path (cat $config_path | jq -r ".unzip | .[] | select(.src_path==\"$s\") | .dest_path")
        log "unzip $s to $dest_path"
        mkdir -p (eval echo $dest_path)
        unzip -d (eval echo $dest_path) -j (eval echo $s)
    end
end

#install_process_unzip ../config.json
