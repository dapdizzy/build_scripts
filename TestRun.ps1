$c = . (join-path (Split-Path -Parent $MyInvocation.MyCommand.Path) "common.ps1")
$b = . (join-path (Split-Path -Parent $MyInvocation.MyCommand.Path) "BuildAX.ps1")

$ApplicationDir = "C:\Program Files\Microsoft Dynamics AX\60\Server\MicrosoftDynamicsAX\bin\Application\WAX-New"

$models = @()
$modelHash = @{}
$i = 0
foreach($ModelToBuild in ((Get-ModelsToBuild).GetEnumerator())) # | Where-Object {$_.Folder -ne $null -and $_.Folder -ne ''})
{
    $i++
    Write-InfoLog ('{0}: {1}' -f $i, $ModelToBuild.Folder)
}

Write-InfoLog 'End   <======================================   '