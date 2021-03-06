$str = 'AssemblyDisplayName #MMS.Cloud.Commands.CMI, Version=1.0.4.0, Culture=neutral, PublicKeyToken=be6d35a4ca1458fd, processorArchitecture=MSIL'
$re1 = '\bVersion\=(?<version>\d+(?:\.\d+)+)'
$re2 = '\b(?<assemblyname>MMS\.Cloud\.Commands\.[a-zA-Z0-9._%+-]+)[ ,]+Version\=(?<version>\d+(?:\.\d+)+)\b'
$regex = "AssemblyDisplayName\s\#(?<assemblyname>MMS\.Cloud\.Commands\.[a-zA-Z0-9._%+-]+)\,\bVersion\=(?<version>\d+(?:\.\d+)+)\s"
if ($str -match $re2)
{
    Write-Host ('Matched: assembly = {0}, version = {1}' -f $matches['assemblyname'], $matches['version'])
}
else
{
    Write-Host 'Not matched'
}