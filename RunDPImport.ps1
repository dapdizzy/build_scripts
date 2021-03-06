$dp = 'C:\Program Files (x86)\Microsoft Dynamics AX 2012 Test Data Transfer Tool (Beta)\DP.exe'
$dataFolder = "C:\AX\Data\WAX"
$dbname = "MicrosoftDynamicsAX"
$dbservername = $env:COMPUTERNAME
$arguments = 'IMPORT "{0}" {1} {2}' -f $dataFolder, $dbname, $dbservername
$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.Filename = $dp
$pinfo.UseShellExecute = $false
$pinfo.RedirectStandardInput = $true
$pinfo.Arguments = $arguments

$p = New-Object System.Diagnostics.Process
$p.StartInfo = $pinfo
$p.Start();

Start-Sleep -s 2 # wait 2 seconds to let the process start up and be running

$p.StandardInput.WriteLine('Y')
$timeoutInMinutes = 60
if ($p.WaitForExit(60000*$timeoutInMinutes) -eq $false)
{
    $p.Kill()
    Throw "DP Import did not complete in {0} minutes" -f $timeoutInMinutes
}

Write-Host 'DP Import successfully completed'
Read-Host 'Press <Enter> to exit'
