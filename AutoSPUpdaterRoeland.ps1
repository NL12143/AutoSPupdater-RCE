
.EXAMPLE
.\AutoSPUpdaterLaunch.ps1 -patchPath C:\SP\2013\Updates -remoteAuthPassword fuzzyBunny99
& C:\SP\AutoSPInstaller\AutoSPUpdaterLaunch.ps1

.ps1
Install-Remote -skipParallelInstall $skipParallelInstall -remoteFarmServers $remoteFarmServers -credential $credential -launchPath $launchPath -patchPath $patchPath @verboseParameter
InstallUpdatesFromPatchPath -patchPath $patchPath -spVer $spVer @verboseParameter
#endr
Clear-SPConfigurationCache

Set-Service -Name $service -StartupType $startupType
Write-Host -ForegroundColor White "  - Starting service $((Get-Service -Name $service).DisplayName)..."
Start-Service -Name $service
Get-SPProduct -Local

.psm1

Function InstallUpdatesFromPatchPath
INP $patchPath, $spVer
Local install 

Function Install-Remote 
INP $skipParallelInstall, $remoteFarmServers, $credential, $launchPath, $patchPath


Enable-RemoteSession -Server $server -plainPass $(ConvertFrom-SecureString $($credential.Password)) -launchPath `"$launchPath`"; `
Start-RemoteUpdate -Server $server -plainPass $(ConvertFrom-SecureString $($credential.Password)) -launchPath `"$launchPath`" -patchPath `"$patchPath`" -spVer $spver $verboseSwitch; `

# Launch each farm server install in sequence, one-at-a-time, or run these steps on the current $targetServer
Write-Host -ForegroundColor Green " - Server: $server"
Enable-RemoteSession -Server $server -Password $(ConvertFrom-SecureString $($credential.Password)) -launchPath $launchPath; `
InstallUpdatesFromPatchPath `
}

Function Start-RemoteUpdate 
$server, $plainPass, $launchPath, $patchPath, $spVer
$session = New-PSSession -Name "AutoSPUpdaterSession-$server" -Authentication Credssp -Credential $credential -ComputerName $server
Invoke-Command -ScriptBlock {& "$launchPath\AutoSPUpdaterLaunch.ps1" -patchPath $patchPath -remoteAuthPassword $(ConvertFrom-SecureString $($credential.Password)) @verboseParameter} -Session $session
Remove-PSSession $session

Function Update-ContentDatabases


function Confirm-LocalSession
function Enable-CredSSP
function Test-ServerConnection
function Enable-RemoteSession
function StartTracing 
function UnblockFiles 
function WriteLine
Function ConvertTo-PlainText( [security.securestring]$secure )
Function Test-UpgradeRequired
Function Test-PSConfig
Function Clear-SPConfigurationCache
Function Get-SPYear
