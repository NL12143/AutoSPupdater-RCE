
$spver = 

`
$launchPath
$patchPath
$credential = Get-Credential "dnbad\NC2643B"
$pass = $(ConvertFrom-SecureString $($credential.Password))
$servers = "P3000737"
$spver = 

$PSHOME
$server 
Function Install-Remote 
# Start powershell for each remote server, Invoke Start-RemoteUpdate  
{
ForEach ($server in $servers) {
Start-Process -FilePath "$PSHOME\powershell.exe" -ArgumentList "$versionSwitch -ExecutionPolicy Bypass ` 
Invoke-Command -ScriptBlock  {
    Test-ServerConnection -Server $server `
    Enable-RemoteSession -Server $server -plainPass $pass -launchPath `"$launchPath`"; `
    Import-Module -Name `"$launchPath\AutoSPUpdaterModule.psm1`" -DisableNameChecking -Global -Force `
    Start-RemoteUpdate -Server $server -plainPass -launchPath `"$launchPath`" -patchPath `"$patchPath`" -spVer $spver $verboseSwitch; `
        $session = New-PSSession -Name "AutoSPUpdaterSession-$server" -Authentication Credssp -Credential $credential -ComputerName $server
    }
}


$server 
Function Start-RemoteUpdate {
$sessionSSP = New-PSSession -Name "AutoSPUpdaterSession-$server" -Authentication CredSSP -Credential $credential -ComputerName $server
Invoke-Command -Session $sessionSSP -ScriptBlock {
  & "$launchPath\AutoSPUpdaterLaunch.ps1" -patchPath $patchPath -remoteAuthPassword $pass @verboseParameter
  } 
Remove-PSSession $session   
}