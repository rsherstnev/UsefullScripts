# Данный скрипт позволяет быстро создать некоторое количество пользователей автоматизированной системы
# Запускать скрипт необходимо без каких-либо аргументов
# Скрипт интерактивно запросит количество создаваемых пользователей и начнет поэтапно создавать их со случайно сгенерированными паролями
# При создании пользователя будет запрошено его Ф.И.О.
# Логины созданных пользователей будут иметь вид "user1, user2 ..."
# При генерации паролей для пользователей учитываются заданные в автоматизированной системе требования к качеству паролей

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

function set_password {
    # Аргумент №1: логин пользователя, пароль которого необходимо изменить
    user_gecos=$(grep $1 /etc/passwd | cut -d : -f 5 | cut -d , -f 1)
    while true
    do
        generated_password=$(< /dev/urandom tr -dc $_ALPHABET | head -c12)
        if echo $1:$generated_password | chpasswd &> /dev/null; then
            report_success "Пароль пользователя с логином \"$1\" ($user_gecos) был успешно задан в $generated_password"
            break
        fi
    done
}

read -p "Введите количество создаваемых пользователей: " user_number
for (( user_id = 1; user_id <= $user_number; user_id++ ))
do
    user_login=user$user_id
    if id $user_login &> /dev/null; then
        report_fail "Пользователь с логином \"$user_login\" уже существует в системе!"
    else
        read -p "Введите Ф.И.О. пользователя $user_login: " user_gecos
        if useradd -c "$user_gecos" -m -s /usr/bin/bash $user_login; then
            report_success "Пользователь с логином $user_login ($user_gecos) был успешно добавлен в систему."
        else
            report_fail "При добавлении пользователя с логином $user_login ($user_gecos) в систему произошла ошибка!"
        fi
        set_password $user_login
    fi
done