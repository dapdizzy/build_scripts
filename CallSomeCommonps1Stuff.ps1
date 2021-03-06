function Get-InputVariables ($homePath, $fileName = "DeployParameters.txt")
{
    $script:AxBuildDir = $homePath
    $RunDeployParmFile = (Join-Path $AxBuildDir $fileName)
    Write-InfoLog "Input parameters"        
    if ((Test-Path $RunDeployParmFile) -ne $false)
    {
        $fileContent = Get-Content $RunDeployParmFile
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
                Write-InfoLog "Bad DeployParameters file content: {0}" -f $line
            }
        }       
    }   
    if ($script:SqlServer -eq $null -or [string]::IsNullOrEmpty($script:SqlServer))
    {
        $script:SqlServer           = GetEnvironmentVariable("SqlServer")
    }
    if ($script:SqlDatabase -eq $null -or [string]::isNullOrEmpty($script:SqlDatabase))
    {
        $script:SqlDatabase         = GetEnvironmentVariable("SqlDatabase")
    }
    if ($script:sqlModelDatabase -eq $null -or [string]::IsNullOrEmpty($script:sqlModelDatabase))
    {
        $script:sqlModelDatabase    = GetEnvironmentVariable("SqlModelDatabase")
    }
    $script:dropLocation            = GetEnvironmentVariable("BuildLocation")
    # Assume this is 'drop root' (the folder containing concrete build folders) folder in case this is not a 'build folder'
    if ((Is-BuildFolder $script:dropLocation) -ne $true)
    {
        # Override the value with the latest successful build folder found
        $script:dropLocation = (Get-LatestBuildFolder $script:dropLocation).FullName
    }
    if ($script:ServerBinDir -eq $null -or [string]::isNullOrEmpty($script:serverBinDir))
    {
        $script:ServerBinDir        = GetEnvironmentVariable("ServerBinDir")
    }
    $script:LogFolder               = GetEnvironmentVariable("LogFolder")
    if ($script:LogFolder -eq $null -or [string]::IsNullOrEmpty($script:LogFolder))
    {
        # Override with active AX configuration client log dir in case not defined
        $script:LogFolder = $script:clientLogDir
    }
    # Override variable only in case it is not defined or null
    if ($script:AOSname -eq $null -or [string]::IsNullOrEmpty($script:AOSname))
    {
        $script:AOSname             = GetEnvironmentVariable("AOSname")
    }
    $script:AxCompileAll            = GetEnvironmentVariable("CompileAll")
    $script:CompileCIL              = GetEnvironmentVariable("CompileCIL")
    $script:TFSIntegration          = GetEnvironmentVariable("TFSIntegration")
    $script:TFSUrl                  = GetEnvironmentVariable("TFSUrl")
    $script:TFSLabel                = GetEnvironmentVariable("TFSLabel")
    $script:ApplicationSourceDir    = GetEnvironmentVariable("ApplicationSourceDir")
    if ($script:ApplicationSourceDir -eq $null -or [string]::isNullOrEmpty($script:ApplicationSourceDir))
    {
        $local:systemName = GetEnvironmentVariable("SystemName")
        $script:ApplicationSourceDir = Join-Path $script:ServerBinDir "Application\$local:systemName"
        if ((Test-Path $script:ApplicationSourceDir) -ne $true)
        {
            New-Item -Path $script:ApplicationSourceDir -ItemType Directory -Confirm
        }
    }
    $script:CleanOnly               = GetEnvironmentVariable("UninstallOnly")
    $script:AOSNotOnDeployBox       = GetEnvironmentVariable("AOSNotOnDeployBox")
    $script:NoCleanOnError          = GetEnvironmentVariable("NoCleanOnError")
    $script:InstallModelStore       = GetEnvironmentVariable("InstallModelStore")
    $script:MsBuildPath             = GetEnvironmentVariable("MsBuildDir")
    $script:TFSWorkspace            = GetEnvironmentVariable("TFSWorkspace")
    
    if ((Test-Path $RunDeployParmFile) -eq $false)
    {
        $private:buffer = @()
        $buffer += "SqlServer="+ $SqlServer
        $buffer += "SqlDatabase="+ $SqlDatabase
        $buffer += "SqlModelDatabase="+ $SqlModelDatabase
        $buffer += "BuildLocation="+ $dropLocation
        $buffer += "ServerBinDir="+ $ServerBinDir
        $buffer += "LogFolder="+ $LogFolder
        $buffer += "CompileAll=" + $AxCompileAll
        $buffer += "CompileCIL="+ $CompileCIL
        $buffer += "AOSname="+ $AOSname
        $buffer += "UninstallOnly="+ $CleanOnly                         
        $buffer += "AOSNotOnDeployBox="+ $AOSNotOnDeployBox
        $buffer += "NoCleanOnError="+ $NoCleanOnError
        $buffer += "TFSIntegration="+ $TFSIntegration
        $buffer += "TFSUrl="+ $TFSUrl
        $buffer += "TFSLabel="+ $TFSLabel   
        $buffer += "ApplicationSourceDir="+ $ApplicationSourceDir
        $buffer | Out-File $RunDeployParmFile -Encoding Default
    }
    $script:vsProjBinFolder = join-path $dropLocation "VSProjBin"
}

$c = . (join-path (Split-Path -Parent $MyInvocation.MyCommand.Path) "common.ps1")
#$combinedXpoFilename = 'C:\AX\CombinedXPOs\Combined.VAR Model.xpo'
#CreateSpecificXPOs $combinedXpoFilename

<#$tfs = GET-TFS "https://mediamarkt.visualstudio.com/defaultcollection"

$authenticatedUser = $tfs.VCS.AuthenticatedUser
$hostName = [System.Net.Dns]::GetHostName()

Write-Host "TFS Authenticated user: $authenticatedUser, Host name: $hostName" -ForegroundColor Green

$workspaces = $tfs.VCS.QueryWorkspaces($null, $authenticatedUser, $hostName)

if ($workspaces -ne $null)
{
    Write-Host "Some workspaces were found`nLets list them for fun" -ForegroundColor Gray
    foreach ($workspace in $workspaces)
    {
        Write-Host "Workspace: $($workspace.Name)" -ForegroundColor Gray
    }
}
else
{
    Write-Host "No matching workspaces were found" -ForegroundColor Red
}

break


$w = $tfs.VCS.TryGetWorkspace("C:\Program Files\Microsoft Dynamics AX\60\Server\FAX\bin\Application\Fax")

if ($w -ne $null)
{
    Write-Host $w.Name -ForegroundColor Cyan

    #break
}
else
{
    Write-Host "No matching workspace was found" -ForegroundColor Red
}

break

$ApplicationSourceDir = "C:\Program Files\Microsoft Dynamics AX\60\Server\FAX\bin\Application"

Write-Host "Local Application Source Dir:`n$ApplicationSourceDir" -ForegroundColor Cyan

[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.TeamFoundation.VersionControl.Client') | Out-Null
$workstation = [Microsoft.TeamFoundation.VersionControl.Client.Workstation]::Current
if ($workstation -ne $null)
{
    Write-Host "Current workstation successfully found!`nWorkstation name: $($workstation.Name)" -ForegroundColor Gray
}
$workspacesInfo = $workstation.GetAllLocalWorkspaceInfo()
if (($workspacesInfo -ne $null) -and ($workspacesInfo.Length -gt 0))
{
    Write-Host "Some local workspaces found: $($workspacesInfo.Length)`nLets loop them through!" -fore Gray
    foreach ($workspaceInfo in $workspacesInfo)
    {
        Write-Host "Workspace info: $($workspaceInfo.Name)" -ForegroundColor Gray
    }
}
else
{
    Write-Host "No local workspaces found on workstation $($workstation.Name)" -ForegroundColor Gray
}
$workspaceInfo = $workstation.GetLocalWorkspaceInfo($ApplicationSourceDir)

if ($workspaceInfo -ne $null)
{
    Write-Host "WOW! WorkspaceInfo matching the local path finally found!" -ForegroundColor Cyan


    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.TeamFoundation.Client') | Out-Null
    $collection = New-Object [Microsoft.TeamFoundation.Client.TfsTeamProjectCollection]($info.ServerUri)
    $workspace = $info.GetWorkspace($collection)

    if ($workspace -ne $null)
    {
        Write-Host "The workspace exists which is fine" -ForegroundColor Green
        Write-Host "Workspace name: $($workspace.Name)" -ForegroundColor Magenta
    }
    else
    {
        Write-Host "Unable to find the workspace" -ForegroundColor Red
    }
    <#
    TfsTeamProjectCollection collection = new TfsTeamProjectCollection(info.ServerUri);
    Workspace workspace = info.GetWorkspace(collection);
    
}
else
{
    Write-Host "Workspace info matching the given local path is not found" -fore Red
}

break


$guid = [Guid]::NewGuid().ToString()
$wName = 'AXWorkspace_' + $guid
$w = $tfs.VCS.CreateWorkspace($wName, $tfs.VCS.AuthenticatedUser)
$ApplicationSourceDir = "C:\Program Files\Microsoft Dynamics AX\60\Server\FAX\bin\Application\FAX"
$tfsWorkspace = "$/FAX/FAX"
$w.Map($tfsWorkspace, $ApplicationSourceDir)
$versionSpec = [Microsoft.TeamFoundation.VersionControl.Client.VersionSpec]::Latest
#$w.Get($versionSpec, 1)


break

robocopy /?

break #>

Get-OverrideParameters
Read-AXClientConfiguration
Read-AxServerConfiguration

Get-InputVariables "C:\AX\BuildScripts" "DeployParameters1.txt"

Get-Variable

break

$model = Get-Item -Path "C:\Program Files\Microsoft Dynamics AX\60\Server\AXTest\bin\Application\FAX\VAR Model\Model.xml"

$modelName = 'VAR Model'

Create-AOTObjectsTxt $model

Write-Host "Done!" -ForegroundColor Green

Verify-AOTObjects

break



break

$ApplicationSourceDir = "C:\Program Files\Microsoft Dynamics AX\60\Server\AXTest\bin\Application\Fax"

$exclusionList = @()

Write-Host "ApplicationSourceDir: $ApplicationSourceDir" -ForegroundColor Cyan

gci -Path $ApplicationSourceDir -Exclude $exclusionList -Include *.xpo, *.csproj, *.dynamicsproj -File -Recurse `
|% {sp $_ IsReadOnly $true}

Write-Host "Setting synched files to ReadOnly Done. $(Get-Date)" -ForegroundColor Cyan

break

$path = "\C:\hjshdjsd\"
$isLocal = Is-PathLocal $path

Write-Host "Path $path is local: $isLocal" -ForegroundColor Cyan

$path = "\\MOW04DEV014\Drop\Fax\1.0.0.232\Application\Appl"
$isLocal = Is-PathLocal $path

Write-Host "Path $path is local: $isLocal" -ForegroundColor Cyan

break

$currentLogFolder = "C:\Test"

$localModelStorePath = Copy-Modelstores "\\MOW04DEV014\Drop\Fax\1.0.0.232\Application\Appl"

#Copy-Packages "\\MOW04DEV014\Drop\Fax\1.0.0.232\Logs\Packages"

break

#Write-ErrorLog 'Some error message here...'
#return

$script:startupDir = $MyInvocation.MyCommand.Path

Get-OverrideParameters
Read-AXClientConfiguration
Read-AxServerConfiguration



#$exclusionList = Build-PendingChangesList "C:\Program Files\Microsoft Dynamics AX\60\Server\MicrosoftDynamicsAX\bin\Application\FAX"

Remove-OldSourceControlledFiles "C:\Program Files\Microsoft Dynamics AX\60\Server\MicrosoftDynamicsAX\bin\Application\FAX"

break

Write-Host "And here's our exclusion list, build specifically for yA!" -ForegroundColor Cyan
foreach ($item in $exclusionList)
{
    Write-Host $item -ForegroundColor Green
}

Read-Host "R U Satisfied?"

break

#$model = Get-Item -Path "C:\Program Files\Microsoft Dynamics AX\60\Server\MicrosoftDynamicsAX\bin\Application\FAX\VAR Model\Model.xml"
Create-AOTObjectsTxt $model

break

<#Write-Host "Client Log Dir: $clientLogDir" -ForegroundColor Cyan

Read-Host 'R U confused?'

break#>

Verify-AOTObjectsImported

break

<#$applicationSourceDir = 'C:\Program Files\Microsoft Dynamics AX\60\Server\LIPSAX\bin\Application\LIPS'

Import-MissedObjects

break#>

<#Create-AOTObjectsTxt (Get-Item -Path 'C:\Program Files\Microsoft Dynamics AX\60\Server\LIPSAX\bin\Application\LIPS\VAR Model\Model.xml')
break#>

$arguments = "-StartupCmd=verifyAOTObjects"
$axProcess = Start-Process $ax32 -WorkingDirectory $clientBinDir -PassThru -WindowStyle minimized -ArgumentList $arguments -OutVariable out
Write-host $out
Write-InfoLog (" ")
Write-InfoLog (" ")
if ($axProcess.WaitForExit(60000*5) -eq $false)
{
    $axProcess.Kill()
    Throw ("Error: AX AOT objects verification did not complete within {0} minutes" -f 5)
}

Write-Host 'Done!' -ForegroundColor Cyan

break


$currentLogFolder = 'C:\Program Files\Microsoft Dynamics AX\60\Server\LIPSAX\bin\Application\LIPS\VAR Model\Projects\Shared'

<#$projectFilesMap = @{}
$projectList = @()

$projectContents = Get-Content -Path 'C:\AX\Projects.txt'
foreach ($line in $projectContents)
{
    if ($projectFilesMap.ContainsKey($line) -eq $true)
    {
        Write-Host "Duplicate project $line" -ForegroundColor Red -BackgroundColor Black
        continue
    }
    $projectFilesMap.Add($line, @())
    $projectList += $line
}

$files = gci -Path "$currentLogFolder\*" -include 'Combined.VAR Model_prj(*).xpo' | Where-Object {$_.Name -match 'Combined.VAR Model_prj\([0-9]+\)\.xpo'}

foreach ($projectName in $projectList)
{
    Write-Host "Looking for project $projectName" -ForegroundColor Cyan
    $filesList = $projectFilesMap.get_Item($projectName)
    foreach ($file in $files)
    {
        Write-Host "Searching in file $($file.Name)" -ForegroundColor Green
        $contents = Get-Content -Path $file.FullName
        foreach ($line in $contents)
        {
            if ($line -match "Microsoft Dynamics AX Project[ :]+$projectName\b")
            {
                $filesList += $file.Name
                break
            }
        }
    }
    $projectFilesMap.set_Item($projectName, $filesList)
}

$lines = @()
foreach ($projectName in $projectFilesMap)
{
    $filesList = $projectFilesMap.get_Item($projectName)
    $line = "$projectName <--> $([string]::Join(', ', $filesList))"
    $lines += $line
}
$lines | Out-File -FilePath 'C:\AX\Project2FilesMapping.txt' -Encoding default

break#>

<#$fileName = 'C:\AX\Projects.txt'
$proj2FileMap = @{}
$contents = Get-Content -Path $filePath
foreach ($line in $contents)
{
    if ($line -match 'Microsoft Dynamics AX Project[ :]+(?<projectName>[a-zA-Z0-9_]+)\b')
    {
        $projectName = $matches['projectName']
        if ($proj2FileMap.ContainsKey($projectName) -ne $true)
        {
            $projFiles = @()
        }
        else
        {
            $projFiles = $proj2FileMap.Get_Item($projectName)
        }
        $projFiles += 
    }
}#>

$axLayer = 'var'

$aolCode = 'gR8aYLQYS3Yzj94qIoOUOA=='

$Model = Get-Item -Path 'C:\Program Files\Microsoft Dynamics AX\60\Server\LIPSAX\bin\Application\LIPS\VAR Model\Model.xml'

Import-XPO 'MMS_FormInfo.xpo'

break

$fileProjectsMap =@{}
$counter = 0
$files = gci -Path "$currentLogFolder\*" -include 'Combined.VAR Model_prj(*).xpo' | Where-Object {$_.Name -match 'Combined.VAR Model_prj\([0-9]+\)\.xpo'}
foreach ($file in $files)
{
    $contents = Get-Content $file
    $projects = @()
    foreach ($line in $contents)
    {
        if ($line -match 'Microsoft Dynamics AX Project[ :]+(?<projectName>[a-zA-Z0-9_]+)\b')
        {
            $projects += $matches['projectName']
        }
    }
    $fileProjectsMap.Add($file.Name, $projects)
}

$fileProjectsMap | Out-File -Path 'C:\AX\FileProjectsMap.txt' -Encoding default
break

<#$filePath = Join-Path $currentLogFolder 'Combined.VAR Model.xpo'
if ((Test-Path -Path $filePath) -ne $true)
{
    Write-Host "Seems like $filePath does not exist" -ForegroundColor Red -BackgroundColor Black
    break
}#>

#$nlines = 0
#select-string -pattern 'Microsoft Dynamics AX Project[ :]+(?<projectName>[a-zA-Z0-9_]+)\b' -path $filePath | % { $projects += $_.Matches.Captures['projectName'] }


<#$contents = Get-Content -Path $filePath
foreach ($line in $contents)
{
    if ($line -match 'Microsoft Dynamics AX Project[ :]+(?<projectName>[a-zA-Z0-9_]+)\b')
    {
        $projects += $matches['projectName']
    }
}
#>

$projects | Out-File -FilePath 'C:\AX\Projects_I.txt' -Encoding default

break

$items = gci -Path "$currentLogFolder\*" -Include 'Combined.VAR Model_prj*.xpo'
foreach ($item in $items)
{
    $contents = Get-Content $items
    foreach ($line in $content)
    {
        if ($line -match 'MMS_811_SourceSistemUpd')
        {
            Write-Host $file.Name -ForegroundColor Cyan
        }
    }
    #Import-XPO $item.Name # 'Combined.VAR Model_prj.xpo'
}

#CreateSpecificXPOs 'C:\AX\Build\Drop\LIPS\1.0.0.184\Logs\Combined.VAR Model.xpo'

break

#Copy-Item -Path (join-path (Split-Path -Parent $MyInvocation.MyCommand.Path) "AOTprco.log") -Destination $clientLogDir -Force -ErrorAction SilentlyContinue 
#Copy-PredefinedAOTprco
$currentLogFolder = 'C:\AX\Build\Drop\LIPS\1.0.0.120\Logs'
Create-PackagesConfig
Install-Packages

break

<#
$compileInLayer = 'var'

$aolParm = ''
$compileInLayerParm = ''
if($compileInLayer -ne $null)
{
    $AolCode = Get-AolCode $compileInLayer
    if ($aolCode -ne '') {$aolParm = '-aolCode={0}' -f $aolCode}
    
    $compileInLayerParm = '-aol={0}' -f $compileInLayer
}

$arguments = '{0} {1} -lazyclassloading -lazytableloading -StartupCmd=compilepartial -novsprojcompileall -internal=noModalBoxes' -f $compileInLayerParm,$aolParm
Write-host ("Calling CompilePartial API : {0}" -f (Get-Date)) 
$axProcess = Start-Process $ax32 -WorkingDirectory $clientBinDir -PassThru -WindowStyle minimized -ArgumentList $arguments -OutVariable out
Write-host $out
Write-InfoLog (" ")
Write-InfoLog (" ")
if ($axProcess.WaitForExit(60000*$CompileAllTimeout) -eq $false)
{
    $axProcess.Kill()
    Throw ("Error: AX compile partial did not complete within {0} minutes" -f $CompileAllTimeout)
}#>