# Intro
- this is ShockRabbit's install script
- tested on OSX
- working with config file

# Goal
- zero-base install until enable develop
    - buy mac -> unboxing -> run installer -> enjoy develop
- installable various environment by config file
---
![goal_01](./readme_img/goal_01.png)
---
![goal_02](./readme_img/goal_02.png)
---

# Usage
- writing config file
- run install script with config file and local password
    - ex) ``sh install.sh config.json PASSWORD``

# How to write config file ?
- writing config for each installer
    - see [example_config.json](example_config.json)
- writing install order
    - install script will run installers by config's order
- also you can insert your custom shell script to config's order

# Support Installer List
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
