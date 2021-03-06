# Run AXBuild.exe utility
$aosNumber = '01'
$script:AOSname = "AOS60`${0}" -f $aosNumber
$script:AxAOSServerName = $env:COMPUTERNAME
$script:currentLogFolder = $MyInvokation.MyCommand.Path
$buildTimeout = 120
$cilTimeout = 120
$serverBinDir = 'C:\Program Files\Microsoft Dynamics AX\60\Server\MAX_DEV\bin'
$axBuild = Join-Path $serverBinDir AXBuild.exe
$arguments = ' xppcompileall /s={0}' -f $aosNumber
$axBuildProcess = Start-Process $script:axBuild -WorkingDirectory $script:serverBinDir -PassThru -ArgumentList $arguments -Verbose
if ($axBuildProcess.WaitForExit(60000*$buildTimeout) -eq $false)
{
    $axBuildProcess.Kill()
    Throw ("Error: AX compile did not complete within {0} minutes" -f $buildTimeout)
}
$script:clientBinDir = [System.Environment]::ExpandEnvironmentVariables("$clientBinDir")    
$script:ax32  = join-path $clientBinDir "ax32.exe"