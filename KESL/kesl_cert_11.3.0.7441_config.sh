#!/bin/bash

green="\033[1;32m"
red="\033[1;31m"
yellow="\033[1;33m"
default_color="\033[0m"

function report_success {
    echo -e $green"[SUCCESS]$default_color $1"
}

function report_fail {
    echo -e $red"[FAIL]$default_color $1"
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

function start_kesl_task {
    echo "Запуск задачи \"${kesl_tasks_human_name[$1]}\"..."
    kesl-control --start-task $1 &> /dev/null
    exit_code=$?
    if [[ $exit_code == 0 ]]; then
        report_success "Задача \"${kesl_tasks_human_name[$1]}\" была запущена!"
    elif [[ $exit_code == 70 ]]; then
        report_warning "Задача \"${kesl_tasks_human_name[$1]}\" уже запущена!"
    else
        report_fail "Что-то пошло не так при запуске задачи \"${kesl_tasks_human_name[$1]}\"!"
    fi
}

# Запуск задачи "Защита от файловых угроз"
start_kesl_task file_threat_protection

# На вход функции подается два параметра: первый - ID задачи Kaspersky Enpoint Security for Linux, второй - имя настраиваемого параметра
function configure_kesl_task_parameter {
    case "$2" in
        "FirstAction" )
            value=Disinfect
        ;;
        "SecondAction" )
            value=Remove
        ;;
        "UseAnalyzer" )
            value=Yes
        ;;
        "HeuristicLevel" )
            value=Recommended
        ;;
        "ScanArchived" )
            value=Yes
        ;;
        "ScanSfxArchived" )
            value=Yes
        ;;
        "ScanMailBases" )
            value=Yes
        ;;
        "ScanByAccessType" )
            value=Open
        ;;
        "SourceType" )
            value=Custom
        ;;
        "ApplicationUpdateMode" )
            value=Disabled
        ;;
        "UseHostBlocker" )
            value=Yes
        ;;
        "ActionOnDetect" )
            value=Block
        ;;
        "ScanRemovableDrives" )
            value=DetailedScan
        ;;
        "ScanOpticalDrives" )
            value=DetailedScan
    esac
    kesl-control --set-settings $1 $2=$value
    if [[ $? == 0 ]]; then
        report_success "Значение параметра \"$2\" задачи \"${kesl_tasks_human_name[$1]}\" было успешно задано как \"$value\"."
    else
        report_fail "При установке значения параметра \"$2\" задачи \"${kesl_tasks_human_name[$1]}\" произошла ошибка!"
    fi
}

for parameter in FirstAction SecondAction UseAnalyzer HeuristicLevel ScanArchived ScanSfxArchived ScanMailBases ScanByAccessType SourceType ApplicationUpdateMode UseHostBlocker ActionOnDetect ScanRemovableDrives ScanOpticalDrives; do
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
        "ScanOpticalDrives" )
            tasks="removable_drives_scan"
        ;;
    esac
    echo "Задание значения параметра \"$parameter\" задач Kaspersky Endpoint Security for Linux..."
    for task in $tasks; do
        configure_kesl_task_parameter $task $parameter
    done
done

echo "Задание диска в дисководе источником обновлений антивирусных баз..."
cd_mount_point=$(grep /dev/sr0 /etc/fstab | awk -F ' ' '{print $2}')
kesl-control --set-settings update CustomSources.item_0000.URL=$cd_mount_point CustomSources.item_0000.Enabled=Yes ApplicationUpdateMode=Disabled
if [[ $? == 0 ]]; then
    report_success "Диск в дисководе был успешно задан как источник обновления антивирусных баз"
else
    report_fail "При задании диска в дисководе в качестве источника обвновлений произошла ошибка!"
fi

echo 'Задание значения общего параметра "UseKSN" Kaspersky Endpoint Security for Linux для соответствия состоянию сертифицированной конфигурации...'
kesl-control --set-app-settings UseKSN=No
if [[ $? == 0 ]]; then
    report_success "Значение общего параметра \"UseKSN\" Kaspersky Endpoint Security for Linux было успешно задано как \"No\"."
else
    report_fail "При установке значения общего параметра \"UseKSN\" Kaspersky Endpoint Security for Linux произошла ошибка!"
fi

echo -e $default_color
read -p "Вы хотите произвести дополнительные настройки (не влияющие на состояние сертифицированности, но желательные для использования)? [Y/N]: " extra_settings
if [[ $extra_settings == "Y" || $extra_settings == "y" ]]; then
    # Запуск задачи "Проверка сьемных дисков"
    start_kesl_task removable_drives_scan
    echo "Задание расписания задачи \"Антивирусная проверка\" на запуск раз в неделю..."
    if kesl-control --set-schedule scan_my_computer RuleType=Weekly StartTime="$(env LANG=en_US date +"%H:%M:%S;%a")" RandomInterval=0 RunMissedStartRules=Yes; then
        report_success "Задача \"Антивирусная проверка\" поставлена в расписании на запуск раз в неделю (пропущенные задачи выполнятся при первой возможности)."
    else
        report_fail "При установке расписания задачи \"Антивирусная проверка\" произошла ошибка!"
    fi
else
    exit 0
fi