#Load common automation library
$c = . (join-path (Split-Path -Parent $MyInvocation.MyCommand.Path) "common.ps1")
$clientLogDir = 'C:\Users\pyatkov\Microsoft\Dynamics Ax\Log'
Check-CompilerErrors