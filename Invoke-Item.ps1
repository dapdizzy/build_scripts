$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\VsDevCmd.bat"
$pinfo.RedirectStandardInput = $true
$pinfo.RedirectStandardError = $true
$pinfo.RedirectStandardOutput = $true
$pinfo.UseShellExecute = $false
#$pinfo.Arguments = "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\VsDevCmd.bat"
$p = New-Object System.Diagnostics.Process
$p.StartInfo = $pinfo
$p.Start() | Out-Null
#$p.WaitForExit()
$stdin = $p.StandardInput
#$stdout = $p.StandardOutput.ReadToEnd()
#$stderr = $p.StandardError.ReadToEnd()
#Write-Host "stdout: $stdout"
#Write-Host "stderr: $stderr"
#Write-Host "exit code: " + $p.ExitCode

$stdin.WriteLine('gacutil /i "C:\AX\Build\Drop\LIPS\1.0.0.120\Logs\Packages\MMS.Cloud.Commands.LIPS.1.0.29.0\lib\net40\MMS.Cloud.Commands.LIPS.dll"')
$stdin.Flush()

if ($p.WaitForExit(10000) -eq $false)
{
    $p.Kill()
}

break;

#$stdout = $p.StandardOutput.ReadToEnd()
#$stderr = $p.StandardError.ReadToEnd()
#Write-Host "stdout: $stdout"
#Write-Host "stderr: $stderr"

<#

& 'C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\Shortcuts\Developer Command Prompt for VS2013.lnk' -r
Start-Sleep -s 5
$newCmd = Get-Process cmd | Sort-Object StartTime -descending | Select-Object -f 1
$newCmd.RedirectStandardInput = $true
$newCmd.StandardInput.WriteLine('gacutil /i "C:\AX\Build\Drop\LIPS\1.0.0.120\Logs\Packages\MMS.Cloud.Commands.LIPS.1.0.29.0\lib\net40\MMS.Cloud.Commands.LIPS.dll"')
$newCmd.StandardInput.Flush()
$newCmd.Kill();
#'gacutil "C:\AX\Build\Drop\LIPS\1.0.0.120\Logs\Packages\MMS.Cloud.Commands.LIPS.1.0.29.0\lib\net40\MMS.Cloud.Commands.LIPS.dll"'
Write-Host 'yyy'

#>