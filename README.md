# UsefullScripts

В данном репозитории находятся скрипты, автоматизирующие тот или иной мой рабочий процесс

## kesl_cert_11.3.0.7441_check.sh

Данный скрипт позволяет провести проверку конфигурации программы "Kaspersky Endpoint Security for Linux" на соответствие сертифицирванному состоянию в соответствии с руководством по эксплуатации на данное средство антивирусной защиты.

### Описание работы скрипта

В ходе работы проверяются следующие параметры:

- Запущена ли служба программы "Kaspersky Endpoint Security for Linux"
- Активирована ли программа лицензионным ключем
- Загружены ли в программу антивирусные базы
- Запущена ли задача "Защита от файловых угроз"
- Значения параметров задач программы на соответствие сертифицированной конфигурации (в соответствии с приложением "Значения параметров программы в сертифицированной конфигурации" к руководству по эксплуатации)
- Отказ от участия в KSN

В скрипте также присутствуют необязательные проверки, не влияющие на состояние сертифицированности, но желательные в использовании:

- Запущена ли задача "Проверка сьемных дисков"
- Как давно в последний раз обновлялись антивирусные базы? (при > 90 дней выводится предупреждение)
- Расписание задачи "Антивирусная проверка": нежелательно чтобы она выполнялась в ручном режиме, лучше задать автоматическую периодическую проверку

## kesl_cert_11.3.0.7441_config.sh

Данный скрипт позволяет произвести конфигурацию программы "Kaspersky Endpoint Security for Linux" для соответствия сертифицирванному состоянию в соответствии с руководством по эксплуатации на данное средство антивирусной защиты.

### Описание работы скрипта

В ходе работы выполняются следующие настройки:

- Запускается задача "Защита от файловых угроз"
- Устанавливаются значения параметров задач программы для соответствия сертифицированной конфигурации (в соответствии с приложением "Значения параметров программы в сертифицированной конфигурации" к руководству по эксплуатации)
- Отключается участие в KSN

В скрипте также присутствуют необязательные настройки, не влияющие на состояние сертифицированности, но желательные в использовании:

- Запуск задачи "Проверка сьемных дисков"
- Установка расписания задачи "Антивирусная проверка" на запуск раз в неделю

## kali_linux_config.sh

Данный скрипт позволяет произвести настройку операционной системы Kali Linux для решения CTF тасков. Его необходимо запускать до скрипта `kali_linux_gui_config.sh`

### Описание работы скрипта

Скрипт необходимо запускать от имени пользователя root, либо с использованием `sudo`

## kali_linux_gui_config.sh

Данный скрипт позволяет произвести настройку операционной системы Kali Linux. Его необходимо запускать после отработки скрипта `kali_linux_config.sh` и входа через GUI учетной записью root

### Описание работы скрипта

Скрипт необходимо запускать от имени пользователя root, либо с использованием `sudo`

## alse_change_user_passwords_auto.sh

Данный скрипт позволяет изменить пароли всех пользователей системы на автоматически сгенерированые

### Описание работы скрипта

Перед использованием необходимо изменить логины на логины из своей системы

## alse_change_user_passwords_manual.sh

Данный скрипт позволяет изменить пароли всех пользователей системы вручную

### Описание работы скрипта

Перед использованием необходимо изменить логины на логины из своей системы