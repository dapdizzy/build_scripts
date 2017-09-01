$c = . (join-path (Split-Path -Parent $MyInvocation.MyCommand.Path) "common.ps1")

$ApplicationSourceDir = "C:\Program Files\Microsoft Dynamics AX\60\Server\MicrosoftDynamicsAX\bin\Application"
$tfsUrl = 'https://mediamarkt.visualstudio.com/defaultcollection'
# $tfsWorkspace = '$/WAXR3/WAXR3'

# $tfsLabelPrefix = 'WAX-{0}'
# $currentVersion = '9.9.9.9'

Get-DefaultParameters

Sync-TFSWorkspace $tfsUrl $ApplicationSourceDir

# Sync-Files