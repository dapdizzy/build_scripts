$wc = (new-object net.webclient)
$wc.Proxy = (new-object Net.WebProxy("bluecoat.media-saturn.com:80", $true))
$wc.Proxy.Credentials =[System.Net.CredentialCache]::DefaultNetworkCredentials
iex($wc.DownloadString('https://chocolatey.org/install.ps1')) #&& SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
#"iex $wc.DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin

#iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))