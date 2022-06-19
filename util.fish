#!/usr/local/bin/fish


set LIGHT_RED "\033[1;31m"
set LIGHT_GREEN "\033[1;32m"
set LIGHT_CYAN "\033[1;36m"
set NO_COLOR "\033[0m"

set BORDER_LINE "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
set PADDING "                  "
set BORDER_LT "┏"
set BORDER_RT "┓"
set BORDER_LB "┗"
set BORDER_RB "┛"
set PADDING "                  "


function echo_title
    set -l str $argv[1]
    set -l len (string length $str)
    set -l padding_len (string length $PADDING)
    set -l width (math $len + $padding_len x 2)

    set -l top_border (string sub -s 1 -e $width $BORDER_LINE)
    set -l bottom_border (string sub -s 1 -e $width $BORDER_LINE)
    
    set_color green
    echo -e "$BORDER_LT$top_border$BORDER_RT\n┃$PADDING$str$PADDING┃\n$BORDER_LB$bottom_border$BORDER_RB"
    set_color normal
end

function log
    set -l str argv[1]
    set_color cyan
    echo "[Installer_Log]:: $str"
    set_color normal
end

function log_error
    set -l str argv[1]
    set_color red
    echo "[Installer_LogError]:: $str" 
    set_color normal
    echo $str >> log_error.txt
end

function get_shell_config_file
    if [[ $SHELL == *"bash" ]]; then
        path=~/.bash_profile
    elif [[ $SHELL == *"zsh" ]]; then
        path=~/.zshrc 
    elif [[ $SHELL == *"fish" ]]; then
        path=~/.config/fish/config.fish
    else
        log_error "[pyenv] fail :: not supported shell type"
        path=~/.bash_profile
    fi
    echo $path
end


if test -e log_error.txt
    rm log_error.txt
end
