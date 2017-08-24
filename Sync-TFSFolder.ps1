$c = . (join-path (Split-Path -Parent $MyInvocation.MyCommand.Path) "common.ps1")

$ApplicationSourceDir = "C:\TFS\WAX"
$tfsUrl = 'https://mediamarkt.visualstudio.com/defaultcollection'
$tfsWorkspace = '$/WAX/WAX'

$tfsLabelPrefix = 'WAX-{0}'
$currentVersion = '9.9.9.9'

Get-DefaultParameters

Sync-TFSWorkspace $tfsUrl $ApplicationSourceDir

# Sync-Files