#!/usr/bin/env bash

_RED_COLOR="\e[1;31m"
_GREEN_COLOR="\e[1;32m"
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

# Если необходимо поменять пароль только определенным пользователям, то нужно заменить цикл, например, на:
# for user in secadmin sysadmin user{1..27}; do

for user in $(awk -F: '$3 > 999 && $3 != 65534 {print $1}' /etc/passwd); do
    if id $user &> /dev/null; then
        user_gecos=$(grep $user /etc/passwd | cut -d : -f 5 | cut -d , -f 1)
        while true
        do
            generated_password=$(< /dev/urandom tr -dc $_ALPHABET | head -c12)
            if echo $user:$generated_password | chpasswd &> /dev/null; then
                report_success "Пароль пользователя с логином \"$user\" ($user_gecos) был успешно изменен на $generated_password"
                break
            fi
        done
    else
        report_fail "Пользователь с логином \"$user\" отсутствует в системе!"
    fi
done