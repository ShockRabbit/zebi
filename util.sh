#!/bin/sh

LIGHT_RED="\033[1;31m"
LIGHT_GREEN="\033[1;32m"
LIGHT_CYAN="\033[1;36m"
NO_COLOR="\033[0m"

BORDER_LINE="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
PADDING="                  "
BORDER_LT="┏"
BORDER_RT="┓"
BORDER_LB="┗"
BORDER_RB="┛"
PADDING="                  "

function echo_title() {
    str=$1
    len=${#str}
    padding_len=${#PADDING}
    width=len+padding_len*2
    
    echo ""
    echo "${LIGHT_GREEN}${BORDER_LT}${BORDER_LINE:0:$width}${BORDER_RT}"
    echo "┃${PADDING}${str}${PADDING}┃"
    echo "${BORDER_LB}${BORDER_LINE:0:$width}${BORDER_RB}${NO_COLOR}"
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

function safe_append_config() {
    config_line=$1
    shell_config_file=$2

    if grep "${config_line}" $shell_config_file>/dev/null; then
        echo "${config_line} already exist in ${shell_config_file}"
    else
        echo "${config_line}" >> $shell_config_file
    fi
}

function is_exist_cmd() {
    target_cmd=$1
    if ! command -v $target_cmd &> /dev/null; then
        echo "not exist"
        # return false
    else
        echo "exist"
        # return true
    fi
}


if [ -f "log_error.txt" ]; then
    rm log_error.txt
fi
