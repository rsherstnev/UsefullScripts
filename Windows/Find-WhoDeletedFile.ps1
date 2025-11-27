function Find-WhoDeletedFile {
    param(
        [datetime]$StartTime = [datetime]::Today,
        [string]$FileName,
        [bool]$GUI = $false
    )

    $eventsHashTable = @{}
    
    Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4663, 4659; StartTime=$StartTime} | ForEach-Object {
        $xml = [xml]$_.ToXml()

        $user = $xml.Event.EventData.Data | Where-Object { $_.Name -eq 'SubjectUserName' } | Select-Object -ExpandProperty '#text'
        $file = $xml.Event.EventData.Data | Where-Object { $_.Name -eq 'ObjectName' } | Select-Object -ExpandProperty '#text'
        $accessMask = $xml.Event.EventData.Data | Where-Object { $_.Name -eq 'AccessMask' } | Select-Object -ExpandProperty '#text'
        $accessMaskInt = [convert]::ToInt32($accessMask, 16)
        
        if (($accessMaskInt -band 0x10000) -or ($accessMaskInt -band 0x2)) {
            if ($file -match $FileName) {
                $russianTime = $_.TimeCreated.ToString("dd.MM.yyyy HH:mm:ss")
                
                $eventKey = "$russianTime|$user|$file"
                
                if (-not $eventsHashTable.ContainsKey($eventKey)) {
                    $eventsHashTable[$eventKey] = [PSCustomObject]@{
                        Time = $russianTime
                        User = $user
                        File = $file
                    }
                }
            }
        } 
    }
    
    if ($GUI) {
        $eventsHashTable.Values | Sort-Object Time -Descending | Out-GridView -Title "События удаления файлов"
    }
    else {
        $eventsHashTable.Values | Sort-Object Time -Descending | ForEach-Object {
            Write-Host "$($_.Time)`t`t$($_.User)`t`t$($_.File)"
        }
    }
}