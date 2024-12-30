# Данный скрипт позволяет вручную поменять пароли нескольким пользователям системы
# Если в аргументы скрипту ничего не передано, то скрипт извлекает из /etc/passwd всех несистемных пользователей и начинает изменять им пароль
# Иначе скрипт начинает изменять пароли всех учетных записей, переданных скрипту в аргументах
# Примеры использования скрипта:
#    sudo ./alse_change_user_passwords_manual.sh
#    sudo ./alse_change_user_passwords_manual.sh secadmin sysadmin user{1..27}

#!/usr/bin/env bash

_RED_COLOR="\e[1;31m"
_YELLOW_COLOR="\e[1;33m"
_COLOR_RESET="\e[0m"

if [[ $EUID != 0 ]]; then
    echo -e "${_RED_COLOR}!!! Данный скрипт должен быть запущен от имени root !!!${_COLOR_RESET}"
    exit 1
fi

function report_step {
    echo -e "${_YELLOW_COLOR}[STEP] $1${_COLOR_RESET}"
}

function report_fail {
    echo -e "  ${_RED_COLOR}[FAIL] $1!${_COLOR_RESET}"
}

function change_password {
    # Аргумент №1: логин пользователя, пароль которого необходимо изменить
    user_gecos=$(grep -w $1 /etc/passwd | cut -d : -f 5 | cut -d , -f 1)
    while true
    do
        report_step "Изменение пароля пользователя с логином \"$1\" ($user_gecos)";
        if passwd $1; then
            break
        fi
    done
}

if [[ $# == 0 ]]; then
    users=$(awk -F: '$3 > 999 && $3 != 65534 {print $1}' /etc/passwd)
else
    users=$@
fi

for user in $users; do
    if id $user &> /dev/null; then
        change_password $user
    else
        report_fail "Пользователь с логином \"$user\" отсутствует в системе"
    fi
done