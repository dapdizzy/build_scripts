#Load common automation library
$c = . (join-path (Split-Path -Parent $MyInvocation.MyCommand.Path) "common.ps1")
Get-OverrideParameters
Read-AXClientConfiguration
Read-AxServerConfiguration

$arguments = ' xppcompileall /s={0}' -f  $script:aosNumber

Write-Host "SQL Server: $sqlServer, SQL Database: $sqlDatabase, Model Database: $sqlModelDatabase" -ForegroundColor Cyan
Write-Host "The process will be called with the following arguments:`n$axBuild`n$arguments" -ForegroundColor Cyan
Read-Host "Do You agree to proceed?" | Out-Null

Write-Host ''
Write-Host 'Lets go then!' -ForegroundColor Cyan
Write-Host ''

# Run AXBuild.exe utility
$axBuildProcess = Start-Process $script:axBuild -WorkingDirectory $script:serverBinDir -PassThru -ArgumentList $arguments -Verbose
Write-InfoLog $out
Write-InfoLog ("                                                                 ") 
Write-InfoLog ("                                                                 ") 

#do {start-sleep -Milliseconds 5000}
#until ($axBuildProcess.HasExited)

if ($axBuildProcess.WaitForExit(60000*$CompileAllTimeout) -eq $false)
{
    $axBuildProcess.Kill()
    Throw ("Error: AX compile did not complete within {0} minutes" -f $CompileAllTimeout)
}

Write-InfoLog ("End of CompileAll API: {0}" -f (Get-Date))

#Copy-Item -Path (Join-Path $script:serverLogDir AxCompileAll.html) -Destination (join-path $currentLogFolder AxCompileAll_Pass1.html) -Force -ErrorAction SilentlyContinue 