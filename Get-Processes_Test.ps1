$processName = 'notepad'
$processes = Get-Process -Name $processName
$counter = 0
if ($processes -ne $null)
{
    foreach ($p in $processes)
    {
        Stop-Process -processname $p -Force
        $counter++
    }
}
Write-Host "$counter processes have been killed"