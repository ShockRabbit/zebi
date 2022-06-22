# Intro
- **ze**ro-**b**ase **i**nstaller
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
- [ ] cask 제대로 설치 안되던데... 확인 필요. -> 작업은 완료. 테스트 필요
- [ ] config 관리 기능 추가. 설치시 사용한 config 가 그대로 저장되어 이후 활용된다.
    - show config : config path 및 config 내용 출력
    - sync config : 현재 설정된 config 와 내부적으로 관리하는 실제 설치된 내용이 다를 경우, 그에 맞춰 설치 혹은 제거
        - config file 자체의 sync 는 개인적으로 알아서 처리
- [X] 명령어 wrapping 하기. install, uninstall 에 따라 config 에 추가, 삭제 되도록 한다.
    - [X] brew 만 우선 지원
    - [X] install, uninstall 시 --ignore-config 옵션으로 config 무시하는 옵션 추가
    - [X] brew 는 tap, untap 도 지원 필요
- [X] 여러개의 config 를 차례로 install 가능하도록 처리 (config merge or installer 에서 대응)
    - 우선 최소한 pyenv, rbenv, nodenv, git_organization, brew 는 대응 가능
- [X] gitlab bitmango 계정으로 되어있는 것 p1s 로 변경
- [X] gitlab group download 기능
- [X] github user download 기능
- [X] pyenv, rbenv, nodenv, brew 바뀐 인터페이스 적용
- [X] pyenv, rbenv, nodenv 바뀐 설정 대응 (zebi 는 공식적으로는 fish 는 지원하지 않는다. fish 관련 설정은 알아서 dotfiles 등을 통해서 처리)


- 사실 하지말았어야할 프로젝트. 반복되는 횟수가 적기 때문에, 투자되는 시간에비해 이득이 너무 적다.
- 설치보다는 백업이 용이한 구조를 갖추는데 신경쓰는게 그나마 낫다
