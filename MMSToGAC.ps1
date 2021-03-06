$root = 'C:\MMS'
$util = 'C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\Shortcuts\Developer Command Prompt for VS2013'
$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.Filename = $util
$pinfo.UseShellExecute = $false
$pinfo.RedirectStandardInput = $true
$pinfo.Arguments = $arguments

$p = New-Object System.Diagnostics.Process
$p.StartInfo = $pinfo
$p.Start()

Start-Sleep -s 2 # wait 2 seconds to let the process start up and be running
foreach ($fileName in Get-ChildItem $root -Filter '*.dll' -Recurse ) 
{
    $command = ('gacutil /i {0}' -f $fileName)
    $p.StandardInput.WriteLine($command)
    Write-Host ('{0} registered in GAC' -f $fileName)
}

$p.Close()

Write-Host 'Import to GAC successfuly completed'
Read-Host 'Press <Enter> to exit'