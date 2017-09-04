$dataFolder = $args[0]
$databaseName = $args[1]

Write-Host "Data folder is ($dataFolder)" -ForegroundColor Cyan

Write-Host "Database name is ($databaseName)" -ForegroundColor Cyan

$psi = New-Object 'System.Diagnostics.ProcessStartInfo'
$psi.UseShellExecute = $false
$psi.RedirectStandardInput = $true
$psi.FileName = 'dp.exe'
$psi.Arguments = @('IMPORT', $dataFolder, $databaseName)

$process = New-Object 'System.Diagnostics.Process'
$process.StartInfo = $psi
$process.Start()

return $process