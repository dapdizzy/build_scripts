# Copyright (c) Microsoft 
# All rights reserved.
# Microsoft Limited Public License:
# This license governs use of the accompanying software. If you use the software, you 
# accept this license. If you do not accept the license, do not use the software.
# 1. Definitions 
# The terms "reproduce," "reproduction," "derivative works," and "distribution" have the 
# same meaning here as under U.S. copyright law. 
# A "contribution" is the original software, or any additions or changes to the software. 
# A "contributor" is any person that distributes its contribution under this license. 
# "Licensed patents" are a contributor's patent claims that read directly on its contribution.
# 2. Grant of Rights 
# (A) Copyright Grant- Subject to the terms of this license, including the license conditions and limitations in section 3, each contributor grants you a non-exclusive, worldwide, royalty-free copyright license to reproduce its contribution, prepare derivative works of its contribution, and distribute its contribution or any derivative works that you create. 
# (B) Patent Grant- Subject to the terms of this license, including the license conditions and limitations in section 3, each contributor grants you a non-exclusive, worldwide, royalty-free license under its licensed patents to make, have made, use, sell, offer for sale, import, and/or otherwise dispose of its contribution in the software or derivative works of the contribution in the software.
# 3. Conditions and Limitations 
# (A) No Trademark License- This license does not grant you rights to use any contributors' name, logo, or trademarks. 
# (B) If you bring a patent claim against any contributor over patents that you claim are infringed by the software, your patent license from such contributor to the software ends automatically. 
# (C) If you distribute any portion of the software, you must retain all copyright, patent, trademark, and attribution notices that are present in the software. 
# (D) If you distribute any portion of the software in source code form, you may do so only under this license by including a complete copy of this license with your distribution. If you distribute any portion of the software in compiled or object code form, you may only do so under a license that complies with this license. 
# (E) The software is licensed "as-is." You bear the risk of using it. The contributors give no express warranties, guarantees or conditions. You may have additional consumer rights under your local laws which this license cannot change. To the extent permitted under your local laws, the contributors exclude the implied warranties of merchantability, fitness for a particular purpose and non-infringement.
# (F) Platform Limitation - The licenses granted in sections 2(A) and 2(B) extend only to the software or derivative works that you create that run on a Microsoft Windows operating system product.

#File version: 1.0.2.0

function Get-BuildVersion
{
    if($version -ne $null)
    {
        $script:CurrentVersion = $version
    }
    else
    {
        $script:CurrentVersion = "1.0.0.0"
        if ($versionFile -ne $false -and (Test-Path $versionFile) -ne $false)
        {
            $fileContent = Get-Content $versionFile
            foreach ($line in $fileContent)
            {
                $script:CurrentVersion = $line
            }       
        }
    }
    
    Set-NextBuildVersion    
}

function Set-NextVersion
{
    foreach($ModelToBuild in ((Get-ModelsToBuild).GetEnumerator()) | Where-Object {$_.Folder -ne $null -and $_.Folder -ne ''})
    {
        Write-InfoLog('ModelToBuild.Folder: {0}' -f $ModelToBuild.Folder)
        $filePath = (Join-Path (Join-Path $ApplicationDir $ModelToBuild.Folder) 'Model.xml' )
        #$filePath = (Join-Path $ModelToBuild.Folder 'Model.xml')
        Write-InfoLog('Model file path: {0}' -f $filePath)
        #checkout
        if($w -ne $null)
        {
            $w.PendEdit($filePath)
        }
        
        [xml]$x = Get-Content $filePath
        $x.ModelManifest.Version = Get-NextVersion($x.ModelManifest.Version)
        $x.save($filePath)
    }
 
    if($w -ne $null)
    {
        $pendingChanges = $w.GetPendingChanges();
        if ($pendingChanges.count -gt 0)
        {
            $changesetNumber = $w.CheckIn($pendingChanges, 'Version Updated');
        }
    }
}

function Get-NextVersion($oldVersion)
{
    if($oldVersion -ne $null -and $oldVersion.Trim() -ne '')
    {
        $m = $oldVersion.split('.')
        $m.SetValue([string]([int]($m.GetValue($m.count - 1)) + 1), $m.count - 1)
        $version = ""
        for ($idx = 0; $idx -lt $m.Count; $idx++) {$version+='{0}.' -f $m.Get($idx)}   
        $version = $version.Substring(0,$version.Length-1)
    }
    else
    {
        $version = $currentVersion
    }
    
    $version
}

function Set-NextBuildVersion
{
    $m = $currentVersion.split('.')
    $m.SetValue([string]([int]($m.GetValue($m.count - 1)) + 1), $m.count - 1)
    $private:version = ""
    for ($idx = 0; $idx -lt $m.Count; $idx++) {$version+='{0}.' -f $m.Get($idx)}   
    $version = $version.Substring(0,$version.Length-1)
    $version | Out-File $versionFile -Encoding Default
}

#Read the environmentvariables comming from the BuildTemplate and put them in a parameter file to be used if the script is run manual.
function Get-InputVariables ($homePath)
{
    $script:AxBuildDir = $homePath
    $axbuildError = @()

    $RunBuildParmFile = (Join-Path $AxBuildDir "BuildParameters.txt")
    if ((Test-Path $RunBuildParmFile) -ne $false)
    {
        $fileContent = Get-Content $RunBuildParmFile
        Write-InfoLog "Input parameters"        
	    foreach ($line in $fileContent)
        {
            Write-InfoLog $line
            $line = $line.split("=")
            if($line.Count -eq 2)
            {
                [System.Environment]::SetEnvironmentVariable($line[0],$line[1])     
            }
            else
            {
                Write-InfoLog "Bad BuildParameters file content: {0}" -f $line
            }
        }       
    }   
    
    $script:LocalProject            = GetEnvironmentVariable("VCSFilePath")
    $script:ApplicationSourceDir    = GetEnvironmentVariable("ApplicationSourceDir")
    $script:Version                 = GetEnvironmentVariable("Version")
    $script:dropLocation            = GetEnvironmentVariable("DropLocation")
    $script:AxCompileAll            = GetEnvironmentVariable("CompileAll")
    $script:CleanupAfterBuild       = GetEnvironmentVariable("CleanupAfterBuild")
    $script:CompileCIL              = GetEnvironmentVariable("CompileCIL")
    $script:TFSIntegration          = GetEnvironmentVariable("TFSIntegration")
    $script:TFSUrl                  = GetEnvironmentVariable("TFSUrl")
    $script:TFSLabelPrefix          = GetEnvironmentVariable("TFSLabelPrefix")
    $script:TFSWorkspace            = GetEnvironmentVariable("TFSWorkspace")
    $script:LabelComments           = GetEnvironmentVariable("LabelComments")
    $script:LogFolder               = GetEnvironmentVariable("LogFolder")
    $script:SignKey                 = GetEnvironmentVariable("SignKey")
    $script:MsBuildPath             = GetEnvironmentVariable("MsBuildDir")
    $script:rdlLanguage             = GetEnvironmentVariable("RdlLanguage")
    $script:NoCleanOnError          = GetEnvironmentVariable("NoCleanOnError")
    $script:backupModelStoreFolder  = GetEnvironmentVariable("BackupModelStoreFolder")
    $script:CleanBackupFileName     = GetEnvironmentVariable("CleanBackupFileName")
    
    if ($ApplicationSourceDir -ne $null) {$script:dependencyPath= Join-Path $ApplicationSourceDir "Dependencies"}
    
    if ((Test-Path $RunBuildParmFile) -eq $false)
    {
        $private:buffer = @()
        $buffer += "Version="+$Version
        $buffer += "VCSFilePath="+$LocalProject
        $buffer += "ApplicationSourceDir=" + $ApplicationSourceDir
        $buffer += "DropLocation=" + $dropLocation
        $buffer += "CompileAll=" + $AxCompileAll
        $buffer += "CleanupAfterBuild=" + $CleanupAfterBuild
        $buffer += "CompileCIL="+ $CompileCIL
        $buffer += "TFSIntegration="+ $TFSIntegration
        $buffer += "TFSUrl="+ $TFSUrl
        $buffer += "TFSLabelPrefix="+ $TFSLabelPrefix
        $buffer += "TFSWorkspace="+ $TFSWorkspace
        $buffer += "LabelComments="+ $LabelComments
        $buffer += "SignKey="+ $SignKey
        $buffer += "MsBuildDir="+ $msBuildPath
        $buffer += "RdlLanguage="+ $rdlLanguage
        $buffer += "NoCleanOnError="+ $NoCleanOnError               
        
        $buffer | Out-File $RunBuildParmFile -Encoding Default
    }
    
    Update-InputVariables       
}

function Update-InputVariables
{
    if($localProject -ne $null -and $ApplicationSourceDir -ne $null) {
        $ApplicationSourceDir = $ApplicationSourceDir.TrimEnd('\')
        $script:ApplicationDir = $localProject.Replace($ApplicationSourceDir,'')   
        $script:ApplicationDir = $ApplicationDir.ToUpper().Replace('\DEFINITION\VCSDEF.XML','')
        $script:ApplicationDir = join-path $ApplicationSourceDir $applicationdir
    }    
    
   $script:versionFile = join-path $AxBuildDir 'version.txt'
   
   if($rdlLanguage -eq $null)
   {
       $script:rdlLanguage = 'EN-US'
   }
}

function Validate-InputVariables
{
    $axbuildError = @()

    if ($ApplicationSourceDir -eq $null)    {$axBuildError += "The environment variable %ApplicationSourceDir% is missing."+[char]10}
    
    if ($ApplicationSourceDir -ne $null -and (Test-Path $ApplicationSourceDir) -eq $false)    {$axBuildError += "The environment variable %ApplicationSourceDir% : {0} is not a valid path." -f $ApplicationSourceDir+[char]10}
    
    if ($localProject -eq $null)    {$axBuildError += "The environment variable %localproject% is missing."+[char]10}
        
    if ($clientBinDir -ne $null) {
        if ((Test-Path -Path $clientBinDir) -eq $false) {$axBuildError += "The client bin dir is missing."+[char]10}}
    if ($AOSName -eq $null) {{$axBuildError += ("The AX AOS {0} can not be found." -f $axAOS)+[char]10}}
    
    if ($DropLocation -eq $null -or (Test-Path $DropLocation) -ne $true)
    {
        $axBuildError += "Drop location in not specified or invalid."+[char]10}
    
    if ($MsBuildPath -eq $null -or (Test-Path $MsBuildPath) -ne $true)
    {
        $axBuildError += "MsBuild.exe path is invalid."+[char]10}
    
    if ((test-path(Join-Path $AxBuildDir 'combinexpos.exe')) -ne $true)
    {
        $axBuildError += ("Combinexpos.exe is missing from {0}." -f $axBuildDir)+[char]10
    }
    if ($axBuildError -ne $null) 
    {
        $axbuildError | Out-File (join-path "$currentLogFolder" "AxInputValidationErrors.txt") -Encoding Default
        Write-ErrorLog "Parameter validation error. See AxInputValidationErrors.txt for more information." 
        Write-InfoLog $axbuildError
        $axbuildError
    }
}   

function Create-BuildCompleted
{
    $axbuildError = @() 
    
    $axbuildError | Out-File (join-path "$dropLocation" "BuildCompleted.txt") -Encoding Default 
}

function Scan-InputErrors
{
    $retVal = $false
    $axbuildError = @() 
    if((Test-Path (join-path $AxBuildDir "AxInputErrors.txt")) -eq $True)
    {
        Copy-Item -Path (join-path $AxBuildDir "AxInputErrors.txt") -Destination $currentLogFolder -Force
        $axBuildError += "Parameters file is wrong. See AXInputErrors.txt"+[char]10
        $retVal = $true
    }
    
    if((Test-Path (join-path $AxBuildDir "AxInputValidationErrors.txt")) -eq $True)
    {
        Copy-Item -Path (join-path $AxBuildDir "AxInputValidationErrors.txt") -Destination $currentLogFolder -Force 
        $axBuildError += "Some parameters passed are wrong. See AxInputValidationErrors.txt"+[char]10
        $retVal = $true
    }
    
    if($retVal -eq $true)
    {
        $axbuildError | Out-File (join-path $dropLocation "BuildErrors.err") -Encoding Default 
    }
    
    $retVal
}

function Build-AX
{
    #Step 1:Sync files
    Disable-VCS
    if($TFSIntegration -eq "True") 
    {
        try
        {            
            Sync-Files
            Set-NextVersion
            Apply-Label
        }
        finally
        {
            if($w -ne $null)
            {
                Write-InfoLog ("Deleting workspace.") 
                $d= $w.Delete()
            }
        }
    }
    else
    {
        Set-NextVersion
    }
          
    if ( $ApplicationDir -eq $null -or (Test-Path $ApplicationDir) -eq $false)
    { Write-TerminatingErrorLog ("Wrong local project setting: {0}" -f $localProject)}

    #Step 
    $script:modelLayerMap = @{}
    Create-ModelMap
    
    #Step 
    Write-InfoLog ("                                                                 ") 
    Write-InfoLog ("*****************************************************************") 
    Write-InfoLog ("****************COMBINE AND EXPORT XPOs**************************")

    Write-Infolog "Collecting models to Build $(Get-Date)"
    $modelsToBuild = Get-ModelsToBuild
    Write-Infolog "Models to build: $($modelsToBuild.ToString())"

    $models = @()
    $modelHash = @{}
    foreach($ModelToBuild in ($modelsToBuild.GetEnumerator()) | Where-Object {$_.Folder -ne $null -and $_.Folder -ne ''})
    {
        $Model = Get-Item -Path (Join-Path (Join-Path $ApplicationDir $ModelToBuild.Folder) 'Model.xml' )
        Get-Model $model
        if ($aolCode -eq '' -and $AxLayer -ne '' -and $AxLayer.SubString(0,2).ToUpper() -ne 'US')
        {
            Write-TerminatingErrorLog ("License code is not available for model: {0}" -f $model.FullName)
        }
        
        $modelHash.Add($modelName, $AxLayer)
        Combine-Xpos $model.Directory
        Create-AOTObjectsTxt $model | Out-Null
        $ret = Check-CombineXpoError
        if ($ret -eq $true)
        {
            
            $models += $model
            Add-LayerOrder $model $axLayer
        }
        else
        {
            Write-TerminatingErrorLog ("Unable to combine xpo for: {0}" -f $model.FullName)
        }
    }

    if ($models -eq $null)
    {
        Write-Infolog "Models are equal to NULL"
    }
    else
    {
        Write-Infolog "Models contain $($models.Length) items"
    }
    
    # Now we've got all the references downloaded to local repo and it's time to install the needed MyGet packages and register them to GAC for AX to build.
    Create-PackagesConfig
    Install-Packages
    
    Write-InfoLog '------------------------------------------>' 
    Write-InfoLog ("Models list: $models")
    Write-InfoLog '<------------------------------------------'

    Clean-Build
    
    # Avoid calling Setup-AXModelStore -NoInstallMode too often
    
    #Step 2
    #Set the No install mode after the Clean-Build as we need to override the settings restored by importing the model store file.
    #Write-InfoLog ("Calling Set-AXModelStore: {0}" -f (Get-Date)) 
    #Set-AXModelStore -NoInstallMode -Database $sqlModelDatabase -Server $sqlServer -OutVariable out -Verbose
    #Write-InfoLog $out
    
    $modelLayerMap = $modelLayerMap.GetEnumerator() | Sort-Object Name
    if($modelLayerMap -eq $null)
    {
        $modelLayerMap = @{}
    }
    if($modelLayerMap.GetType().Name -eq 'DictionaryEntry')
    {
        $modelLayerMap = @{ $modelLayerMap.Name = $modelLayerMap.Value}
    }

    Create-ModelList   
    Install-DependentBinaries
    Import-BuildModels
    
    # Check imported AOT objects in the system against list of source controlled files in the local TFS Workspace
    #$secodWaveOfImportPassed = $false
    <#$verificationResult = $true
    $importRetryCount = 0
    DO
    {
        #Now we can verify all objects have been imported
        $verificationResult = Verify-AOTObjectsImported
        if ($verificationResult -eq $true)
        {
            Write-Host 'Now, everything is imported' -ForegroundColor Cyan
        }
        elseif ($importRetryCount -eq 0)
        #($secodWaveOfImportPassed -ne $true)
        {
            Write-Host 'Some objects were not imported after combined XPO import' -ForegroundColor Yellow
            Write-Host 'Attempting to import missed objects...' -ForegroundColor Yellow
            Import-MissedObjects
            $importRetryCount++
            #$secodWaveOfImportPassed = $true
        }
        # We actually quit the loop here in case of a negative scenario
        else
        {
            Write-Host 'Still some objects are missing after attempting to reimport' -ForegroundColor Yellow
            break
        }
    } While ($verificationResult -eq $false)#>

    Verify-AOTObjects

    Write-InfoLog ("*****************************************************************") 
    Write-InfoLog ("*****************************************************************")
    Write-InfoLog ("                                                                 ")
           
    #Step 9
    Write-InfoLog ("                                                                 ") 
    Write-InfoLog ("*****************************************************************") 
    Write-InfoLog ("****************COMPILE AX***************************************") 
    Compile-Ax
    Write-InfoLog ("*****************************************************************") 
    Write-InfoLog ("*****************************************************************")
    Write-InfoLog ("                                                                 ")

    # Recreate AOT Objects once again to be sure enough
    Create-AOTObjectsTxt $model | Out-Null
    # Verify AOT Objects once again after AX is fully compiled
    Verify-AOTObjects

    #Step 10
    Write-InfoLog ("                                                                 ") 
    Write-InfoLog ("*****************************************************************") 
    Write-InfoLog ("****************COLLECTING BUILD*********************************") 
    Collect-Build $models
    Write-InfoLog ("*****************************************************************") 
    Write-InfoLog ("*****************************************************************")
    Write-InfoLog ("                                                                 ")
    
	<#if ($NoCleanOnError -ne $true -or (Test-Path (join-path $currentLogFolder 'BuildErrors.err')) -ne $true)
    {
        #Clean build step 11
        if ($CleanupAfterBuild -eq "True")      
        {
            Write-InfoLog ("                                                                 ") 
            Write-InfoLog ("*****************************************************************") 
            Write-InfoLog ("****************CLEANING BUILD***********************************") 
            Clean-Build
            Write-InfoLog ("*****************************************************************") 
            Write-InfoLog ("*****************************************************************") 
            Write-InfoLog ("                                                                 ") 
        }
    }#>
}

$ErrorActionPreference = "SilentlyContinue"

# Capture Initial script path in a script scoped variable as powershell is not smart enough to provide $Myinvocation variable in a function in a references script (i.e., Common.ps1)
$script:startupDir = $MyInvocation.MyCommand.Path

Write-Host ('Invocation command path: {0}' -f $MyInvocation.MyCommand.Path)
$commonps1Path = (join-path (Split-Path -Parent $MyInvocation.MyCommand.Path) "Common.ps1")
Write-Host ('Common.ps1 path: {0}' -f $commonps1Path)
Write-Host ('Common.ps1 path exists: {0}' -f (Test-Path $commonps1Path))

#Load common automation library
$c = . (join-path (Split-Path -Parent $MyInvocation.MyCommand.Path) "Common.ps1")
$script:scriptName = 'BUILD'

Write-InfoLog ("CommandPath = {0}" -f $MyInvocation.MyCommand.Path)

try
{   
    $ErrorActionPreference = "Stop"
    #Check-PowerShellVersion
    #Step
    #Read environment variables comming from the build template (or the parm file)
    Get-InputVariables(Split-Path -Parent $MyInvocation.MyCommand.Path)
    
    if($dropLocation -eq $null -or (Test-path $dropLocation) -eq $false)
    {
        Write-TerminatingErrorLog "Drop location ($dropLocation) is not valid."
    }
    
    Get-BuildVersion

    Write-InfoLog ("Build Starting : {0}" -f (Get-Date)) 

    Write-InfoLog ("Creating output directories : {0}" -f (Get-Date)) 
    Create-BuildFolders
}
catch
{
    #Write-ErrorLog "Error occured while building."
    Write-TerminatingErrorLog 'Error occured while building.'
}
    
try
{   
    $script:transcriptStarted = $true
    Start-Transcript (join-path $currentLogFolder 'BuildLogs.log')  

    Get-DefaultParameters
    Get-OverrideParameters
    Get-ImportOverrideParameters
    #Load the AX PS libary
    $x = . (join-path (join-path (Get-Item $SetupRegistryPath).GetValue("InstallDir") "ManagementUtilities") "Microsoft.Dynamics.ManagementUtilities.ps1")

    #Step
    #Read the AX information from the registry
    Read-AXClientConfiguration
    Read-AxServerConfiguration
    Write-InfoLog ('Printing all variables')
    Write-InfoLog (Get-Variable)

    #Step
    if ((Validate-InputVariables) -eq $null)
    {
        Register-SQLSnapIn
        $script:buildModelStarted = $true
        Build-AX
        if((Test-Path (join-path $dropLocation 'BuildErrors.err')) -ne $true)
        {
            Create-BuildCompleted
            Write-InfoLog ("Build finished : {0}" -f (Get-Date)) 
            Write-InfoLog ("BUILD SUCCESS") 
        }
        else
        {
            Write-InfoLog ("Errors occured while building.")
            Write-InfoLog ("BUILD FAILED")        
        }
    }
    else
    {
        Write-InfoLog "Parameter validation errors."
    }
}
catch
{
    Write-ErrorLog ("Error occured while building.")
    Write-ErrorLog ($Error[0])
    
    if($buildModelStarted -eq $true)
    {
        $script:buildModelStarted = $false
        try
        {
            if($NoCleanOnError -ne $true)
            {
                Write-InfoLog ("                                                                 ") 
                Write-InfoLog ("*****************************************************************") 
                Write-InfoLog ("****************TRYING TO REVERT BUILD***************************") 
                Clean-Build
                Write-InfoLog ("*****************************************************************") 
                Write-InfoLog ("*****************************************************************") 
                Write-InfoLog ("                                                                 ") 
            }
        }
        catch
        {
            Write-ErrorLog ("Failed to revert build.")
            Write-ErrorLog ($Error[0])
        }
    }
    $ErrorActionPreference = "SilentlyContinue"
    Write-InfoLog ("Build finished : {0}" -f (Get-Date)) 
    Write-InfoLog ("BUILD FAILED")
}
finally
{    
    Copy-Item -Path (Join-Path $clientLogDir *.*) -Destination (join-path $currentLogFolder "DetailedLogs") -Force -ErrorAction SilentlyContinue 

    Enable-VCS

    if($transcriptStarted -eq $true)
    {Stop-Transcript}
}
# SIG # Begin signature block
# MIIauQYJKoZIhvcNAQcCoIIaqjCCGqYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUDsVHxG0FLZ4JM/+buPptqHHS
# 8JegghWCMIIEwzCCA6ugAwIBAgITMwAAADaeewBVssNdLAAAAAAANjANBgkqhkiG
# 9w0BAQUFADB3MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
# A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEw
# HwYDVQQDExhNaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EwHhcNMTMwMzI3MjAwODI4
# WhcNMTQwNjI3MjAwODI4WjCBszELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjENMAsGA1UECxMETU9QUjEnMCUGA1UECxMebkNpcGhlciBEU0UgRVNO
# OkJCRUMtMzBDQS0yREJFMSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBT
# ZXJ2aWNlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvBmYmWSq9tq9
# TdEuQs9m7Ncr2HJUyU3z+i4JBkTQEzAtoukQKnUbP1Zcd7f66bz41enN9MiOmyvw
# wBGa8Ve4bL0GjdbBYY/WMOEmqQom0XbagJXqfzAD3A/A1k2Gq7raHn51pQLb4TCz
# QQedDDDfugtCawe9Q8lyj9UZDl3j9fsx7XFsiK7nO3ro+G4X3cv2B/j+IQjpIDoQ
# 4fNJMWfp0jOWwRFXy4v7KnDPO/G73m61dLk9U70D5NzKsvcWvdmac8I+yUdiQlfF
# CsiYycRYKd4O6/J8GPvEq9cLl7UZpgtJODqwUwSIBg6iirll6g5svVqt0Hue0Xoy
# R/Ie0SNuNQIDAQABo4IBCTCCAQUwHQYDVR0OBBYEFMwfZPc12efmJAP0En8Ep94v
# Gr5hMB8GA1UdIwQYMBaAFCM0+NlSRnAK7UD7dvuzK7DDNbMPMFQGA1UdHwRNMEsw
# SaBHoEWGQ2h0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3Rz
# L01pY3Jvc29mdFRpbWVTdGFtcFBDQS5jcmwwWAYIKwYBBQUHAQEETDBKMEgGCCsG
# AQUFBzAChjxodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY3Jv
# c29mdFRpbWVTdGFtcFBDQS5jcnQwEwYDVR0lBAwwCgYIKwYBBQUHAwgwDQYJKoZI
# hvcNAQEFBQADggEBAFsHcVX7PnDXFDRFUmUNen+e7t7n+WMlVp3qsYH318h82rXp
# Td6wCRG7bLcMMjUSAOCOn7il2jt68y2GkZ6QRIz3NGE2UOZoj1wNCED4Cw2r1Q9F
# SftgR7r5wENBsu5oIGIWtaaf1lNZx7tQoLR8kElP01X27HxYUR7eEtfbfjv8cEa+
# ZQ6ER/tJWAi7eE2Lx8G2nKhFQiAkwQdyfwhXdZ9SlE8UYzkFzK0xA4EHEHqRfzqK
# 2r871svWmnJj/BHgkVIR5Ul/age2xSK+pVTouRQEZLAuWB9H32XIlA0rJTRinaHQ
# hiO16llZ8Oo61VIvwHLHCIUlQPbc4RXEUNTz0ukwggTsMIID1KADAgECAhMzAAAA
# sBGvCovQO5/dAAEAAACwMA0GCSqGSIb3DQEBBQUAMHkxCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xIzAhBgNVBAMTGk1pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBMB4XDTEzMDEyNDIyMzMzOVoXDTE0MDQyNDIyMzMzOVowgYMxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xDTALBgNVBAsTBE1PUFIx
# HjAcBgNVBAMTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjCCASIwDQYJKoZIhvcNAQEB
# BQADggEPADCCAQoCggEBAOivXKIgDfgofLwFe3+t7ut2rChTPzrbQH2zjjPmVz+l
# URU0VKXPtIupP6g34S1Q7TUWTu9NetsTdoiwLPBZXKnr4dcpdeQbhSeb8/gtnkE2
# KwtA+747urlcdZMWUkvKM8U3sPPrfqj1QRVcCGUdITfwLLoiCxCxEJ13IoWEfE+5
# G5Cw9aP+i/QMmk6g9ckKIeKq4wE2R/0vgmqBA/WpNdyUV537S9QOgts4jxL+49Z6
# dIhk4WLEJS4qrp0YHw4etsKvJLQOULzeHJNcSaZ5tbbbzvlweygBhLgqKc+/qQUF
# 4eAPcU39rVwjgynrx8VKyOgnhNN+xkMLlQAFsU9lccUCAwEAAaOCAWAwggFcMBMG
# A1UdJQQMMAoGCCsGAQUFBwMDMB0GA1UdDgQWBBRZcaZaM03amAeA/4Qevof5cjJB
# 8jBRBgNVHREESjBIpEYwRDENMAsGA1UECxMETU9QUjEzMDEGA1UEBRMqMzE1OTUr
# NGZhZjBiNzEtYWQzNy00YWEzLWE2NzEtNzZiYzA1MjM0NGFkMB8GA1UdIwQYMBaA
# FMsR6MrStBZYAck3LjMWFrlMmgofMFYGA1UdHwRPME0wS6BJoEeGRWh0dHA6Ly9j
# cmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY0NvZFNpZ1BDQV8w
# OC0zMS0yMDEwLmNybDBaBggrBgEFBQcBAQROMEwwSgYIKwYBBQUHMAKGPmh0dHA6
# Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljQ29kU2lnUENBXzA4LTMx
# LTIwMTAuY3J0MA0GCSqGSIb3DQEBBQUAA4IBAQAx124qElczgdWdxuv5OtRETQie
# 7l7falu3ec8CnLx2aJ6QoZwLw3+ijPFNupU5+w3g4Zv0XSQPG42IFTp8263Os8ls
# ujksRX0kEVQmMA0N/0fqAwfl5GZdLHudHakQ+hywdPJPaWueqSSE2u2WoN9zpO9q
# GqxLYp7xfMAUf0jNTbJE+fA8k21C2Oh85hegm2hoCSj5ApfvEQO6Z1Ktwemzc6bS
# Y81K4j7k8079/6HguwITO10g3lU/o66QQDE4dSheBKlGbeb1enlAvR/N6EXVruJd
# PvV1x+ZmY2DM1ZqEh40kMPfvNNBjHbFCZ0oOS786Du+2lTqnOOQlkgimiGaCMIIF
# vDCCA6SgAwIBAgIKYTMmGgAAAAAAMTANBgkqhkiG9w0BAQUFADBfMRMwEQYKCZIm
# iZPyLGQBGRYDY29tMRkwFwYKCZImiZPyLGQBGRYJbWljcm9zb2Z0MS0wKwYDVQQD
# EyRNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkwHhcNMTAwODMx
# MjIxOTMyWhcNMjAwODMxMjIyOTMyWjB5MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMSMwIQYDVQQDExpNaWNyb3NvZnQgQ29kZSBTaWduaW5nIFBD
# QTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALJyWVwZMGS/HZpgICBC
# mXZTbD4b1m/My/Hqa/6XFhDg3zp0gxq3L6Ay7P/ewkJOI9VyANs1VwqJyq4gSfTw
# aKxNS42lvXlLcZtHB9r9Jd+ddYjPqnNEf9eB2/O98jakyVxF3K+tPeAoaJcap6Vy
# c1bxF5Tk/TWUcqDWdl8ed0WDhTgW0HNbBbpnUo2lsmkv2hkL/pJ0KeJ2L1TdFDBZ
# +NKNYv3LyV9GMVC5JxPkQDDPcikQKCLHN049oDI9kM2hOAaFXE5WgigqBTK3S9dP
# Y+fSLWLxRT3nrAgA9kahntFbjCZT6HqqSvJGzzc8OJ60d1ylF56NyxGPVjzBrAlf
# A9MCAwEAAaOCAV4wggFaMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFMsR6MrS
# tBZYAck3LjMWFrlMmgofMAsGA1UdDwQEAwIBhjASBgkrBgEEAYI3FQEEBQIDAQAB
# MCMGCSsGAQQBgjcVAgQWBBT90TFO0yaKleGYYDuoMW+mPLzYLTAZBgkrBgEEAYI3
# FAIEDB4KAFMAdQBiAEMAQTAfBgNVHSMEGDAWgBQOrIJgQFYnl+UlE/wq4QpTlVnk
# pDBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtp
# L2NybC9wcm9kdWN0cy9taWNyb3NvZnRyb290Y2VydC5jcmwwVAYIKwYBBQUHAQEE
# SDBGMEQGCCsGAQUFBzAChjhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2Nl
# cnRzL01pY3Jvc29mdFJvb3RDZXJ0LmNydDANBgkqhkiG9w0BAQUFAAOCAgEAWTk+
# fyZGr+tvQLEytWrrDi9uqEn361917Uw7LddDrQv+y+ktMaMjzHxQmIAhXaw9L0y6
# oqhWnONwu7i0+Hm1SXL3PupBf8rhDBdpy6WcIC36C1DEVs0t40rSvHDnqA2iA6VW
# 4LiKS1fylUKc8fPv7uOGHzQ8uFaa8FMjhSqkghyT4pQHHfLiTviMocroE6WRTsgb
# 0o9ylSpxbZsa+BzwU9ZnzCL/XB3Nooy9J7J5Y1ZEolHN+emjWFbdmwJFRC9f9Nqu
# 1IIybvyklRPk62nnqaIsvsgrEA5ljpnb9aL6EiYJZTiU8XofSrvR4Vbo0HiWGFzJ
# NRZf3ZMdSY4tvq00RBzuEBUaAF3dNVshzpjHCe6FDoxPbQ4TTj18KUicctHzbMrB
# 7HCjV5JXfZSNoBtIA1r3z6NnCnSlNu0tLxfI5nI3EvRvsTxngvlSso0zFmUeDord
# EN5k9G/ORtTTF+l5xAS00/ss3x+KnqwK+xMnQK3k+eGpf0a7B2BHZWBATrBC7E7t
# s3Z52Ao0CW0cgDEf4g5U3eWh++VHEK1kmP9QFi58vwUheuKVQSdpw5OPlcmN2Jsh
# rg1cnPCiroZogwxqLbt2awAdlq3yFnv2FoMkuYjPaqhHMS+a3ONxPdcAfmJH0c6I
# ybgY+g5yjcGjPa8CQGr/aZuW4hCoELQ3UAjWwz0wggYHMIID76ADAgECAgphFmg0
# AAAAAAAcMA0GCSqGSIb3DQEBBQUAMF8xEzARBgoJkiaJk/IsZAEZFgNjb20xGTAX
# BgoJkiaJk/IsZAEZFgltaWNyb3NvZnQxLTArBgNVBAMTJE1pY3Jvc29mdCBSb290
# IENlcnRpZmljYXRlIEF1dGhvcml0eTAeFw0wNzA0MDMxMjUzMDlaFw0yMTA0MDMx
# MzAzMDlaMHcxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD
# VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xITAf
# BgNVBAMTGE1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQTCCASIwDQYJKoZIhvcNAQEB
# BQADggEPADCCAQoCggEBAJ+hbLHf20iSKnxrLhnhveLjxZlRI1Ctzt0YTiQP7tGn
# 0UytdDAgEesH1VSVFUmUG0KSrphcMCbaAGvoe73siQcP9w4EmPCJzB/LMySHnfL0
# Zxws/HvniB3q506jocEjU8qN+kXPCdBer9CwQgSi+aZsk2fXKNxGU7CG0OUoRi4n
# rIZPVVIM5AMs+2qQkDBuh/NZMJ36ftaXs+ghl3740hPzCLdTbVK0RZCfSABKR2YR
# JylmqJfk0waBSqL5hKcRRxQJgp+E7VV4/gGaHVAIhQAQMEbtt94jRrvELVSfrx54
# QTF3zJvfO4OToWECtR0Nsfz3m7IBziJLVP/5BcPCIAsCAwEAAaOCAaswggGnMA8G
# A1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFCM0+NlSRnAK7UD7dvuzK7DDNbMPMAsG
# A1UdDwQEAwIBhjAQBgkrBgEEAYI3FQEEAwIBADCBmAYDVR0jBIGQMIGNgBQOrIJg
# QFYnl+UlE/wq4QpTlVnkpKFjpGEwXzETMBEGCgmSJomT8ixkARkWA2NvbTEZMBcG
# CgmSJomT8ixkARkWCW1pY3Jvc29mdDEtMCsGA1UEAxMkTWljcm9zb2Z0IFJvb3Qg
# Q2VydGlmaWNhdGUgQXV0aG9yaXR5ghB5rRahSqClrUxzWPQHEy5lMFAGA1UdHwRJ
# MEcwRaBDoEGGP2h0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1
# Y3RzL21pY3Jvc29mdHJvb3RjZXJ0LmNybDBUBggrBgEFBQcBAQRIMEYwRAYIKwYB
# BQUHMAKGOGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljcm9z
# b2Z0Um9vdENlcnQuY3J0MBMGA1UdJQQMMAoGCCsGAQUFBwMIMA0GCSqGSIb3DQEB
# BQUAA4ICAQAQl4rDXANENt3ptK132855UU0BsS50cVttDBOrzr57j7gu1BKijG1i
# uFcCy04gE1CZ3XpA4le7r1iaHOEdAYasu3jyi9DsOwHu4r6PCgXIjUji8FMV3U+r
# kuTnjWrVgMHmlPIGL4UD6ZEqJCJw+/b85HiZLg33B+JwvBhOnY5rCnKVuKE5nGct
# xVEO6mJcPxaYiyA/4gcaMvnMMUp2MT0rcgvI6nA9/4UKE9/CCmGO8Ne4F+tOi3/F
# NSteo7/rvH0LQnvUU3Ih7jDKu3hlXFsBFwoUDtLaFJj1PLlmWLMtL+f5hYbMUVbo
# nXCUbKw5TNT2eb+qGHpiKe+imyk0BncaYsk9Hm0fgvALxyy7z0Oz5fnsfbXjpKh0
# NbhOxXEjEiZ2CzxSjHFaRkMUvLOzsE1nyJ9C/4B5IYCeFTBm6EISXhrIniIh0EPp
# K+m79EjMLNTYMoBMJipIJF9a6lbvpt6Znco6b72BJ3QGEe52Ib+bgsEnVLaxaj2J
# oXZhtG6hE6a/qkfwEm/9ijJssv7fUciMI8lmvZ0dhxJkAj0tr1mPuOQh5bWwymO0
# eFQF1EEuUKyUsKV4q7OglnUa2ZKHE3UiLzKoCG6gW4wlv6DvhMoh1useT8ma7kng
# 9wFlb4kLfchpyOZu6qeXzjEp/w7FW1zYTRuh2Povnj8uVRZryROj/TGCBKEwggSd
# AgEBMIGQMHkxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD
# VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xIzAh
# BgNVBAMTGk1pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBAhMzAAAAsBGvCovQO5/d
# AAEAAACwMAkGBSsOAwIaBQCggbowGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFJiH
# 5Z9PmgkYDrby1hghqgTnIYPHMFoGCisGAQQBgjcCAQwxTDBKoBiAFgBCAHUAaQBs
# AGQAQQBYAC4AcABzADGhLoAsaHR0cDovL3d3dy5NaWNyb3NvZnQuY29tL01pY3Jv
# c29mdER5bmFtaWNzLyAwDQYJKoZIhvcNAQEBBQAEggEAYUeNrdL23x7wdblmPY8l
# 44OBweAoljOfgqAKUe3f2FNiOq+nm6K0bsO9dXLkNVNTZ/XdZ5o7yWv3JiKD9Zj2
# 5N6h48lSos28R9IO55FWc3cVAsJLWOu0cGxpYPXSrT/eZSTZAcZ7Xg7XzIdIgg6g
# 0irExLyJeSkBLxMU1WIkq4Mg/ZGwJ77GP8nXx9Ylch0/CwZ8v/A/uIYY9kKw/FPp
# +1gZRHMZSCeqfHkxO9H5Mj8DFaRpc4Ez8VR41jZbPe1D4ofxAHqb1jd1Szyhyh/Y
# 7qOXEceJmwMDykpqzeVmq6Ny+lNWjQbHj6BeTCZH0vJ2a8gVVugKj+va0JVefia+
# taGCAigwggIkBgkqhkiG9w0BCQYxggIVMIICEQIBATCBjjB3MQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEwHwYDVQQDExhNaWNyb3NvZnQgVGlt
# ZS1TdGFtcCBQQ0ECEzMAAAA2nnsAVbLDXSwAAAAAADYwCQYFKw4DAhoFAKBdMBgG
# CSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTEzMDYyMTIy
# MTcwMVowIwYJKoZIhvcNAQkEMRYEFFFVB3k17VbD9MQW5FWnlnfPFyRLMA0GCSqG
# SIb3DQEBBQUABIIBAIBOfTfCzZXbYFoVxfvMXgDz32zLBA9ss5orM8LHXL0RMOUB
# ikAUTrvQvV2+oOLM0mEAnN726HrcnRSGLk5m0zyZRwaBMyUAbf8R5pYylzNmeTc6
# 9macCwwWqaXgus2j5pDrCKkuPSqxYTKBpLriycPO7Qb5ydFU7aLf/mQTSCg9m8LP
# REW8sCN+bPDS0hHTt59oZXamDTj8fPEHCPGYmOP84aFDi8ZroSOG1TEWDzvRCC8d
# V/71qmiavuGZZECTBj+ZEcf415o5tvFy5IGtEMKK1nt+w7+4pciS3l16vZbUBLQJ
# hnz9sSEcJKE9SOV5ALKw6+oFOO6sc5ZPGpIgxvA=
# SIG # End signature block
