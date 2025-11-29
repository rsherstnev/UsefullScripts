# Find-WhoDeletedFile.ps1

Скрипт предназначен для поиска событий удалений файлов на файловом сервере Windows (при условии, что соответствующие настройки аудита заданы)

## Описание работы скрипта

Сначала выполняется поиск всех событий с кодами 4663, 4659 в журнале "Безопасность"

После чего фильтруются именно события удаления файлов по полю "Маска доступа"

И удаляются дубликаты событий путем добавления событий в структуру данных "Хеш таблица"

Дубликаты событий наблюдаются если удалять файл в расшаренной папке на самом сервере (получив доступ на него с консоли или через RDP), а не удаленно через SMB (зайдя в проводнике по UNC пути)

## Примеры использования скрипта

> [!WARNING]
> Если командлет Invoke-WebRequest при скачивании файла выдает ошибку (преимущественно на Windows Server)
> > Запрос был прерван: Не удалось создать защищенный канал SSL/TLS
> 
> Можно явно указать команде какую версию протокола использовать, например:
> ```powershell
> [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri "https://raw.githubusercontent.com/rsherstnev/UsefullScripts/master/Windows/Find-WhoDeletedFile.ps1" -OutFile Find-WhoDeletedFile.ps1
> ```

### Предварительная загрузка скрипта в файловую систему

Загрузить скрипт с GitHub в файловую систему
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/rsherstnev/UsefullScripts/master/Windows/Find-WhoDeletedFile.ps1" -OutFile Find-WhoDeletedFile.ps1
```

Импортировать функцию, описанную в файле, в текущую PowerShell сессию
```powershell
. .\Find-WhoDeletedFile.ps1
```

### Исполнение в памяти без записи на диск

Импортировать функцию, описанную в файле, в текущую PowerShell сессию
```powershell
Invoke-Expression (New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/rsherstnev/UsefullScripts/master/Windows/Find-WhoDeletedFile.ps1")
```

### Использование импортированной функции

#### Возможные опции

| Опция      | Функционал                                                                                                                           |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| StartTime  | Если не указать явно - будет подразумеваться "Сегодня"<br>Иначе - поиск будет производиться с указанного времени до текущего момента |
| FileName   | Паттерн для поиска<br>Например, если указать "txt", будут искаться все файлы, которые в своем пути содержат это слово                |
| GUI        | Если не указать данную опцию, вывод найденных событий будет осуществлен в консоль, иначе - в графическое окно                        |

#### Примеры

Вывести события удаления docx файлов за сегодня в консоль
```powershell
Find-WhoDeletedFile -FileName "docx"
```

Вывести события удаления docx файлов за сегодня в графическое окно
```powershell
Find-WhoDeletedFile -FileName "docx" -Gui $true
```

Вывести события удаления всех файлов в период со вчера до текущего момента в консоль
```powershell
Find-WhoDeletedFile -StartTime (Get-Date).AddDays(-1)
```

Вывести события удаления pdf файлов в период с 15 января 2024 года до текущего момента в консоль
```powershell
Find-WhoDeletedFile -FileName "pdf" -StartTime "2024-01-15"
```

Поиск событий удаления конкретного файла в период с 15 января 2024 года до текущего момента в консоль
```powershell
Find-WhoDeletedFile -FileName "SampleToSearch.pdf" -StartTime "2024-01-15"
```

# Get-WindowsSharesAudit.ps1

Скрипт предназначен для анализа настроек аудита файловых операций на файловом сервере Windows

## Описание работы скрипта

- Проверка глобальных настроек аудита файловый операций в ОС
- Проверка настроек аудита для каждой расшаренной на сервере директории

## Примеры использования скрипта

> [!WARNING]
> Если командлет Invoke-WebRequest при скачивании файла выдает ошибку (преимущественно на Windows Server)
> > Запрос был прерван: Не удалось создать защищенный канал SSL/TLS
> 
> Можно явно указать команде какую версию протокола использовать, например:
> ```powershell
> [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri "https://raw.githubusercontent.com/rsherstnev/UsefullScripts/master/Windows/Get-WindowsSharesAudit.ps1" -OutFile Get-WindowsSharesAudit.ps1
> ```

### Предварительная загрузка скрипта в файловую систему

Загрузить скрипт с GitHub в файловую систему
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/rsherstnev/UsefullScripts/master/Windows/Get-WindowsSharesAudit.ps1" -OutFile Get-WindowsSharesAudit.ps1
```

Импортировать функцию, описанную в файле, в текущую PowerShell сессию
```powershell
. .\Get-WindowsSharesAudit.ps1
```

### Исполнение в памяти без записи на диск

Импортировать функцию, описанную в файле, в текущую PowerShell сессию
```powershell
Invoke-Expression (New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/rsherstnev/UsefullScripts/master/Windows/Get-WindowsSharesAudit.ps1")
```

### Использование импортированной функции

Проверка глобальных настроек аудита файловый операций в ОС
```powershell
Get-OSAuditSettings
```

Проверка настроек аудита для каждой расшаренной на сервере директории
```powershell
Get-AllSharesAuditSettings
```

Совместное выполнение функций `Get-OSAuditSettings` и `Get-AllSharesAuditSettings`
```powershell
Get-WindowsSharesAudit
```

# Get-LogonEvents.ps1

Скрипт для вывода интересующих событий аутентификации

## Описание работы скрипта

Скрипт получает все события аутентификации в системе, а затем фильтрует их по указанным параметрам и выводит пользователю

## Примеры использования скрипта

> [!WARNING]
> Если командлет Invoke-WebRequest при скачивании файла выдает ошибку (преимущественно на Windows Server)
> > Запрос был прерван: Не удалось создать защищенный канал SSL/TLS
> 
> Можно явно указать команде какую версию протокола использовать, например:
> ```powershell
> [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri "https://raw.githubusercontent.com/rsherstnev/UsefullScripts/master/Windows/Get-LogonEvents.ps1" -OutFile Get-LogonEvents.ps1
> ```

### Предварительная загрузка скрипта в файловую систему

Загрузить скрипт с GitHub в файловую систему
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/rsherstnev/UsefullScripts/master/Windows/Get-LogonEvents.ps1" -OutFile Get-LogonEvents.ps1
```

Импортировать функцию, описанную в файле, в текущую PowerShell сессию
```powershell
. .\Get-LogonEvents.ps1
```

### Исполнение в памяти без записи на диск

Импортировать функцию, описанную в файле, в текущую PowerShell сессию
```powershell
Invoke-Expression (New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/rsherstnev/UsefullScripts/master/Windows/Get-LogonEvents.ps1")
```

### Использование импортированной функции

#### Возможные опции

| Опция            | Функционал                                                                                                                                                                                                                                                                                                                                            |
| ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| StartTime        | Если не указать явно - будет подразумеваться "Сегодня"<br>Иначе - поиск будет производиться с указанного времени до текущего момента                                                                                                                                                                                                                  |
| IncludeLogonType | Типы событий, которые нужно включить в вывод<br>Если не указать - в вывод будут включены события всех типов                                                                                                                                                                                                                                           |
| ExcludeLogonType | Типы событий, которые нужно исключить из вывода<br>Если не указать - будут включены все события, указанные в опции -IncludeLogonType<br>Можно использовать вместе с опцией -IncludeLogonType, но опция -ExcludeLogonType будет иметь приоритет<br>Если один и тот же тип события будет включен в обе опции, он не будет выводиться в итоговой выборке |
| GUI              | Если не указать данную опцию, вывод найденных событий будет осуществлен в консоль, иначе - в графическое окно                                                                                                                                                                                                                                         |


#### Примеры

Вывести события интерактивного входа за текущий день в консоль
```powershell
Get-LogonEvents -IncludeLogonType Interactive
```

Вывести события входа всех типов (кроме сетевого) за текущий день в консоль
```powershell
Get-LogonEvents -ExcludeLogonType Network
```

Вывести события интерактивного и удаленного интерактивного входа за текущий день в графическое окно
```powershell
Get-LogonEvents -IncludeLogonType Interactive, RemoteInteractive -GUI $true
```

Вывести события интерактивного и удаленного интерактивного входа в период с 25.11.2025 до текущего момента в консоль
```powershell
Get-LogonEvents -IncludeLogonType Interactive, RemoteInteractive -StartTime "2025-11-25"
```
