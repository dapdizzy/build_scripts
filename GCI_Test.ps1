$currentLogFolder = 'C:\AX\Build\Drop\LIPS\1.0.0.104\Logs'
$sysTabXpoFileName = gci -Path "$currentLogFolder\*" -Include "*_sysTab.xpo" -Name | select -f 1
Write-Host $sysTabXpoFileName
Read-Host 'Are U surprised?'