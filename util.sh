#!/bin/sh

LIGHT_RED="\033[1;31m"
LIGHT_GREEN="\033[1;32m"
LIGHT_CYAN="\033[1;36m"
NO_COLOR="\033[0m"

BORDER_LINE="#####################################################################################################################################################"
PADDING="                  "

function echo_title() {
    str=$1
    len=${#str}
    padding_len=${#PADDING}
    width=2+len+padding_len*2
    
    echo "${LIGHT_GREEN}${BORDER_LINE:0:$width}"
    echo "#${PADDING}${str}${PADDING}#"
    echo "${BORDER_LINE:0:$width}${NO_COLOR}"
}

function log() {
    str=$1
    echo "${LIGHT_CYAN}[Installer_Log]:: ${str}${NO_COLOR}"
}

function log_error() {
    str=$1
    echo "${LIGHT_RED}[Installer_LogError]:: ${str}${NO_COLOR}" 
    echo $str >> log_error.txt
}

function get_shell_config_file() {
    if [[ $SHELL == *"bash" ]]; then
        path=~/.bash_profile
    elif [[ $SHELL == *"zsh" ]]; then
        path=~/.zshrc 
    else
        log_error "[pyenv] fail :: not supported shell type"
        path=~/.bash_profile
    fi
    echo $path
}


if [ -f "log_error.txt" ]; then
    rm log_error.txt
fi
