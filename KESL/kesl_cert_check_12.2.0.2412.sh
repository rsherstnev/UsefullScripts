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
    ["FirstAction"]="Disinfect Remove Recommended"
    ["SecondAction"]="Remove"
    ["UseExcludeMasks"]="No"
    ["UseAnalyzer"]="Yes"
    ["HeuristicLevel"]="Light Medium Deep Recommended"
    ["ScanArchived"]="Yes"
    ["ScanSfxArchived"]="Yes"
    ["ScanMailBases"]="Yes"
    ["ScanByAccessType"]="SmartCheck OpenAndModify Open"
    ["SourceType"]="KLServers SCServer Custom"
    ["ApplicationUpdateMode"]="Disabled"
    ["UseHostBlocker"]="Yes"
    ["ActionOnDetect"]="Block"
    ["OperationMode"]="Block"
    ["AppControlRulesAction"]="Block"
    ["ScanRemovableDrives"]="DetailedScan QuickScan"
    ["ScanOpticalDrives"]="DetailedScan QuickScan"
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

get_task_state() {
    kesl-control --get-task-state $1 | grep Состояние | awk -F ':' '{ gsub(/ /, ""); print $2 }'
}

get_task_parameter_value() {
    kesl-control --get-settings $1 $2 | awk -F '=' '{print $2}'
}

# Проверяет наличие элемента в массиве
# В дальнейшем используется для определения является ли значение параметра задачи KESL допустимым в сертифицированной конфигурации продукта
is_value_in_array() {
    IFS=' ' read -ra words <<< "$2"

    for word in "${words[@]}"; do
        if [[ "$word" == "$1" ]]; then
            return 0
        fi
    done

    return 1
}

if ! groups | grep -qw kesladmin; then
    report_fail "Скрипт необходимо запускать от имени учетной записи, входящей в группу \"kesladmin\""
    exit 1
fi

if ! systemctl is-active kesl.service &> /dev/null; then
    report_fail "Служба Kaspersky Endpoint Security for Linux не запущена"
    exit 1
fi

report_step "Проверка статуса активации программы"
if ! kesl-control -L --query &> /dev/null; then
    report_fail "Программа не активирована, лицензионный ключ не добавлен"
else
    report_success "Программа активирована, лицензионный ключ добавлен"
fi

report_step "Проверка загруженности антивирусных баз"
if [[ $(kesl-control --app-info | grep "Базы приложения загружены:" | awk -F " " '{print $4}') == "Да" ]]; then
    report_success "Антивирусные базы программы загружены"
else
    report_fail "Антивирусные базы программы не загружены"
fi

report_step "Проверка статуса задачи \"Защита от файловых угроз\""
if [[ $(get_task_state file_threat_protection) != "Запущена" ]]; then
    report_fail "Задача \"Защита от файловых угроз\" не запущена"
else
    report_success "Задача \"Защита от файловых угроз\" запущена"
fi

# Условие признания любого значения параметра "SecondAction" сертифицированным если значение параметра "FirstAction" == "Remove" выпущено намеренно
# В целях упрощения логики скрипта, любая защита поверх не будет лишней
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
    ScanRemovableDrives;
do
    report_step "Проверка значения параметра \"$parameter\" задач Kaspersky Endpoint Security for Linux на соответствие сертифицированной конфигурации"
    for task in ${parameter_tasks_list[$parameter]}; do
        task_parameter_value=$(get_task_parameter_value $task $parameter)
        if is_value_in_array $task_parameter_value "${tasks_certified_parameters_value[$parameter]}"; then
            report_success "Значение \"$task_parameter_value\" параметра \"$parameter\" является допустимым в сертифицированной конфигурации для задачи \"${tasks_human_name[$task]}\""
        else
            report_fail "Значение \"$task_parameter_value\" параметра \"$parameter\" НЕ является допустимым в сертифицированной конфигурации для задачи \"${tasks_human_name[$task]}\""
        fi
    done
done

report_step "Проверка значения общего параметра \"UseKSN\" программы Kaspersky Endpoint Security for Linux на соответствие сертифицированной конфигурации"
if [[ $(kesl-control --get-app-settings | grep UseKSN | awk -F '=' '{print $2}') == "No" ]]; then
    report_success "Значение общего параметра \"UseKSN\" программы является допустимым в сертифицированной конфигурации"
else
    report_fail "Значение общего параметра \"UseKSN\" программы НЕ является допустимым в сертифицированной конфигурации"
fi

report_step "Проверка значения общего параметра \"CloudMode\" программы Kaspersky Endpoint Security for Linux на соответствие сертифицированной конфигурации"
if [[ $(kesl-control --get-app-settings | grep CloudMode | awk -F '=' '{print $2}') == "No" ]]; then
    report_success "Значение общего параметра \"CloudMode\" программы является допустимым в сертифицированной конфигурации"
else
    report_fail "Значение общего параметра \"CloudMode\" программы НЕ является допустимым в сертифицированной конфигурации"
fi

report_step "Проверка значения общего параметра \"UseMDR\" программы Kaspersky Endpoint Security for Linux на соответствие сертифицированной конфигурации"
if [[ $(kesl-control --get-app-settings | grep UseMDR | awk -F '=' '{print $2}') == "No" ]]; then
    report_success "Значение общего параметра \"UseMDR\" программы является допустимым в сертифицированной конфигурации"
else
    report_fail "Значение общего параметра \"UseMDR\" программы НЕ является допустимым в сертифицированной конфигурации"
fi

echo
read -p "Вы хотите произвести дополнительные проверки (не влияющие на состояние сертифицированности, но желательные для использования)? [Y/N]: " extra_checks

if [[ "$extra_checks" == "Y" || "$extra_checks" == "y" ]]; then

    report_step "Проверка статуса задачи \"Проверка сьемных дисков\""
    if [[ $(get_task_state removable_drives_scan) != "Запущена" ]]; then
        report_warning "Задача \"Проверка сьемных дисков\" не запущена"
    else
        report_success "Задача \"Проверка сьемных дисков\" запущена"
        report_step "Проверка значения параметра \"ScanOpticalDrives\" задачи \"Проверка сьемных дисков\""
        if is_value_in_array removable_drives_scan "${tasks_certified_parameters_value["ScanOpticalDrives"]}"; then
            report_warning "Значение параметра \"ScanOpticalDrives\" задачи \"Проверка сьемных дисков\" настроено не оптимально (лучше задать его в \"DetailedScan\")"
        else
            report_success "Значение параметра \"ScanOpticalDrives\" задачи \"Проверка сьемных дисков\" настроено оптимально"
        fi
    fi

    report_step "Проверка актуальности загруженных антивирусных баз"
    updates_date=$(date --date $(kesl-control --app-info | grep "Дата последнего выпуска баз приложения:" | awk -F " " '{print $6}') +"%s")
    now=$(date +%s)
    if [[ $(( (now - updates_date) / 86400 )) -gt 90 ]]; then
        report_warning "Антивирусные базы не обновлялись больше 90 дней и устарели"
    else
        report_success "Антивирусные базы актуальны"
    fi
    
    report_step "Проверка расписания задачи \"Антивирусная проверка\""
    if [[ $(kesl-control --get-schedule scan_my_computer | awk -F '=' '{print $2}') == "Manual" ]]; then
        report_warning "Задача \"Антивирусная проверка\" настроена на ручной запуск (рекомендуемо - автозапуск раз в определенный период времени)"
    else
        report_success "Задача \"Антивирусная проверка\" запускается автоматически"
    fi
else
    exit 0
fi