#!/bin/bash

green="\033[1;32m"
red="\033[1;31m"
yellow="\033[1;33m"
default_color="\033[0m"

if [ "$(groups | grep -o kesladmin)" != "kesladmin" ]; then
   echo -e $red"Скрипт необходимо запускать от имени учетной записи, входящей в группу \"kesladmin\"!"$default_color
   exit 1
fi

if [[ $(systemctl is-active kesl.service) == "inactive" ]]; then
    echo -e $red"Служба Kaspersky Endpoint Security for Linux не запущена!"$default_color
    exit 1
fi

function report_success {
    echo -e $green"[SUCCESS]$default_color Значение параметра \"$1\" задачи \"$2\" является допустимым в сертифицированной конфигурации."
}

function report_fail {
    echo -e $red"[FAIL]$default_color Значение параметра \"$1\" задачи \"$2\" НЕ является допустимым в сертифицированной конфигурации!"
}

function report_warning {
    echo -e $yellow"[WARNING]$default_color $1"
}

function get_task_state {
    kesl-control --get-task-state $1 | grep Состояние | awk -F ':' '{ gsub(/ /, ""); print $2 }'
}

echo "Проверка статуса активации программы..."
kesl-control -L --query &> /dev/null
if [[ $? != 0 ]]; then
    echo -e $red"[FAIL]$default_color Программа не активирована! Лицензионный ключ не добавлен"
else
    echo -e $green"[SUCCESS]$default_color Программа активирована! Лицензионный ключ добавлен"
fi

echo "Проверка загруженности антивирусных баз..."
if [[ $(kesl-control --app-info --json | grep "Базы программы загружены" | awk -F ':' '{ gsub(/ /, ""); print $2}' | tr -d "\"",",") == "Да" ]]; then
    echo -e $green"[SUCCESS]$default_color Базы программы загружены!"
else
    echo -e $red"[FAIL]$default_color Базы программы не загружены!"
fi

echo "Проверка статуса задачи \"Защита от файловых угроз\"..."
if [[ $(get_task_state file_threat_protection) != "Запущена" ]]; then
    echo -e $red"[FAIL]$default_color Задача \"Защита от файловых угроз\" не запущена!"
else
    echo -e $green"[SUCCESS]$default_color Задача \"Защита от файловых угроз\" запущена!"
fi

declare -A kesl_tasks_human_name
kesl_tasks_human_name[file_threat_protection]="Защита от файловых угроз"
kesl_tasks_human_name[scan_my_computer]="Антивирусная проверка"
kesl_tasks_human_name[scan_file]="Выборочная проверка"
kesl_tasks_human_name[critical_areas_scan]="Проверка важных областей"
kesl_tasks_human_name[update]="Обновление"
kesl_tasks_human_name[rollback]="Откат обновления баз"
kesl_tasks_human_name[license]="Лицензирование"
kesl_tasks_human_name[backup]="Управление хранилищем"
kesl_tasks_human_name[system_integrity_monitoring]="Контроль целостности системы"
kesl_tasks_human_name[firewall_management]="Управление сетевым экраном"
kesl_tasks_human_name[anti_cryptor]="Защита от шифрования"
kesl_tasks_human_name[web_threat_protection]="Защита от веб-угроз"
kesl_tasks_human_name[device_control]="Контроль устройств"
kesl_tasks_human_name[removable_drives_scan]="Проверка съемных дисков"
kesl_tasks_human_name[network_threat_protection]="Защита от сетевых угроз"
kesl_tasks_human_name[container_scan]="Проверка контейнеров"
kesl_tasks_human_name[custom_container_scan]="Выборочная проверка контейнеров"
kesl_tasks_human_name[behavior_detection]="Анализ поведения"
kesl_tasks_human_name[application_control]="Контроль программ"
kesl_tasks_human_name[inventory_scan]="Инвентаризация"

# Проверяет наличие элемента в массиве
# В дальнейшем используется для определения является ли значение параметра задачи KESL допустимым в сертифицированной конфигурации продукта
function is_value_in_array {
    local -n array=$2
    if [[ "${array[@]}" =~ "$1" ]]; then
        return 0
    else
        return 1
    fi
}

# На вход функции подается два параметра: первый - ID задачи Kaspersky Enpoint Security for Linux, второй - имя проверяемого параметра
function is_parameter_value_secure_for_certified_config {
    parameter_value=$(kesl-control --get-settings $1 $2 | awk -F '=' '{print $2}')
    case "$2" in
        "FirstAction" )
            permissible_values=(Disinfect Remove Recommended)
            is_value_in_array $parameter_value permissible_values
        ;;
        "SecondAction" )
            permissible_values=(Disinfect Remove Recommended)
            if [[ $(kesl-control --get-settings $1 "FirstAction" | awk -F '=' '{print $2}') == "Remove" ]]; then
                return 0
            else
                is_value_in_array $parameter_value permissible_values
            fi
        ;;
        "UseAnalyzer" )
            permissible_values=(Yes)
            is_value_in_array $parameter_value permissible_values
        ;;
        "HeuristicLevel" )
            permissible_values=(Light Medium Deep Recommended)
            is_value_in_array $parameter_value permissible_values
        ;;
        "ScanArchived" )
            permissible_values=(Yes)
            is_value_in_array $parameter_value permissible_values
        ;;
        "ScanSfxArchived" )
            permissible_values=(Yes)
            is_value_in_array $parameter_value permissible_values
        ;;
        "ScanMailBases" )
            permissible_values=(Yes)
            is_value_in_array $parameter_value permissible_values
        ;;
        "ScanByAccessType" )
            permissible_values=(Open)
            is_value_in_array $parameter_value permissible_values
        ;;
        "SourceType" )
            permissible_values=(KLServers SCServer Custom)
            is_value_in_array $parameter_value permissible_values
        ;;
        "ApplicationUpdateMode" )
            permissible_values=(Disabled)
            is_value_in_array $parameter_value permissible_values
        ;;
        "UseHostBlocker" )
            permissible_values=(Yes)
            is_value_in_array $parameter_value permissible_values
        ;;
        "ActionOnDetect" )
            permissible_values=(Block)
            is_value_in_array $parameter_value permissible_values
        ;;
        "ScanRemovableDrives" )
            permissible_values=(DetailedScan QuickScan)
            is_value_in_array $parameter_value permissible_values
        ;;
    esac
}

echo 'Проверка значения параметра "FirstAction" задач Kaspersky Endpoint Security for Linux на соответствие сертифицированной конфигурации...'
for task in file_threat_protection scan_my_computer scan_file critical_areas_scan container_scan custom_container_scan; do
    is_parameter_value_secure_for_certified_config $task "FirstAction"
    if [[ $? == 0 ]]; then
        report_success FirstAction "${kesl_tasks_human_name[$task]}"
    else
        report_fail FirstAction "${kesl_tasks_human_name[$task]}"
    fi
done

echo 'Проверка значения параметра "SecondAction" задач Kaspersky Endpoint Security for Linux на соответствие сертифицированной конфигурации...'
for task in file_threat_protection scan_my_computer scan_file critical_areas_scan container_scan custom_container_scan; do
    is_parameter_value_secure_for_certified_config $task "SecondAction"
    if [[ $? == 0 ]]; then
        report_success SecondAction "${kesl_tasks_human_name[$task]}"
    else
        report_fail SecondAction "${kesl_tasks_human_name[$task]}"
    fi
done

echo 'Проверка значения параметра "UseAnalyzer" задач Kaspersky Endpoint Security for Linux на соответствие сертифицированной конфигурации...'
for task in file_threat_protection scan_my_computer scan_file critical_areas_scan container_scan custom_container_scan; do
    is_parameter_value_secure_for_certified_config $task "UseAnalyzer"
    if [[ $? == 0 ]]; then
        report_success UseAnalyzer "${kesl_tasks_human_name[$task]}"
    else
        report_fail UseAnalyzer "${kesl_tasks_human_name[$task]}"
    fi
done

echo 'Проверка значения параметра "HeuristicLevel" задач Kaspersky Endpoint Security for Linux на соответствие сертифицированной конфигурации...'
for task in file_threat_protection scan_my_computer scan_file critical_areas_scan container_scan custom_container_scan; do
    is_parameter_value_secure_for_certified_config $task "HeuristicLevel"
    if [[ $? == 0 ]]; then
        report_success HeuristicLevel "${kesl_tasks_human_name[$task]}"
    else
        report_fail HeuristicLevel "${kesl_tasks_human_name[$task]}"
    fi
done

echo 'Проверка значения параметра "ScanArchived" задач Kaspersky Endpoint Security for Linux на соответствие сертифицированной конфигурации...'
for task in file_threat_protection scan_my_computer scan_file critical_areas_scan container_scan custom_container_scan; do
    is_parameter_value_secure_for_certified_config $task "ScanArchived"
    if [[ $? == 0 ]]; then
        report_success ScanArchived "${kesl_tasks_human_name[$task]}"
    else
        report_fail ScanArchived "${kesl_tasks_human_name[$task]}"
    fi
done

echo 'Проверка значения параметра "ScanSfxArchived" задач Kaspersky Endpoint Security for Linux на соответствие сертифицированной конфигурации...'
for task in file_threat_protection scan_my_computer scan_file critical_areas_scan container_scan custom_container_scan; do
    is_parameter_value_secure_for_certified_config $task "ScanSfxArchived"
    if [[ $? == 0 ]]; then
        report_success ScanSfxArchived "${kesl_tasks_human_name[$task]}"
    else
        report_fail ScanSfxArchived "${kesl_tasks_human_name[$task]}"
    fi
done

echo 'Проверка значения параметра "ScanMailBases" задач Kaspersky Endpoint Security for Linux на соответствие сертифицированной конфигурации...'
for task in file_threat_protection scan_my_computer scan_file critical_areas_scan container_scan custom_container_scan; do
    is_parameter_value_secure_for_certified_config $task "ScanMailBases"
    if [[ $? == 0 ]]; then
        report_success ScanMailBases "${kesl_tasks_human_name[$task]}"
    else
        report_fail ScanMailBases "${kesl_tasks_human_name[$task]}"
    fi
done

echo 'Проверка значения параметра "ScanByAccessType" задач Kaspersky Endpoint Security for Linux на соответствие сертифицированной конфигурации...'
for task in file_threat_protection; do
    is_parameter_value_secure_for_certified_config $task "ScanByAccessType"
    if [[ $? == 0 ]]; then
        report_success ScanByAccessType "${kesl_tasks_human_name[$task]}"
    else
        report_fail ScanByAccessType "${kesl_tasks_human_name[$task]}"
    fi
done

echo 'Проверка значения параметра "SourceType" задач Kaspersky Endpoint Security for Linux на соответствие сертифицированной конфигурации...'
for task in update; do
    is_parameter_value_secure_for_certified_config $task "SourceType"
    if [[ $? == 0 ]]; then
        report_success SourceType "${kesl_tasks_human_name[$task]}"
    else
        report_fail SourceType "${kesl_tasks_human_name[$task]}"
    fi
done

echo 'Проверка значения параметра "ApplicationUpdateMode" задач Kaspersky Endpoint Security for Linux на соответствие сертифицированной конфигурации...'
for task in update; do
    is_parameter_value_secure_for_certified_config $task "ApplicationUpdateMode"
    if [[ $? == 0 ]]; then
        report_success ApplicationUpdateMode "${kesl_tasks_human_name[$task]}"
    else
        report_fail ApplicationUpdateMode "${kesl_tasks_human_name[$task]}"
    fi
done

echo 'Проверка значения параметра "UseHostBlocker" задач Kaspersky Endpoint Security for Linux на соответствие сертифицированной конфигурации...'
for task in anti_cryptor; do
    is_parameter_value_secure_for_certified_config $task "UseHostBlocker"
    if [[ $? == 0 ]]; then
        report_success UseHostBlocker "${kesl_tasks_human_name[$task]}"
    else
        report_fail UseHostBlocker "${kesl_tasks_human_name[$task]}"
    fi
done

echo 'Проверка значения параметра "ActionOnDetect" задач Kaspersky Endpoint Security for Linux на соответствие сертифицированной конфигурации...'
for task in web_threat_protection; do
    is_parameter_value_secure_for_certified_config $task "ActionOnDetect"
    if [[ $? == 0 ]]; then
        report_success ActionOnDetect "${kesl_tasks_human_name[$task]}"
    else
        report_fail ActionOnDetect "${kesl_tasks_human_name[$task]}"
    fi
done

echo 'Проверка значения параметра "ScanRemovableDrives" задач Kaspersky Endpoint Security for Linux на соответствие сертифицированной конфигурации...'
for task in removable_drives_scan; do
    is_parameter_value_secure_for_certified_config $task "ScanRemovableDrives"
    if [[ $? == 0 ]]; then
        report_success ScanRemovableDrives "${kesl_tasks_human_name[$task]}"
    else
        report_fail ScanRemovableDrives "${kesl_tasks_human_name[$task]}"
    fi
done

echo 'Проверка значения общего параметра "UseKSN" программы Kaspersky Endpoint Security for Linux на соответствие сертифицированной конфигурации...'
if [[ $(kesl-control --get-app-settings | grep UseKSN | awk -F '=' '{print $2}') == "No" ]]; then
    echo -e $green"[SUCCESS]$default_color Значение общего параметра "UseKSN" программы является допустимым в сертифицированной конфигурации."
else
    echo -e $red"[FAIL]$default_color Значение общего параметра "UseKSN" программы НЕ является допустимым в сертифицированной конфигурации!"
fi

echo -e $default_color
read -p "Вы хотите произвести дополнительные проверки (не влияющие на состояние сертифицированности, но желательные для использования)? [Y/N]: " extra_checks
if [[ $extra_checks == "Y" ]] || [[ $extra_checks == "y" ]]; then
    echo "Проверка статуса задачи \"Проверка сьемных дисков\"..."
    if [[ $(get_task_state removable_drives_scan) != "Запущена" ]]; then
        report_warning "Задача \"Проверка сьемных дисков\" не запущена!"
    else
        echo -e $green"[SUCCESS]$default_color Задача \"Проверка сьемных дисков\" запущена!"
        echo "Проверка значения параметра \"ScanOpticalDrives\" задачи \"Проверка сьемных дисков\"..."
        if [[ $(kesl-control --get-settings removable_drives_scan ScanOpticalDrives | awk -F '=' '{print $2}') != "DetailedScan" ]]; then
            report_warning "Значение параметра \"ScanOpticalDrives\" задачи \"Проверка сьемных дисков\" настроено не оптимально. Лучше задать его как \"DetailedScan\"."
        else
            echo -e $green"[SUCCESS]$default_color Значение параметра \"ScanOpticalDrives\" задачи \"Проверка сьемных дисков\" настроено оптимально"
        fi
    fi
    echo "Проверка актуальности загруженных антивирусных баз..."
    updates_date=$(date --date $(kesl-control --app-info | grep "Дата последнего выпуска баз программы:" | awk -F " " '{print $6}') +"%s")
    now=$(date +"%s")
    if [[ $[($now - $updates_date) / 86400] > 90 ]]; then
        report_warning "Анивирусные базы не обновлялись больше 90 дней и устарели!"
    else
        echo -e $green"[SUCCESS]$default_color Антивирусные базы актуальны!"
    fi
    echo "Проверка расписания задачи \"Антивирусная проверка\"..."
    if [[ $(kesl-control --get-schedule scan_my_computer | awk -F '=' '{print $2}') == "Manual" ]]; then
        report_warning "Задача \"Антивирусная проверка\" настроена на ручной запуск, что не является лучшей практикой! Желательно переделать на автозапуск раз в определенный период времени."
    fi
else
    exit 0
fi