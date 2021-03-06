#Load the AX PS libary
$SetupRegistryPath = "HKLM:\SOFTWARE\Microsoft\Dynamics\6.0\Setup"
$x = . (join-path "C:\Program Files\Microsoft Dynamics AX\60\ManagementUtilities" "Microsoft.Dynamics.ManagementUtilities.ps1")
$dstFolder = "C:\Ax\Build\Drop\WAXR3\1.0.0.432\Application\Appl"
# $configFileName = 'C:\Users\pyatkov\Documents\AxShortcuts\AxServ\AXTest.axc'
Import-AXModelStore -File "$dstFolder\Build-1.0.0.432.axmodelstore" -Server "MOW04WAXBLD01" -Database "MicrosoftDynamicsAX_model" -IdConflict "Overwrite" -NoPrompt -Details -OutVariable out -Verbose
Read-Host "Done"