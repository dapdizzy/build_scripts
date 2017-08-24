$ticks = .\Get-Ticks.ps1
$folder = $args[0]
iex "cd '$folder'"
$exp = "iex.bat --sname s$ticks --cookie cookie -S mix"
iex $exp