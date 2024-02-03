#!/bin/bash

green="\033[1;32m"
red="\033[1;31m"
yellow="\033[1;33m"
default_color="\033[0m"

function report_success {
    echo -e $green"[SUCCESS]$default_color Значение параметра \"$1\" задачи \"$2\" является допустимым в сертифицированной конфигурации."
}

function report_fail {
    echo -e $red"[FAIL]$default_color Значение параметра \"$1\" задачи \"$2\" НЕ является допустимым в сертифицированной конфигурации!"
}

function report_warning {
    echo -e $yellow"[WARNING]$default_color $1"
}

if ! groups | grep -q kesladmin; then
    report_fail "Скрипт необходимо запускать от имени учетной записи, входящей в группу \"kesladmin\"! Необходимо выполнить команду \"sudo gpasswd --add kesladmin $(whoami)\"."
    exit 1
fi

if ! systemctl is-active kesl.service &> /dev/null; then
    report_fail "Служба Kaspersky Endpoint Security for Linux не запущена! Необходимо выполнить команду \"sudo systemctl start kesl.service && sudo systemctl enable kesl.service\"."
    exit 1
fi

function get_task_state {
    kesl-control --get-task-state $1 | grep Состояние | awk -F ':' '{ gsub(/ /, ""); print $2 }'
}

echo "Проверка статуса активации программы..."
if ! kesl-control -L --query &> /dev/null; then
    echo -e $red"[FAIL]$default_color Программа не активирована! Лицензионный ключ не добавлен"
else
    echo -e $green"[SUCCESS]$default_color Программа активирована! Лицензионный ключ добавлен"
fi

echo "Проверка загруженности антивирусных баз..."
if [[ $(kesl-control --app-info --json | grep "Базы программы загружены" | awk -F ':' '{ gsub(/ /, ""); print $2}' | tr -d "\"",",") == Да ]]; then
    echo -e $green"[SUCCESS]$default_color Антивирусные базы программы загружены!"
else
    echo -e $red"[FAIL]$default_color Антивирусные базы программы не загружены!"
fi

echo "Проверка статуса задачи \"Защита от файловых угроз\"..."
if [[ $(get_task_state file_threat_protection) != Запущена ]]; then
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
            if [[ $(kesl-control --get-settings $1 "FirstAction" | awk -F '=' '{print $2}') == Remove ]]; then
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

for parameter in FirstAction SecondAction UseAnalyzer HeuristicLevel ScanArchived ScanSfxArchived ScanMailBases ScanByAccessType SourceType ApplicationUpdateMode UseHostBlocker ActionOnDetect ScanRemovableDrives; do
    case "$parameter" in
        "FirstAction" )
            tasks="file_threat_protection scan_my_computer scan_file critical_areas_scan container_scan custom_container_scan"
        ;;
        "SecondAction" )
            tasks="file_threat_protection scan_my_computer scan_file critical_areas_scan container_scan custom_container_scan"
        ;;
        "UseAnalyzer" )
            tasks="file_threat_protection scan_my_computer scan_file critical_areas_scan container_scan custom_container_scan"
        ;;
        "HeuristicLevel" )
            tasks="file_threat_protection scan_my_computer scan_file critical_areas_scan container_scan custom_container_scan"
        ;;
        "ScanArchived " )
            tasks="file_threat_protection scan_my_computer scan_file critical_areas_scan container_scan custom_container_scan"
        ;;
        "ScanSfxArchived" )
            tasks="file_threat_protection scan_my_computer scan_file critical_areas_scan container_scan custom_container_scan"
        ;;
        "ScanMailBases" )
            tasks="file_threat_protection scan_my_computer scan_file critical_areas_scan container_scan custom_container_scan"
        ;;
        "ScanByAccessType" )
            tasks="file_threat_protection"
        ;;
        "SourceType" )
            tasks="update"
        ;;
        "ApplicationUpdateMode" )
            tasks="update"
        ;;
        "UseHostBlocker" )
            tasks="anti_cryptor"
        ;;
        "ActionOnDetect" )
            tasks="web_threat_protection"
        ;;
        "ScanRemovableDrives" )
            tasks="removable_drives_scan"
        ;;
    esac
    echo "Проверка значения параметра \"$parameter\" задач Kaspersky Endpoint Security for Linux на соответствие сертифицированной конфигурации..."
    for task in $tasks; do
        if is_parameter_value_secure_for_certified_config $task $parameter; then
            report_success $parameter "${kesl_tasks_human_name[$task]}"
        else
            report_fail $parameter "${kesl_tasks_human_name[$task]}"
        fi
    done
done

echo 'Проверка значения общего параметра "UseKSN" программы Kaspersky Endpoint Security for Linux на соответствие сертифицированной конфигурации...'
if [[ $(kesl-control --get-app-settings | grep UseKSN | awk -F '=' '{print $2}') == No ]]; then
    echo -e $green"[SUCCESS]$default_color Значение общего параметра "UseKSN" программы является допустимым в сертифицированной конфигурации."
else
    echo -e $red"[FAIL]$default_color Значение общего параметра "UseKSN" программы НЕ является допустимым в сертифицированной конфигурации!"
fi

echo -e $default_color
read -p "Вы хотите произвести дополнительные проверки (не влияющие на состояние сертифицированности, но желательные для использования)? [Y/N]: " extra_checks
if [[ "$extra_checks" == Y || "$extra_checks" == y ]]; then
    echo "Проверка статуса задачи \"Проверка сьемных дисков\"..."
    if [[ $(get_task_state removable_drives_scan) != Запущена ]]; then
        report_warning "Задача \"Проверка сьемных дисков\" не запущена!"
    else
        echo -e $green"[SUCCESS]$default_color Задача \"Проверка сьемных дисков\" запущена!"
        echo "Проверка значения параметра \"ScanOpticalDrives\" задачи \"Проверка сьемных дисков\"..."
        if [[ $(kesl-control --get-settings removable_drives_scan ScanOpticalDrives | awk -F '=' '{print $2}') != DetailedScan ]]; then
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
    if [[ $(kesl-control --get-schedule scan_my_computer | awk -F '=' '{print $2}') == Manual ]]; then
        report_warning "Задача \"Антивирусная проверка\" настроена на ручной запуск, что не является лучшей практикой! Желательно переделать на автозапуск раз в определенный период времени."
    else
        echo -e $green"[SUCCESS]$default_color Задача \"Антивирусная проверка\" запускается автоматически!"
    fi
else
    exit 0
fi