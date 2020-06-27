# Intro
- working with config file
- tested on OSX

# Goal
- zero-base install until enable develop
    - buy mac -> unboxing -> run installer -> enjoy develop
- install various environment by config file

# Usage
- writing config file
- run install script with config file and local password
    - ex) ``sh install.sh config.json PASSWORD``

# How to write config file ?
- write config for each [support list](#Support List)
    - see [example_config.json](example_config.json)
- write install order
    - install script will install by config's order
- also you can insert your custom shell script to config's order

# Support List
- brew
- mas
- pyenv (+ pyenv-virtualenv)
- rbenv
- nodenv
- git_organization
- git_clone
- unity3d
- android_sdk
- android_ndk
- sdkman
