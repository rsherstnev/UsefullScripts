#!/usr/bin/env bash

_RED_COLOR="\e[1;31m"
_GREEN_COLOR="\e[1;32m"
_YELLOW_COLOR="\e[1;33m"
_COLOR_RESET="\e[0m"

if [[ $EUID != 0 ]]; then
    echo -e "${_RED_COLOR}!!! Данный скрипт должен быть запущен от имени root !!!${_COLOR_RESET}"
    exit 1
fi

function report_step {
    echo -e "${_YELLOW_COLOR}[STEP] $1...${_COLOR_RESET}"
}

function report_success {
    echo -e "  ${_GREEN_COLOR}[SUCCESS] $1.${_COLOR_RESET}"
}

function report_fail {
    echo -e "  ${_RED_COLOR}[FAIL] $1!${_COLOR_RESET}"
}

function config_download {
    # Аргумент 1: URL скачиваемого файла
    # Аргумент 2: Путь для скачивания файла
    # Так как wget не умеет перезаписывать файлы, нужно сначала удалить файл при его наличии
    if [ -f $2 ]; then
        rm -f $2 &> /dev/null
    fi
    # Скачивание файла
    file_name=$(echo $1 | awk -F '/' '{print $NF}')
    if wget $1 -O $2 &> /dev/null; then
        report_success "Файл $file_name был успешно скачан по адресу $2"
    else
        report_fail "При скачивании файла $file_name по адресу $2 произошла ошибка"
    fi
}

# read -p "Введите логин создаваемого пользователя: " _USER
# read -p "Введите GECOS создаваемого пользователя: " _GECOS

report_step "Установка русского языка в систему"
if sed '/ru_RU.UTF-8 UTF-8/s/^# //' -i /etc/locale.gen && locale-gen &> /dev/null; then
    report_success "Русский язык был успешно установлен в систему"
else
    report_fail "При установке русского языка в систему произошла ошибка"
fi

# report_step "Создание рядового пользователя \"$_USER\""
# if useradd -c "$GECOS" -m -s /usr/bin/bash -G sudo $_USER; then
#     report_success "Рядовой пользователь \"$_USER\" был успешно создан"
# else
#     report_fail "При создании рядового пользователя \"$_USER\" произошла ошибка"
# fi

# report_step "Задание пароля созданному пользователю \"$_USER\""
# if passwd $_USER; then
#     report_success "Пароль у пользователя \"$_USER\" был успешно задан"
# else
#     report_fail "При задании пароля у пользователя \"$_USER\" произошла ошибка"
# fi

report_step "Создание необходимых директорий"
for directory in \
    $HOME/.vim/colors \
    $HOME/.config/mc;
do
    if [[ ! -d $directory ]]; then
        if mkdir -p $directory &> /dev/null; then
            report_success "Директория \"$directory\" была успешно создана"
        else
            report_fail "При создании директории \"$directory\" произошла ошибка"
        fi
    else
        report_success "Директория \"$directory\" была успешно создана"
    fi
done

report_step "Обновление системы"
export DEBIAN_FRONTEND=noninteractive
if apt update &> /dev/null && apt full-upgrade -y &> /dev/null; then
    report_success "Система была успешно обновлена"
else
    report_fail "При обновлении системы произошла ошибка"
fi

report_step "Задание необходимой временной зоны"
if timedatectl set-timezone Asia/Krasnoyarsk &> /dev/null; then
    report_success "Временная зона \"Красноярск\" была успешно задана"
else
    report_fail "При установке временной зоны \"Красноярск\" произошла ошибка"
fi

report_step "Установка необходимого для работы софта"
for software in \
    eza \
    vim \
    wget \
    curl \
    less \
    tmux \
    htop \
    btop \
    lnav \
    ncdu \
    gnupg2 \
    ca-certificates \
    apt-transport-https \
    tree \
    tcpdump \
    mc \
    lsof \
    syslog-ng \
    iptables;
    # build-essential \
    # git \
    # auditd \
    # lynis \
    # unattended-upgrades \
do
    if apt install -y $software &> /dev/null; then
        report_success "Утилита \"$software\" была успешно установлена в систему"
    else
        report_fail "При установке утилиты \"$software\" произошла ошибка"
    fi
done

report_step "Установка необходимых конфигов, скриптов, тем"
config_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/bash/.bashrc $HOME/.bashrc
config_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/bash/.inputrc $HOME/.inputrc
config_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/refs/heads/master/common/.aliases $HOME/.aliases
config_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/refs/heads/master/common/.functions $HOME/.functions
config_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/vim/.vimrc $HOME/.vimrc
config_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/tmux/.tmux.conf $HOME/.tmux.conf
config_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/mc/root/ini $HOME/.config/mc/ini
config_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/mc/root/panels.ini $HOME/.config/mc/panels.ini