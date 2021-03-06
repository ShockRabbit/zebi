# Intro
- working with config file
- tested on OSX

# Goal
- zero-base install
    - buy mac -> unboxing -> run installer -> enjoy develop
- install various environment by various config file

# Usage
- write config file
- run install script
    - ``sh install.sh``
- enter your config file path
- enter your password

# How to write config file ?
- write config for each [support list](#support-list)
    - see [example_config.json](example_config.json)
- write install order
    - install script will install by config's order
- also you can insert your custom shell script to config's order

# Support List
- brew
- mas
    - :bangbang: support only ``mas lucky``. this means it only supports reinstall.
- pyenv (+ pyenv-virtualenv)
- rbenv
- nodenv
- git_organization
- git_clone
- unity3d
- android_sdk
- android_ndk
- sdkman
- url download
- unzip


---

# ToDO
- [ ] 완전 첫 설치시 brew install 에서인지 password 입력하라고 뜨는 것 같다. expect 처리 필요 -> 작업은 완료. 테스트 필요
- [ ] git 첫 clone 시 Are you sure you want to continue connecting (yes/no)? 에 대한 expect 처리 필요 -> 작업은 완료. 테스트 필요
- [ ] cask 제대로 설치 안되던데... 확인 필요.
