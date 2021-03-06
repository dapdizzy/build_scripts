$axLayer = 'VAR'
$aolParm = '-aolCode=gR8aYLQYS3Yzj94qIoOUOA=='
$modelName = 'VAR Model'
#$currentLogFolder = 'C:\AX\Build\Drop\DAXSTDR3\1.0.0.11\Logs'
$xpoName = 'C:\AX\Build\Drop\DAXSTDR3\1.0.0.18\Logs\Combined.VAR Model.xpo'
$ax32 = 'C:\Program Files (x86)\Microsoft Dynamics AX\60\Client\Bin\Ax32.exe'
$clientBinDir = 'C:\Program Files (x86)\Microsoft Dynamics AX\60\Client\Bin'
$importTimeout = 10

$arguments = '-aol={0} {1} "-aotimportfile={2}" -lazyclassloading -lazytableloading -nocompileonimport -internal=noModalBoxes "-model=@{3}"' -f $axLayer,$aolParm,$xpoName,$modelName
Write-Host($arguments)
$axProcess = Start-Process $ax32 -WorkingDirectory $clientBinDir -PassThru -WindowStyle minimized -ArgumentList $arguments -Verbose
if ($axProcess.WaitForExit(60000*$ImportTimeout) -eq $false)
{
    $axProcess.Kill()
    Throw ("Error: AX .XPO import did not complete within {0} minutes" -f $ImportTimeout)
}

Read-Host ("Done Import combined xpo for model {0}: {1}" -f $modelName,(Get-Date))