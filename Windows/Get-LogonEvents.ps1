function Get-LogonEvents {
    param(
        [datetime]$StartTime = [datetime]::Today,
        
        [ValidateSet("System", "Interactive", "RemoteInteractive", "Network", "Batch", "Service", "Unlock", "NetworkCleartext", "NewCredentials", "CachedInteractive", "CachedRemoteInteractive", "CachedUnlock")]
        [string[]]$IncludeLogonType = @(),
        
        [ValidateSet("System", "Interactive", "RemoteInteractive", "Network", "Batch", "Service", "Unlock", "NetworkCleartext", "NewCredentials", "CachedInteractive", "CachedRemoteInteractive", "CachedUnlock")]
        [string[]]$ExcludeLogonType = @(),
        
        [bool]$GUI = $false
    )

    $logonTypeNames = @{
        0  = "System"
        2  = "Interactive"
        3  = "Network"
        4  = "Batch"
        5  = "Service"
        7  = "Unlock"
        8  = "NetworkCleartext"
        9  = "NewCredentials"
        10 = "RemoteInteractive"
        11 = "CachedInteractive"
        12 = "CachedRemoteInteractive"
        13 = "CachedUnlock"
    }

    $authEvents = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4624; StartTime=$StartTime} -ErrorAction Stop
    
    $results = @()

    foreach ($authEvent in $authEvents) {
        $eventXml = [xml]$authEvent.ToXml()

        $logonTypeNumber = [int](($eventXml.Event.EventData.Data | Where-Object {$_.Name -eq "LogonType"}).'#text')
        if ($logonTypeNames.ContainsKey($logonTypeNumber)) {
            $logonTypeName = $logonTypeNames[$logonTypeNumber]
        } else {
            $logonTypeName = "Unknown ($logonTypeNumber)"
        }

        $shouldInclude = $true
        
        if ($ExcludeLogonType.Count -gt 0 -and $ExcludeLogonType -contains $logonTypeName) {
            $shouldInclude = $false
        }
        elseif ($IncludeLogonType.Count -gt 0 -and $IncludeLogonType -notcontains $logonTypeName) {
            $shouldInclude = $false
        }

        if ($shouldInclude) {
            $targetUser = ($eventXml.Event.EventData.Data | Where-Object {$_.Name -eq "TargetUserName"}).'#text'
            $domain = ($eventXml.Event.EventData.Data | Where-Object {$_.Name -eq "TargetDomainName"}).'#text'
            $sourceIp = ($eventXml.Event.EventData.Data | Where-Object {$_.Name -eq "IpAddress"}).'#text'
            $sourceHost = ($eventXml.Event.EventData.Data | Where-Object {$_.Name -eq "WorkstationName"}).'#text'
            $process = ($eventXml.Event.EventData.Data | Where-Object {$_.Name -eq "ProcessName"}).'#text'

            $results += [PSCustomObject]@{
                TimeCreated = $authEvent.TimeCreated
                User = if ($domain -and $targetUser) { "$domain\$targetUser" } else { $targetUser }
                LogonType = $logonTypeName
                SourceIP = if ($sourceIp -and $sourceIp -ne "-") { $sourceIp } else { "N/A" }
                SourceHost = if ($sourceHost -and $sourceHost -ne "-") { $sourceHost } else { "Local" }
                Process = $process
            }
        }
    }

    if ($GUI) {
        $title = "События аутентификации"
        $results | Sort-Object TimeCreated -Descending | Out-GridView -Title $title
    } else {
        $results | Sort-Object TimeCreated -Descending | Format-Table -AutoSize
    }
}