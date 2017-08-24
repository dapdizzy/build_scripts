$c = . (join-path (Split-Path -Parent $MyInvocation.MyCommand.Path) "common.ps1")

Restore-Database "MicrosoftDynamicsAX" "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup\MicrosoftDynamicsAX.bak"

<#[System.Environment]::SetEnvironmentVariable('GacUtilPath', 'C:\Program Files (x86)\Microsoft SDKs\Windows\v8.1A\bin\NETFX 4.5.1 Tools\x64\gacutil.exe')

$folder = "C:\AX\Build\Drop\Fax\1.0.0.350\Logs\Packages"

Install-PackagesToGAC $folder

Write-Host "We're done" -ForegroundColor Cyan#>

Write-Host "We're done" -ForegroundColor Cyan