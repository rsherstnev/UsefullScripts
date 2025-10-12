#!/usr/bin/env bash

_RED_COLOR="\e[1;31m"
_GREEN_COLOR="\e[1;32m"
_YELLOW_COLOR="\e[1;33m"
_COLOR_RESET="\e[0m"

if [[ $EUID == 0 ]]; then
    echo -e "${_RED_COLOR}!!! Данный скрипт НЕ должен быть запущен от имени root !!!${_COLOR_RESET}"
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

report_step "Установка необходимых конфигов, скриптов, тем"
config_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/bash/.bashrc $HOME/.bashrc
config_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/bash/.inputrc $HOME/.inputrc
config_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/refs/heads/master/common/.aliases $HOME/.aliases
config_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/refs/heads/master/common/.functions $HOME/.functions
config_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/vim/.vimrc $HOME/.vimrc
config_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/tmux/.tmux.conf $HOME/.tmux.conf
config_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/git/.gitconfig $HOME/.gitconfig