#!/bin/sh

function echo_title() {
    echo "------------------------------------------------------------------------"
    echo $1
    echo "------------------------------------------------------------------------"
}

function request_login_mas() {
    # Request login to Mac App Store
    echo_title "Login to Mac App Store"
    echo "you must login to Mac App Store"
    open -a "App Store"
    read -p "Press enter to continue after Login to Mac App Store"
}

function prepare_install() {
    local config_path=$1
    
    # 설치를 위해 필요한 것들을 설치한다. (brew, git, jq)
    # install Homebrew
    [ X`which brew` = X/usr/local/bin/brew ] || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

    # install git
    brew install git

    # install jq
    brew install jq

    # if order contains mas -> install mas
    order=`cat $config_path | jq -r ".order[]"`
    for o in $order; do
        if [[ $o == "mas" ]] ; then
            # install mas
            brew install mas
            request_login_mas
        fi
    done

}

# import all installer script
for entry in ./installer/*; do
    source $entry
done

# 설치를 위해 잠시 이용되는 temp dir 를 만든다.
temp_path=$HOME/temp_for_install
if [ ! -d "$temp_path" ]; then
    mkdir $temp_path
fi

config_path=./config.json

prepare_install $config_path

# execute install process by order
order=`cat $config_path | jq -r ".order[]"`
for o in $order; do
    if [[ $o == *".sh" ]] ; then
        sh $o
    else
        install_process_$o $config_path
    fi
done

# 0. install requirements
# 1. install pyenv
# 2-1. create git config & ssh config
# 2-2. ssh keygen & register ssh key
# 3. clone repository
# 4. install by mas
# 5. install by brew
# 6. install rbenv 
# 7. install unity & unity hub
# 8. install android sdk
# 9. install android ndk
# 10. install sdkman


# custom script 통해 처리할 것들
# npm (추후 javascript 비중 높아지면 포함)
# cocoapod
# configobj
# mps-youtube
# vim, zsh, tmux 
#   -> brew 로 처리된 듯? 그래도 혹시 모르니 관련된 것들 따로 설치 필요한 것은 없는지 확인
# osx 설정


# ----------------------------------------

# 4. stow dotfiles -> 이건 Hook 으로 따로 빼야할 듯
# stow 로 dotfiles 적용
# stow 대신 mackup 을 이용하는 것도 고려해볼만할 듯..
# - [lra/mackup: Keep your application settings in sync (OS X/Linux)](https://github.com/lra/mackup/)

# ---
# 이후 ...
# rbenv 설치
# npm 설치
# sdkman & gradle
# unity, unity hub
# cocoapod
# vim, zsh, tmux
# brew 로 설치할 수 있는 것들 다 설치
# - brew
#   - android sdkmanager
#       - android sdk, ndk
#   - font
# - cask
#   - alfred
#   - dropbox
#   - google drive (제외?)
#   - avast
#   - chrome
#   - doxygen
#   - audacity
#   - Go2Shell
#   - KeyCastr
#   - iTerm
#   - Dash
# - mas
#   - xcode
#       - 설치 완료 후 xcode-select --install 실행
#   - Affinity Designer
#   - Affinity Photo
#   - Slack
#   - Kakao Talk
#   - Quiver
#   - GIPHY CAPTURE
# Custom Install
# - configobj
# - mps-youtube (develop branch 사용등의 문제 때문)

# osX 설정들 가능한한 자동 설정
# - 확장자별 default app 설정


# 설치 완료 후 ToDo List
# - Avast 설치 완료 (권한 허용등 설정)
# - Chrome login
# - Dropbox login
# - Slack login
# - Go2Shell setting (직접 드래그해서 세팅해야 함)
# - set Sync Alfred, Dash, Quiver





# 이 파일은 dotfiles 보다 installer 라는 프로젝트로 따로 관리되어야할 것 같다..
# 또한 Token, 계정 정보등을 담은 private file 들을 installer 에 포함시키고 remote repository 없이 비공개로 관리되어야할 것 같다.
# (혹은 스크립트만 올려놓고, 요구되는 private file 들을 출력)

# backup helper 프로젝트도 필요할지도..? 
# ㄴ> no no .. backup 보다는 brew install, uninstall. pip install, uninstall 시 file 이 작성되도록 하면 좋을 것 같다.
# 그냥 공식적으로 제공되는 기능들 사용하는게 나을지도 .. brew bundle dump, pip freeze > requirements.txt
