https://docs.microsoft.com/en-us/troubleshoot/azure/virtual-machines/credssp-encryption-oracle-remediation
 
# Configures the server for WinRM and WSManCredSSP
Write-Host -ForegroundColor White " - Configuring PowerShell remoting..."
$winRM = Get-Service -Name winrm
If ($winRM.Status -ne "Running")
{
    Start-Service -Name winrm
}

# Only change the PowerShell execution policy if we need to
if ((Get-ExecutionPolicy) -ne "Unrestricted" -and (Get-ExecutionPolicy) -ne "Bypass")
{
    Write-Host -ForegroundColor White " - Setting PowerShell execution policy..."
    Set-ExecutionPolicy Bypass -Force
}
else
{
    Write-Host -ForegroundColor White " - PowerShell execution policy already set to `"$(Get-ExecutionPolicy)`"."
}

Enable-PSRemoting -Force
Enable-WSManCredSSP -Role Server -Force | Out-Null
# Increase the local memory limit to 1 GB
Set-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB 1024 -WarningAction SilentlyContinue
Get-Item WSMan:\localhost\Shell\

#Get out of this PowerShell process
Stop-Process -Id $PID -Force

Notes RCE 
#Remoting 
Enable-PSremoting
Enable-PSremoting
Get-Command Enable-PSremoting
Get-Command *-PSremot* | Select Name 
Disable-PSRemoting                                                                                                    
Enable-PSRemoting 

Help Enable-PSremoting  
SYNTAX
Enable-PSRemoting [-Force] [-SkipNetworkProfileCheck] 

#Enable-WSmanCredSSP
Get-Command *-WSmanCredSSP | Select Name 
Disable-WSManCredSSP
Enable-WSManCredSSP
Get-WSManCredSSP 
The machine is not configured to allow delegating fresh credentials. 
This computer is not configured to receive credentials from a remote client computer.

Enable-WSManCredSSP
The machine is not configured to allow delegating fresh credentials. 
This computer is configured to receive credentials from a remote client computer.

Help Enable-WSmanCredSSP 
SYNTAX
Enable-WSManCredSSP [-Role] <string> {Client | Server} [[-DelegateComputer] <string[]>] [-Force]  

Enable-WSManCredSSP -Role Server -Force # | Out-Null
cfg               : http://schemas.microsoft.com/wbem/wsman/1/config/service/auth
lang              : en-US
Basic             : false
Kerberos          : true
Negotiate         : true
Certificate       : false
CredSSP           : true
CbtHardeningLevel : Relaxed

Get-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB


