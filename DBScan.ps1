$svr = new-object ('Microsoft.SqlServer.Management.Smo.Server') 'MOW04DEV014'
$dbfl = @()
$relocateData = @()

foreach ($db in $svr.Databases | Where-Object {$_.Name -eq 'AXTest'})
{
    $dbname = $db.Name

    foreach ($fg in $db.FileGroups)
    {
        foreach ($fl in $fg.Files)
        {
            $dirnm = $fl.FileName | Split-Path -Parent
            $filnm = $fl.FileName | Split-Path -Leaf
            $dfl = $fl | select @{Name="DBName"; Expression={$dbname}}, Name, @{Name="Directory"; Expression={$dirnm}}, @{Name="FileName"; Expression={$filnm}}, Size, UsedSpace
            $dbfl += $dfl
            $relocateData += New-Object Microsoft.SqlServer.Management.Smo.RelocateFile($fl.Name, $fl.FileName)
        }
    }
    foreach ($fl in $db.LogFiles)
    {
        $dirnm = $fl.FileName | Split-Path -Parent
        $filnm = $fl.FileName | Split-Path -Leaf
        $dfl = $fl | select @{Name="DBName"; Expression={$dbname}}, Name, @{Name="Directory"; Expression={$dirnm}}, @{Name="FileName"; Expression={$filnm}}, Size, UsedSpace
        $dbfl += $dfl
    }
}

$dbfl | Format-Table -AutoSize
