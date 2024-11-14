#!/usr/bin/env bash

_RED_COLOR="\e[1;31m"
_GREEN_COLOR="\e[1;32m"
_YELLOW_COLOR="\e[1;33m"
_COLOR_RESET="\e[0m"
_ALPHABET="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+-=<>"

if [[ $EUID != 0 ]]; then
    echo -e "${_RED_COLOR}!!! Данный скрипт должен быть запущен от имени root !!!${_COLOR_RESET}"
    exit 1
fi

function report_success {
    echo -e "  ${_GREEN_COLOR}[SUCCESS] $1${_COLOR_RESET}"
}

function report_fail {
    echo -e "  ${_RED_COLOR}[FAIL] $1${_COLOR_RESET}"
}

for user in secadmin sysadmin user{1..27}; do
    if id $user &> /dev/null; then
        user_gecos=$(grep $user /etc/passwd | cut -d : -f 5 | cut -d , -f 1)
        generated_password=$(< /dev/urandom tr -dc $_ALPHABET | head -c12)
        if echo $user:$generated_password | chpasswd &> /dev/null; then
            report_success "Пароль пользователя с логином \"$user\" ($user_gecos) был успешно изменен на $generated_password"
        else
            report_fail "При изменении пароля пользователя с логином \"$user\" ($user_gecos) на $generated_password произошла ошибка! Проверьте соответствие сгенерированного пароля требованиям парольной политики!"
        fi
    else
        report_fail "Пользователь с логином \"$user\" отсутствует в системе"
    fi
done