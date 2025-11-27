# Анализ настроек аудита расшаренных ресурсов текущего ПК

# Проверка глобальной настройки аудита в ОС
function Get-OSAuditSettings {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $audit_settings = auditpol /get /subcategory:"{0CCE921D-69AE-11D9-BED3-505054503030}"

    Write-Host
    if ($audit_settings -match "Success and Failure") {
        Write-Host "В ОС включено логгирование как успешных, так и неуспешных доступов к объектам файловой системы!" -ForegroundColor Green
    } elseif ($audit_settings -match "Success") {
        Write-Host "В ОС включено логгирование только успешных доступов к объектам файловой системы, возможно, лучше донастроить логгирование неуспешных доступов!" -ForegroundColor Yellow
        Write-Host "Настраивается логгирование в GPO по адресу: Конфигурация компьютера -> Конфигурация Windows -> Параметры безопасности -> Конфигурация расширенной политики аудита -> Доступ к объектам -> Аудит файловой системы" -ForegroundColor White
    } elseif ($audit_settings -match "Failure") {
        Write-Host "В ОС включено логгирование только неуспешных доступов к объектам файловой системы, возможно, лучше донастроить логгирование успешных доступов!" -ForegroundColor Yellow
        Write-Host "Настраивается логгирование в GPO по адресу: Конфигурация компьютера -> Конфигурация Windows -> Параметры безопасности -> Конфигурация расширенной политики аудита -> Доступ к объектам -> Аудит файловой системы" -ForegroundColor White
    } else {
        Write-Host "В ОС ОТКЛЮЧЕНО логгирование доступов к объектам файловой системы!" -ForegroundColor Red
        Write-Host "Настраивается логгирование в GPO по адресу: Конфигурация компьютера -> Конфигурация Windows -> Параметры безопасности -> Конфигурация расширенной политики аудита -> Доступ к объектам -> Аудит файловой системы" -ForegroundColor White
    }
}

# Проверка настройки аудита для каждой расшаренной папки
function Get-AllSharesAuditSettings {
    $shares = Get-SmbShare

    foreach ($share in $shares) {
        if ($share.Name -eq "IPC$" -or $share.Name -eq "ADMIN$") {
            continue
        }

        Write-Host
        Write-Host "------------------------------------------------------------"
        Write-Host "Шара: " -ForegroundColor Magenta -NoNewline
        Write-Host "$($share.Name)"
        Write-Host "Адрес шары: " -ForegroundColor Magenta -NoNewline
        Write-Host "$($share.Path)"
        Write-Host
    
        try {
            $acl = Get-Acl -Path $share.Path -Audit
            $auditEntries = $acl.GetAuditRules($true, $false, [System.Security.Principal.NTAccount])
        
            if ($auditEntries.Count -gt 0) {
                Write-Host "Аудит настроен!" -ForegroundColor Green
            
                $i = 1
                foreach ($entry in $auditEntries) {
                    Write-Host "`nAccess Control Entry № $i" -ForegroundColor Yellow
                
                    $identity = $entry.IdentityReference.ToString()
                    $identityTranslated = switch -Wildcard ($identity) {
                        "BUILTIN\Administrators" { "Администраторы" }
                        "BUILTIN\Users" { "Пользователи" }
                        "NT AUTHORITY\SYSTEM" { "Система" }
                        "NT AUTHORITY\Authenticated Users" { "Прошедшие проверку" }
                        "NT AUTHORITY\Everyone" { "Все" }
                        "CREATOR OWNER" { "СОЗДАТЕЛЬ-ВЛАДЕЛЕЦ" }
                        default { $identity }
                    }
                
                    $auditType = switch ($entry.AuditFlags) {
                        "Success, Failure" { "Все" }
                        "Failure" { "Отказ" }
                        "Success" { "Успех" }
                        default { $entry.AuditFlags }
                    }
                
                    $rights = $entry.FileSystemRights
                
                    $fullControlMask = [System.Security.AccessControl.FileSystemRights]::DeleteSubdirectoriesAndFiles -bor
                        [System.Security.AccessControl.FileSystemRights]::Modify -bor
                        [System.Security.AccessControl.FileSystemRights]::ChangePermissions -bor
                        [System.Security.AccessControl.FileSystemRights]::TakeOwnership

                    if (($rights -band $fullControlMask) -eq $fullControlMask) { 
                        $rightsDetails = @("Полный доступ")
                    }
                    elseif ($rights -eq [System.Security.AccessControl.FileSystemRights]::Modify) {
                        $rightsDetails = @("Изменение")
                    }
                    elseif ($rights -eq [System.Security.AccessControl.FileSystemRights]::ReadAndExecute) {
                        $rightsDetails = @("Чтение и выполнение")
                    }
                    elseif ($rights -eq [System.Security.AccessControl.FileSystemRights]::Read) {
                        $rightsDetails = @("Чтение")
                    }
                    elseif ($rights -eq [System.Security.AccessControl.FileSystemRights]::Write) {
                        $rightsDetails = @("Запись")
                    } else {
                        $rightsDetails = @()
                        if ($rights -band [System.Security.AccessControl.FileSystemRights]::ExecuteFile) { $rightsDetails += "Траверс папок / выполнение файлов" }
                        if ($rights -band [System.Security.AccessControl.FileSystemRights]::ReadData) { $rightsDetails += "Содержание папки / чтение данных" }
                        if ($rights -band [System.Security.AccessControl.FileSystemRights]::ReadAttributes) { $rightsDetails += "Чтение атрибутов" }
                        if ($rights -band [System.Security.AccessControl.FileSystemRights]::ReadExtendedAttributes) { $rightsDetails += "Чтение дополнительных атрибутов" }
                        if ($rights -band [System.Security.AccessControl.FileSystemRights]::CreateFiles) { $rightsDetails += "Создание файлов / запись данных" }
                        if ($rights -band [System.Security.AccessControl.FileSystemRights]::AppendData) { $rightsDetails += "Создание папок / дозапись данных" }
                        if ($rights -band [System.Security.AccessControl.FileSystemRights]::WriteAttributes) { $rightsDetails += "Запись атрибутов" }
                        if ($rights -band [System.Security.AccessControl.FileSystemRights]::WriteExtendedAttributes) { $rightsDetails += "Запись дополнительных атрибутов" }
                        if ($rights -band [System.Security.AccessControl.FileSystemRights]::DeleteSubdirectoriesAndFiles) { $rightsDetails += "Удаление подпапок и файлов" }
                        if ($rights -band [System.Security.AccessControl.FileSystemRights]::Delete) { $rightsDetails += "Удаление" }
                        if ($rights -band [System.Security.AccessControl.FileSystemRights]::ReadPermissions) { $rightsDetails += "Чтение разрешений" }
                        if ($rights -band [System.Security.AccessControl.FileSystemRights]::ChangePermissions) { $rightsDetails += "Смена разрешений" }
                        if ($rights -band [System.Security.AccessControl.FileSystemRights]::TakeOwnership) { $rightsDetails += "Смена владельца" }
                    }
                
                    if ($rightsDetails.Count -eq 0) {
                        $rightsDetails = @($rights.ToString())
                    }
                
                    $isInheritedTranslated = switch ($entry.IsInherited) {
                        "False" { "Нет" }
                        default { "Унаследовано от: $entry.AuditFlags" }
                    }

                    $inheritanceFlagsTranslated = switch ($entry.InheritanceFlags) {
                        "None" { "Только для этой папки" }
                        "ContainerInherit, ObjectInherit" { 
                            if ($entry.PropagationFlags -eq "InheritOnly" -or $entry.PropagationFlags -eq "NoPropagateInherit, InheritOnly") {
                                "Только для подпапок и файлов"
                            } elseif ($entry.PropagationFlags -eq "None" -or $entry.PropagationFlags -eq "NoPropagateInherit") {
                                "Для этой папки, её подпапок и файлов"
                            } else {
                                $entry.InheritanceFlags
                            }
                        
                        }
                        "ContainerInherit" { 
                            if ($entry.PropagationFlags -eq "InheritOnly" -or $entry.PropagationFlags -eq "NoPropagateInherit, InheritOnly") {
                                "Только для подпапок"
                            } elseif ($entry.PropagationFlags -eq "None" -or $entry.PropagationFlags -eq "NoPropagateInherit") {
                                "Для этой папки и ее подпапок"
                            } else {
                                $entry.InheritanceFlags
                            }
                        
                        }
                        "ObjectInherit" { 
                            if ($entry.PropagationFlags -eq "InheritOnly" -or $entry.PropagationFlags -eq "NoPropagateInherit, InheritOnly") {
                                "Только для файлов"
                            } elseif ($entry.PropagationFlags -eq "None" -or $entry.PropagationFlags -eq "NoPropagateInherit") {
                                "Для этой папки и ее файлов"
                            } else {
                                $entry.InheritanceFlags
                            }
                        
                        }
                        default { $entry.InheritanceFlags }
                    }

                    $propagationFlag = switch ($entry.PropagationFlags) {
                        "NoPropagateInherit, InheritOnly" { "Да" }
                        "NoPropagateInherit" { "Да" }
                        default { "Нет" }
                    }
                
                    Write-Host "Тип: " -ForegroundColor Cyan -NoNewline
                    Write-Host $auditType -ForegroundColor White

                    Write-Host "Субъект: " -ForegroundColor Cyan -NoNewline
                    Write-Host $identityTranslated -ForegroundColor White

                    Write-Host "Доступ:" -ForegroundColor Cyan
                    foreach ($right in $rightsDetails) {
                        Write-Host "- $right" -ForegroundColor White
                    }

                    Write-Host "Унаследовано от: " -ForegroundColor Cyan -NoNewline
                    Write-Host $isInheritedTranslated -ForegroundColor White

                    Write-Host "Применяется к: " -ForegroundColor Cyan -NoNewline
                    Write-Host $inheritanceFlagsTranslated -ForegroundColor White

                    Write-Host "Применять эти параметры аудита к объектам и контейнерам только внутри этого контейнера: " -ForegroundColor Cyan -NoNewline
                    Write-Host $propagationFlag -ForegroundColor White
                
                    $i++
                }
                Write-Host "------------------------------------------------------------"
            } else {
                Write-Host "Аудит НЕ настроен!" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "Ошибка при получении настроек аудита для шары `"$($share.Name)`": $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

function Get-WindowsSharesAudit {
    Get-OSAuditSettings
    Get-AllSharesAuditSettings
}