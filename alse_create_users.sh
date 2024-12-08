# Данный скрипт позволяет быстро добавить в автоматизированную систему некоторое количество пользователей
# Если в аргументы скрипту ничего не передано, то скрипт интерактивно запросит количество создаваемых пользователей и начнет создавать их со случайно сгенерированными паролями
# Логины созданных пользователей при этом будут иметь вид "user1, user2 ..."
# Иначе скрипт будет создавать учетные записи с логинами, переданными скрипту в аргументах
# При создании пользователя будет интерактивно запрошено его Ф.И.О.
# При генерации паролей для пользователей учитываются заданные в автоматизированной системе требования к качеству паролей
# При создании пользователя скрипт автоматически назначает ему максимальный уровень конфиденциальности, определенный в переменной _USER_SECRET_DEFAULT
# Примеры использования скрипта:
#    sudo ./alse_create_users.sh
#    sudo ./alse_create_users.sh secadmin sysadmin user{1..27}

#!/usr/bin/env bash

_RED_COLOR="\e[1;31m"
_GREEN_COLOR="\e[1;32m"
_COLOR_RESET="\e[0m"
_ALPHABET="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+-=<>"
_USER_SECRET_DEFAULT=1

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
    # Аргумент №1: логин пользователя, пароль которого необходимо задать
	user_login=$1
    user_gecos=$(grep $user_login /etc/passwd | cut -d : -f 5 | cut -d , -f 1)
    while true
    do
        generated_password=$(< /dev/urandom tr -dc $_ALPHABET | head -c12)
        if echo $user_login:$generated_password | chpasswd &> /dev/null; then
            report_success "Пароль пользователя с логином \"$user_login\" ($user_gecos) был успешно задан в $generated_password"
            break
        fi
    done
}

function set_max_secret_level {
    # Аргумент №1: логин пользователя, максимальный уровень конфиденциальности которого необходимо изменить
	user_login=$1
    user_secret_level=$(userlev $_USER_SECRET_DEFAULT | cut -d ' ' -f 3)
    user_gecos=$(grep $user_login /etc/passwd | cut -d : -f 5 | cut -d , -f 1)
    if pdpl-user -l 0:$_USER_SECRET_DEFAULT $user_login &> /dev/null; then
        report_success "Максимальный уровень конфиденциальности пользователя с логином \"$user_login\" ($user_gecos) был успешно изменен на \"$user_secret_level\""
    else
        report_fail "При изменении максимального уровня конфиденциальности пользователя с логином \"$user_login\" ($user_gecos) на \"$user_secret_level\" произошла ошибка"
    fi
}

function create_user {
    # Аргумент №1: логин пользователя, которого необходимо добавить в систему
    user_login=$1
    if id $user_login &> /dev/null; then
        report_fail "Пользователь с логином \"$user_login\" уже существует в системе!"
    else
        read -p "Введите Ф.И.О. пользователя $user_login: " user_gecos
        if useradd -c "$user_gecos" -m -s /usr/bin/bash $user_login; then
            report_success "Пользователь с логином \"$user_login\" ($user_gecos) был успешно добавлен в систему"
        else
            report_fail "При добавлении пользователя с логином \"$user_login\" ($user_gecos) в систему произошла ошибка"
        fi
        set_password $user_login
        set_max_secret_level $user_login
    fi
}

if [[ $# == 0 ]]; then
    read -p "Введите количество создаваемых пользователей: " user_number
    for (( user_id = 1; user_id <= $user_number; user_id++ ))
    do
        create_user user$user_id
    done
else
    for user_login in $@
    do
        create_user $user_login
    done
fi