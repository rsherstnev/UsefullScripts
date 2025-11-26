#!/usr/bin/env bash

# Данный скрипт был разработан для (и протестирован на) версии Kaspersky Endpoint Security for Linux 12.2.0.2412

_RED_COLOR="\e[1;31m"
_GREEN_COLOR="\e[1;32m"
_YELLOW_COLOR="\e[1;33m"
_COLOR_RESET="\e[0m"

# Человекочитаемые имена задач для понятного логгирования на консоль
declare -A tasks_human_name=(
    ["file_threat_protection"]="Защита от файловых угроз"
    ["scan_my_computer"]="Поиск вредоносного ПО"
    ["scan_file"]="Выборочная проверка файлов"
    ["critical_areas_scan"]="Проверка важных областей"
    ["update"]="Обновление"
    ["rollback"]="Откат обновления баз"
    ["license"]="Лицензирование"
    ["system_integrity_monitoring"]="Контроль целостности системы"
    ["firewall_management"]="Управление сетевым экраном"
    ["anti_cryptor"]="Защита от шифрования"
    ["web_threat_protection"]="Защита от веб-угроз"
    ["device_control"]="Контроль устройств"
    ["removable_drives_scan"]="Проверка съемных дисков"
    ["network_threat_protection"]="Защита от сетевых угроз"
    ["container_scan"]="Проверка контейнеров"
    ["custom_container_scan"]="Выборочная проверка контейнеров"
    ["behavior_detection"]="Анализ поведения"
    ["application_control"]="Контроль приложений"
    ["inventory_scan"]="Инвентаризация"
    ["kataedr"]="Интеграция с Kaspersky Endpoint Detection and Response (KATA)"
    ["web_control"]="Веб-Контроль"
    ["standalone_sandbox"]="Интеграция с KATA Sandbox"
    ["kataedr_prevention"]="Запрет запуска объектов (EDR (KATA))"
    ["edro_prevention"]="Запрет запуска объектов (EDR Optimum)"
    ["kuma"]="Интеграция с KUMA"
)

# Перечень задач, в которых присутствует искомый параметр
declare -A parameter_tasks_list=(
    ["FirstAction"]="file_threat_protection scan_my_computer scan_file critical_areas_scan container_scan custom_container_scan"
    ["SecondAction"]="file_threat_protection scan_my_computer scan_file critical_areas_scan container_scan custom_container_scan"
    ["UseExcludeMasks"]="file_threat_protection scan_my_computer scan_file critical_areas_scan container_scan custom_container_scan anti_cryptor"
    ["UseAnalyzer"]="file_threat_protection scan_my_computer scan_file critical_areas_scan container_scan custom_container_scan"
    ["HeuristicLevel"]="file_threat_protection scan_my_computer scan_file critical_areas_scan container_scan custom_container_scan"
    ["ScanArchived"]="file_threat_protection scan_my_computer scan_file critical_areas_scan container_scan custom_container_scan"
    ["ScanSfxArchived"]="file_threat_protection scan_my_computer scan_file critical_areas_scan container_scan custom_container_scan"
    ["ScanMailBases"]="file_threat_protection scan_my_computer scan_file critical_areas_scan container_scan custom_container_scan"
    ["ScanByAccessType"]="file_threat_protection"
    ["SourceType"]="update"
    ["ApplicationUpdateMode"]="update"
    ["UseHostBlocker"]="anti_cryptor"
    ["ActionOnDetect"]="web_threat_protection"
    ["OperationMode"]="device_control"
    ["AppControlRulesAction"]="application_control"
    ["ScanRemovableDrives"]="removable_drives_scan"
    ["ScanOpticalDrives"]="removable_drives_scan"
)

# Безопасные значения для параметров задач в сертифицированной конфигурации
declare -A tasks_certified_parameters_value=(
    ["FirstAction"]="Remove"
    ["SecondAction"]="Remove"
    ["UseExcludeMasks"]="No"
    ["UseAnalyzer"]="Yes"
    ["HeuristicLevel"]="Deep"
    ["ScanArchived"]="Yes"
    ["ScanSfxArchived"]="Yes"
    ["ScanMailBases"]="Yes"
    ["ScanByAccessType"]="SmartCheck"
    ["SourceType"]="Custom"
    ["ApplicationUpdateMode"]="Disabled"
    ["UseHostBlocker"]="Yes"
    ["ActionOnDetect"]="Block"
    ["OperationMode"]="Block"
    ["AppControlRulesAction"]="Block"
    ["ScanRemovableDrives"]="DetailedScan"
    ["ScanOpticalDrives"]="DetailedScan"
)

report_step() {
    echo
    echo "[STEP] $1..."
}

report_success() {
    echo -e "${_GREEN_COLOR}[SUCCESS] $1${_COLOR_RESET}"
}

report_warning() {
    echo -e "${_YELLOW_COLOR}[WARNING] $1${_COLOR_RESET}"
}

report_fail() {
    echo -e "${_RED_COLOR}[FAIL] $1${_COLOR_RESET}"
}

start_kesl_task() {
    report_step "Запуск задачи \"${tasks_human_name[$1]}\""
    kesl-control --start-task $1 &> /dev/null
    case $? in
        0)
            report_success "Задача \"${tasks_human_name[$1]}\" была успешно запущена"
            ;;
        70)
            report_success "Задача \"${tasks_human_name[$1]}\" уже запущена"
            ;;
        *)
            report_fail "Что-то пошло не так при запуске задачи \"${tasks_human_name[$1]}\""
            ;;
    esac
}

# На вход функции подается два параметра:
# Первый: ID задачи Kaspersky Enpoint Security for Linux
# Второй: Настраиваемый параметр
configure_kesl_task_parameter() {
    if kesl-control --set-settings $1 $2="${tasks_certified_parameters_value["$2"]}" &>/dev/null; then
        report_success "Значение параметра \"$2\" задачи \"${tasks_human_name[$1]}\" было успешно задано в \"${tasks_certified_parameters_value["$2"]}\""
    else
        report_fail "При установке значения параметра \"$2\" задачи \"${tasks_human_name[$1]}\" произошла ошибка (возможно, соответствующая задача отключена в настройках)"
    fi
}

if [ "$EUID" -ne 0 ] && ! groups | grep -qw kesladmin; then
    report_fail "Скрипт необходимо запускать от имени учетной записи, входящей в группу \"kesladmin\", либо от имени суперпользователя"
    exit 1
fi

if ! systemctl is-active kesl.service &> /dev/null; then
    report_fail "Служба Kaspersky Endpoint Security for Linux не запущена"
    exit 1
fi

# Запуск задачи "Защита от файловых угроз"
start_kesl_task file_threat_protection

for parameter in \
    FirstAction \
    SecondAction \
    UseAnalyzer \
    HeuristicLevel \
    ScanArchived \
    ScanSfxArchived \
    ScanMailBases \
    ScanByAccessType \
    SourceType \
    ApplicationUpdateMode \
    UseHostBlocker \
    ActionOnDetect \
    ScanRemovableDrives \
    ScanOpticalDrives;
do
    report_step "Задание значения параметра \"$parameter\" задач Kaspersky Endpoint Security for Linux"
    for task in ${parameter_tasks_list[$parameter]}; do
        configure_kesl_task_parameter $task $parameter
    done
done

report_step "Задание диска в дисководе источником обновлений антивирусных баз"
cd_mount_point=$(grep /dev/sr0 /etc/fstab | awk -F ' ' '{print $2}')
if kesl-control --set-settings update CustomSources.item_0000.URL=$cd_mount_point CustomSources.item_0000.Enabled=Yes ApplicationUpdateMode=Disabled &> /dev/null; then
    report_success "Диск в дисководе был успешно задан как источник обновления антивирусных баз"
else
    report_fail "При задании диска в дисководе в качестве источника обвновлений произошла ошибка"
fi

report_step "Задание значения общего параметра \"UseKSN\" Kaspersky Endpoint Security for Linux для соответствия состоянию сертифицированной конфигурации"
if kesl-control --set-app-settings UseKSN=No &> /dev/null; then
    report_success "Значение общего параметра \"UseKSN\" Kaspersky Endpoint Security for Linux было успешно задано как \"No\""
else
    report_fail "При установке значения общего параметра \"UseKSN\" Kaspersky Endpoint Security for Linux произошла ошибка"
fi

report_step "Задание значения общего параметра \"CloudMode\" Kaspersky Endpoint Security for Linux для соответствия состоянию сертифицированной конфигурации"
if kesl-control --set-app-settings CloudMode=No &> /dev/null; then
    report_success "Значение общего параметра \"CloudMode\" Kaspersky Endpoint Security for Linux было успешно задано как \"No\""
else
    report_fail "При установке значения общего параметра \"CloudMode\" Kaspersky Endpoint Security for Linux произошла ошибка"
fi

report_step "Задание значения общего параметра \"UseMDR\" Kaspersky Endpoint Security for Linux для соответствия состоянию сертифицированной конфигурации"
if kesl-control --set-app-settings UseMDR=No &> /dev/null; then
    report_success "Значение общего параметра \"UseMDR\" Kaspersky Endpoint Security for Linux было успешно задано как \"No\""
else
    report_fail "При установке значения общего параметра \"UseMDR\" Kaspersky Endpoint Security for Linux произошла ошибка"
fi

echo
read -p "Вы хотите произвести дополнительные настройки (не влияющие на состояние сертифицированности, но желательные для использования)? [Y/N]: " extra_settings

if [[ $extra_settings == "Y" || $extra_settings == "y" ]]; then
    # Запуск задачи "Проверка сьемных дисков"
    start_kesl_task removable_drives_scan

    report_step "Задание расписания задачи \"Антивирусная проверка\" на запуск раз в неделю"
    if kesl-control --set-schedule scan_my_computer RuleType=Weekly StartTime="$(env LANG=en_US date +"%H:%M:%S;%a")" RandomInterval=0 RunMissedStartRules=Yes &> /dev/null; then
        report_success "Задача \"Антивирусная проверка\" поставлена в расписании на запуск раз в неделю (пропущенные задачи выполнятся при первой возможности)"
    else
        report_warning "При установке расписания задачи \"Антивирусная проверка\" произошла ошибка"
    fi

    echo
else
    echo
    exit 0
fi