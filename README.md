# Intro
- **ze**ro-**b**ase **i**nstaller
- working with config file
- tested on OSX

# Goal
- zero-base install
    - buy mac -> unboxing -> run installer -> enjoy development
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

# Trouble Shooting
- xcode 우선 설치 후 zebi 사용시 xcode 우선 열어서 동의안하면 xcode 동의 하라는 오류가 발생할 수 있다.
- gitlab git clone 시 https 를 사용하지 않으면 실패할 수 있다.
- nodenv version 이 낮으면 apple silicon 에서 실패할 수 있다. (14.4.0 의 경우 실패)


---

# ToDo
- 추측이지만 brew cask install 이 첫번째 설치가 높은 확률로 실패하는 것 같다. 에러가 나는 것은 아닌데 설치 도중 스킵되고 다음으로 넘어가는 현상이 종종 보인다
