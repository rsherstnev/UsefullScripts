#!/usr/bin/env bash

_RED_COLOR="\e[1;31m"
_GREEN_COLOR="\e[1;32m"
_YELLOW_COLOR="\e[1;33m"
_COLOR_RESET="\e[0m"

report_step() {
    echo
    echo "[STEP] $1..."
}

report_success() {
    echo -e "${_GREEN_COLOR}[SUCCESS] $1${_COLOR_RESET}"
}

report_warning() {
    echo -e "${_YELLOW_COLOR}[SUCCESS] $1${_COLOR_RESET}"
}

report_fail() {
    echo -e "${_RED_COLOR}[FAIL] $1${_COLOR_RESET}"
}

# Аргумент 1: URL скачиваемого файла
# Аргумент 2: Путь для скачивания файла
# Так как wget не умеет перезаписывать файлы, нужно сначала удалить файл при его наличии
config_download() {
    if [ -f $2 ]; then
        rm -f $2 &> /dev/null
    fi
    file_name=$(echo $1 | awk -F '/' '{print $NF}')
    if wget $1 -O $2 &> /dev/null; then
        report_success "Файл $file_name был успешно скачан по адресу $2"
    else
        report_fail "При скачивании файла $file_name по адресу $2 произошла ошибка"
    fi
}

create_sudo_user() {
    report_step "Создание пользователя для работы"

    read -p "Введите логин создаваемого пользователя: " _USER
    read -p "Введите GECOS создаваемого пользователя: " _GECOS

    if useradd -c "$GECOS" -m -s /usr/bin/bash -G sudo $_USER; then
        report_success "Пользователь \"$_USER\" был успешно создан"

        report_step "Задание пароля созданному пользователю \"$_USER\""
        if passwd $_USER; then
            report_success "Пароль у пользователя \"$_USER\" был успешно задан"
        else
            report_fail "При задании пароля у пользователя \"$_USER\" произошла ошибка"
        fi
    else
        report_fail "При создании пользователя \"$_USER\" произошла ошибка"
    fi
}

ru_language_install() {
    report_step "Установка русского языка в систему"
    if sed '/ru_RU.UTF-8 UTF-8/s/^# //' -i /etc/locale.gen && locale-gen &> /dev/null; then
        report_success "Русский язык был успешно установлен в систему"
    else
        report_fail "При установке русского языка в систему произошла ошибка"
    fi
}

create_directory() {
    report_step "Создание необходимых директорий"
    for directory in \
        $HOME/.config/mc;
    do
        if [[ ! -d $directory ]]; then
            if mkdir -p $directory &> /dev/null; then
                report_success "Директория \"$directory\" была успешно создана"
            else
                report_fail "При создании директории \"$directory\" произошла ошибка"
            fi
        else
            report_warning "Директория \"$directory\" уже существует"
        fi
    done
}

update_system() {
    report_step "Обновление системы"
    export DEBIAN_FRONTEND=noninteractive
    if apt update &> /dev/null && apt full-upgrade -y &> /dev/null; then
        report_success "Система была успешно обновлена"
    else
        report_fail "При обновлении системы произошла ошибка"
    fi
    unset DEBIAN_FRONTEND
}

set_timezone() {
    report_step "Задание необходимой временной зоны"
    if timedatectl set-timezone Asia/Krasnoyarsk &> /dev/null; then
        report_success "Временная зона \"Красноярск\" была успешно задана"
    else
        report_fail "При установке временной зоны \"Красноярск\" произошла ошибка"
    fi
}

software_install() {
    report_step "Установка необходимого для работы софта"
    
    software_list=(
        eza
        vim
        wget
        curl
        less
        tmux
        htop
        btop
        lnav
        ncdu
        gnupg2
        ca-certificates
        apt-transport-https
        tree
        tcpdump
        mc
        lsof
        syslog-ng
        iptables
        # build-essential
        # git
        # auditd
        # lynis
        # unattended-upgrades
    )

    for software in ${software_list[@]}; do
        if apt install -y $software &> /dev/null; then
            report_success "Утилита \"$software\" была успешно установлена в систему"
        else
            report_fail "При установке утилиты \"$software\" произошла ошибка"
        fi
    done
}

env_configure() {
    report_step "Установка необходимых конфигов, скриптов, тем"
    config_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/bash/.bashrc $HOME/.bashrc
    config_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/bash/.inputrc $HOME/.inputrc
    config_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/common/.aliases $HOME/.aliases
    config_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/common/.functions $HOME/.functions
    config_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/vim/.vimrc $HOME/.vimrc
    config_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/tmux/.tmux.conf $HOME/.tmux.conf

    if [[ $EUID == 0 ]]; then
        home_dir=root
    else
        home_dir=user
    fi

    config_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/mc/$home_dir/ini $HOME/.config/mc/ini
    config_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/mc/$home_dir/panels.ini $HOME/.config/mc/panels.ini
}

if [[ $EUID == 0 ]]; then
    # create_sudo_user
    ru_language_install
    create_directory
    update_system
    set_timezone
    software_install
    env_configure
else
    create_directory
    env_configure
fi