#Load the AX PS libary
$SetupRegistryPath = "HKLM:\SOFTWARE\Microsoft\Dynamics\6.0\Setup"
$x = . (join-path (join-path (Get-Item $SetupRegistryPath).GetValue("InstallDir") "ManagementUtilities") "Microsoft.Dynamics.ManagementUtilities.ps1")
$dstFolder = "C:\Ax\Build\Backup\Modelstore"
Export-AXModelStore -File "$dstFolder\WAXR3_baseline1.axmodelstore" -Database "MicrosoftDynamicsAX_model" -Details
Read-Host "We're done. What about you?"