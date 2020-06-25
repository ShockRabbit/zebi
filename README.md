# Intro
- this is ShockRabbit's install script
- tested on OSX
- working with config file

# Goal
- zero-base install until enable develop
[!goal_01](./readme_img/goal_01.png)
    - buy mac -> unboxing -> run installer -> enjoy develop
- installable various environment by config file
[!goal_02](./readme_img/goal_02.png)

# Usage
- writing config file
- run install script with config file and local password
    - ex) ``sh install.sh config.json PASSWORD``

# How to write config file ?
- writing format


# ToDo
- [X] pyenv packages text file 연결아닌 array 직접 채우는 형태로 변경
- [X] nodenv 지원
- pyenv, rbenv, nodenv system env 지원 -> 보류. 난 필요 없어서..
- android sdk, ndk 통합. android sdk 설치 download url 없이 brew 로 처리 -> 파기. 추후 brew 로 android-sdk 설치가 제대로 동작하지 않을 수 도 있다.
