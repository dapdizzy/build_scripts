$c = . (join-path (Split-Path -Parent $MyInvocation.MyCommand.Path) "common.ps1")

$folder = 'C:\Program Files\Microsoft Dynamics AX\60\Server\LIPSAX\bin\Application\LIPS\VAR Model\Classes'
$xpoMask = 'Ax'

# TODO: implement import of all xpos by a mask

foreach ($xpoName in (gci -Path "$folder\*" -Include "$xpoMask*.xpo" -Name))
{
    Write-Host $xpoName
    #Import-XPO $xpoName
}

#Import-XPO $xpoName