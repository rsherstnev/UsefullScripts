# Данный скрипт позволяет автоматически поменять пароли нескольким пользователям системы
# Если в аргументы скрипту ничего не передано, то скрипт извлекает из /etc/passwd всех несистемных пользователей и изменяет им пароль
# Иначе скрипт изменяет пароли всех учетных записей, переданных скрипту в аргументах
# Примеры использования скрипта:
#    sudo ./alse_change_user_passwords_auto.sh
#    sudo ./alse_change_user_passwords_auto.sh secadmin sysadmin user{1..27}

#!/usr/bin/env bash

_RED_COLOR="\e[1;31m"
_GREEN_COLOR="\e[1;32m"
_COLOR_RESET="\e[0m"
_PASSWORD_LENGTH=10
_ALPHABET="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$"
# Закомментируйте алфавит выше и раскомментируйте данный для более сильных паролей
# _ALPHABET="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+-=<>"

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

function change_password {
    # Аргумент №1: логин пользователя, пароль которого необходимо изменить
    user_gecos=$(grep -w $1 /etc/passwd | cut -d : -f 5 | cut -d , -f 1)
    while true
    do
        generated_password=$(< /dev/urandom tr -dc $_ALPHABET | head -c $_PASSWORD_LENGTH)
        if echo $1:$generated_password | chpasswd &> /dev/null; then
            report_success "Пароль пользователя с логином \"$1\" ($user_gecos) был успешно изменен на $generated_password"
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
        report_fail "Пользователь с логином \"$user\" отсутствует в системе!"
    fi
done