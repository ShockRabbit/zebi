#!/bin/sh

# source ../util.sh

function get_macos_version() {
    # macOS 버전을 가져옵니다 (예: 13.0, 14.0)
    sw_vers -productVersion
}

function get_macos_major_version() {
    # macOS 메이저 버전을 가져옵니다 (예: 13, 14)
    local version=$(get_macos_version)
    echo $version | cut -d. -f1
}

function get_macos_name() {
    # macOS 이름을 가져옵니다 (예: Ventura, Sonoma)
    local major_version=$(get_macos_major_version)
    case $major_version in
        15) echo "Sequoia" ;;
        14) echo "Sonoma" ;;
        13) echo "Ventura" ;;
        12) echo "Monterey" ;;
        11) echo "BigSur" ;;
        10.15) echo "Catalina" ;;
        *) echo "Unknown" ;;
    esac
}

function get_macos_arch() {
    # 아키텍처를 가져옵니다 (arm64 또는 x86_64)
    uname -m
}

function get_macports_installer_url() {
    # macOS 버전에 맞는 MacPorts installer URL을 반환합니다
    local major_version=$(get_macos_major_version)
    local macos_name=$(get_macos_name)
    
    # MacPorts 최신 버전 (2024년 기준 2.11.6)
    local macports_version="2.11.6"
    
    # macOS 버전에 따른 파일명 생성
    # 형식: MacPorts-{version}-{major_version}-{macos_name}.pkg
    # 또는 MacPorts-{version}-{darwin_version}-{macos_name}.pkg
    local filename="MacPorts-${macports_version}-${major_version}-${macos_name}.pkg"
    
    # MacPorts GitHub releases URL
    # 실제로는 GitHub releases 페이지에서 버전별로 제공
    local base_url="https://github.com/macports/macports-base/releases/download/v${macports_version}"
    
    # GitHub releases에서 직접 다운로드 시도
    # 만약 실패하면 공식 사이트에서 수동 다운로드 안내
    echo "${base_url}/${filename}"
}

function download_macports_installer() {
    local download_url=$1
    local dest_path=$2
    
    log "Downloading MacPorts installer from ${download_url}"
    curl -L -o "$dest_path" "$download_url" || {
        log_error "[macports] fail :: download installer from ${download_url}"
        return 1
    }
    
    if [ ! -f "$dest_path" ]; then
        log_error "[macports] fail :: installer file not found at ${dest_path}"
        return 1
    fi
    
    log "MacPorts installer downloaded successfully"
    return 0
}

function install_macports_pkg() {
    local pkg_path=$1
    local pw=$2
    
    log "Installing MacPorts from ${pkg_path}"
    
    # installer 명령어를 사용하여 .pkg 파일 설치
    # sudo가 필요하므로 expect 사용
expect <<EOF
set timeout 600
spawn sudo installer -pkg "${pkg_path}" -target /
expect "Password:"
send "$pw\n"
expect eof
EOF
    
    if [ $? -eq 0 ]; then
        log "MacPorts installed successfully"
        return 0
    else
        log_error "[macports] fail :: install MacPorts from ${pkg_path}"
        return 1
    fi
}

function is_macports_installed() {
    # port 명령어가 존재하는지 확인
    if command -v port >/dev/null 2>&1; then
        echo "installed"
    else
        echo "not_installed"
    fi
}

function port_install_with_expect() {
    local package=$1
    local pw=$2
    
expect <<EOF
set timeout 600
spawn sudo port install $package
expect {
    "Password:" {
        send "$pw\n"
        exp_continue
    }
    "Error:" {
        exit 1
    }
    eof
}
EOF
}

function port_selfupdate_with_expect() {
    local pw=$1
    
expect <<EOF
set timeout 1200
spawn sudo port selfupdate
expect {
    "Password:" {
        send "$pw\n"
        exp_continue
    }
    eof
}
EOF
}

function install_macports_base() {
    local pw=$1
    
    # MacPorts가 이미 설치되어 있는지 확인
    local is_installed=$(is_macports_installed)
    if [[ $is_installed == "installed" ]]; then
        log "MacPorts is already installed"
        return 0
    fi
    
    echo_title "Install MacPorts Base"
    
    # 임시 디렉토리 생성
    local temp_dir=$(mktemp -d)
    local installer_path="${temp_dir}/MacPorts.pkg"
    
    # MacPorts installer URL 가져오기
    local installer_url=$(get_macports_installer_url)
    
    # 다운로드 시도
    if ! download_macports_installer "$installer_url" "$installer_path"; then
        # GitHub releases에서 직접 다운로드 실패 시
        # SourceForge 미러나 공식 사이트에서 시도
        log "Trying alternative download source (SourceForge mirror)"
        local major_version=$(get_macos_major_version)
        local macos_name=$(get_macos_name)
        local alt_url="https://sourceforge.net/projects/macports.mirror/files/v2.11.6/MacPorts-2.11.6-${major_version}-${macos_name}.pkg/download"
        
        if ! download_macports_installer "$alt_url" "$installer_path"; then
            log "Note: MacPorts installation may require manual .pkg installation"
            log "Please visit https://www.macports.org/install.php to download the installer for your macOS version"
            log "macOS Version: $(get_macos_version) ($(get_macos_name))"
            log_error "[macports] fail :: automatic installer download failed from all sources"
            rm -rf "$temp_dir"
            return 1
        fi
    fi
    
    # MacPorts 설치
    if ! install_macports_pkg "$installer_path" "$pw"; then
        rm -rf "$temp_dir"
        return 1
    fi
    
    # 임시 파일 정리
    rm -rf "$temp_dir"
    
    # PATH 설정 확인 및 추가
    shell_config_file=$(get_shell_config_file)
    safe_append_config 'export PATH="/opt/local/bin:/opt/local/sbin:$PATH"' $shell_config_file
    safe_append_config 'export MANPATH="/opt/local/share/man:$MANPATH"' $shell_config_file
    source $shell_config_file
    
    # port 명령어 사용 가능 여부 확인
    if [[ $(is_macports_installed) != "installed" ]]; then
        log_error "[macports] fail :: port command not found after installation"
        return 1
    fi
    
    # MacPorts 업데이트 (선택사항)
    log "Updating MacPorts ports tree"
    port_selfupdate_with_expect "$pw" || log_error "[macports] fail :: port selfupdate"
    
    return 0
}

function install_process_macports() {
    local config_path=$1
    local pw=$2
    
    echo_title "Install Process macports"
    
    # MacPorts 기본 설치
    if ! install_macports_base "$pw"; then
        log_error "[macports] fail :: MacPorts base installation failed"
        return 1
    fi
    
    # Config에서 패키지 목록 읽기
    local packages=`cat $config_path | jq -r '.macports[]?' 2>/dev/null`
    
    if [ -z "$packages" ]; then
        log "No packages specified in config file"
        return 0
    fi
    
    echo_title "Install Process macports :: port install"
    
    # 각 패키지 설치
    for package in $packages; do
        log "port install $package"
        if port_install_with_expect "$package" "$pw"; then
            log "Successfully installed $package"
        else
            log_error "[macports] fail :: port install $package"
        fi
    done
}

# install_process_macports ../config.json TEST_PASSWORD
