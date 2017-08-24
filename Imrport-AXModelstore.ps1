#Load the AX PS libary
$SetupRegistryPath = "HKLM:\SOFTWARE\Microsoft\Dynamics\6.0\Setup"
$x = . (join-path "C:\AX\R2\ManagementUtilities" "Microsoft.Dynamics.ManagementUtilities.ps1")
$dstFolder = 'C:\AX\Backup\Modelstore\WAX'
# $configFileName = 'C:\Users\pyatkov\Documents\AxShortcuts\AxServ\AXTest.axc'
Import-AXModelStore -File "$dstFolder\WMSDEV.axmodelstore" -Server "MOW04DEV014" -Database "WAXTest_model" -IdConflict "Overwrite" -NoPrompt -Details -OutVariable out -Verbose
Read-Host "Done"