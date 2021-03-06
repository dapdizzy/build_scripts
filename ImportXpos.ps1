#Load common automation library
#$c = . (join-path (Split-Path -Parent $MyInvocation.MyCommand.Path) "common.ps1")
$directory = 'C:\AX\Build\Drop\DAXSTDR3\1.0.0.18\Logs'
$axLayer = 'VAR'
$aolParm = '-aolCode=gR8aYLQYS3Yzj94qIoOUOA=='
$modelName = 'VAR Model'
$ax32 = 'C:\Program Files (x86)\Microsoft Dynamics AX\60\Client\Bin\Ax32.exe'
$clientBinDir = 'C:\Program Files (x86)\Microsoft Dynamics AX\60\Client\Bin'
$importTimeout = 10

function Import-XPO([string]$xpoFileName)
{
    $arguments = '-aol={0} {1} "-aotimportfile={2}" -lazyclassloading -lazytableloading -nocompileonimport -internal=noModalBoxes "-model=@{3}"' -f $axLayer,$aolParm,$xpoFileName,$modelName
    Write-Host($arguments)
    $axProcess = Start-Process $ax32 -WorkingDirectory $clientBinDir -PassThru -WindowStyle minimized -ArgumentList $arguments -Verbose
    if ($axProcess.WaitForExit(60000*$ImportTimeout) -eq $false)
    {
        $axProcess.Kill()
        Throw ("Error: AX XPO import did not complete within {0} minutes" -f $ImportTimeout)
    }
}

foreach ($fileName in Get-ChildItem $directory -Filter '*.xpo' )
{
    Import-XPO($fileName.FullName)
}