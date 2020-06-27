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
- input config file path
- input password

# How to write config file ?
- write config for each [support list](#support-list)
    - see [example_config.json](example_config.json)
- write install order
    - install script will install by config's order
- also you can insert your custom shell script to config's order

# Support List
- brew
- mas
    - :bangbang: support only ``mas lucky``. this mean support only reinstall.
- pyenv (+ pyenv-virtualenv)
- rbenv
- nodenv
- git_organization
- git_clone
- unity3d
- android_sdk
- android_ndk
- sdkman
