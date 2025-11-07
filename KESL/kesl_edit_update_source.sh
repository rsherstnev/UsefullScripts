#!/usr/bin/env bash

_RED_COLOR="\e[1;31m"
_GREEN_COLOR="\e[1;32m"
_COLOR_RESET="\e[0m"

if ! [[ groups | grep -o kesladmin ]]; then
    echo -e "${_RED_COLOR}!!! Данный скрипт должен быть запущен от имени учетной записи, входящей в группу \"kesladmin\" !!!${_COLOR_RESET}"
    exit 1
fi

function report_step {
    echo -e "${_YELLOW_COLOR}[STEP] $1...${_COLOR_RESET}"
}

function report_success {
    echo -e "  ${_GREEN_COLOR}[SUCCESS] $1.${_COLOR_RESET}"
}

if kesl-control --set-settings 6 SourceType=Custom CustomSources.item_0000.URL=/media/cdrom0 CustomSources.item_0000.Enabled=Yes ApplicationUpdateMode=Disabled; then
    report_success "Источник обновления для KES for Linux успешно задан в \"/media/cdrom0\""
else
    report_fail "При задании источника обновления для KES for Linux в \"/media/cdrom0\" произошла ошибка"
fi