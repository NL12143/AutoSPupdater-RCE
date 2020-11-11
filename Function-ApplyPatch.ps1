
#region Install-Updates
function InstallUpdatesFromPatchPath
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()]
        [string]$patchPath,
        [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()]
        [string]$spVer
    )
    $spVer,$spYear = Get-SPYear

    # Result codes below are from http://technet.microsoft.com/en-us/library/cc179058(v=office.14).aspx
    $oPatchInstallResultCodes = @{"17301" = "Error: General Detection error";
                                  "17302" = "Error: Applying patch";
                                  "17303" = "Error: Extracting file";
                                  "17021" = "Error: Creating temp folder";
                                  "17022" = "Success: Reboot flag set";
                                  "17023" = "Error: User cancelled installation";
                                  "17024" = "Error: Creating folder failed";
                                  "17025" = "Patch already installed";
                                  "17026" = "Patch already installed to admin installation";
                                  "17027" = "Installation source requires full file update";
                                  "17028" = "No product installed for contained patch";
                                  "17029" = "Patch failed to install";
                                  "17030" = "Detection: Invalid CIF format";
                                  "17031" = "Detection: Invalid baseline";
                                  "17034" = "Error: Required patch does not apply to the machine";
                                  "17038" = "You do not have sufficient privileges to complete this installation for all users of the machine. Log on as administrator and then retry this installation";
                                  "17044" = "Installer was unable to run detection for this package"}

    # Get all CUs and PUs
    Write-Host -ForegroundColor White " - Looking for SharePoint updates to install in $patchPath..."
    $updatesToInstall = Get-ChildItem -Path "$patchPath" -Include office2010*.exe,ubersrv*.exe,ubersts*.exe,*pjsrv*.exe,sharepointsp2013*.exe,coreserver201*.exe,sts201*.exe,wssloc201*.exe,svrproofloc201*.exe,oserver*.exe,wac*.exe,oslpksp*.exe -Recurse -ErrorAction SilentlyContinue | Sort-Object -Descending
    $updatesToInstall
    
    # Look for Server Update installers
    if ($updatesToInstall)
    {
        Write-Host -ForegroundColor White " - Starting local install..."

        # Now attempt to install any other CUs found in the \Updates folder
        Write-Host -ForegroundColor White "  - Installing SharePoint Updates on " -NoNewline
        Write-Host -ForegroundColor Black -BackgroundColor Green "$env:COMPUTERNAME"
        ForEach ($updateToInstall in $updatesToInstall)
        {
            $splitUpdate = Split-Path -Path $updateToInstall -Leaf # Get the file name only 
            Write-Verbose -Message "Running `"Start-Process -FilePath `"$updateToInstall`" -ArgumentList `"/passive /norestart`" -LoadUserProfile`""
            Write-Host -ForegroundColor Cyan "   - Installing $splitUpdate from `"$($updateToInstall.Directory.Name)`"..." -NoNewline
            $startTime = Get-Date
  
            Start-Process -FilePath "$updateToInstall" -ArgumentList "/passive /norestart" -LoadUserProfile
            Show-Progress -Process $($splitUpdate -replace ".exe", "") -Color Cyan -Interval 5
            $delta,$null = (New-TimeSpan -Start $startTime -End (Get-Date)).ToString() -split "\."
            $oPatchInstallLog = Get-ChildItem -Path (Get-Item $env:TEMP).FullName | Where-Object {$_.Name -like "opatchinstall*.log"} | Sort-Object -Descending -Property "LastWriteTime" | Select-Object -first 1

            # Get install result from log
            $oPatchInstallResultMessage = $oPatchInstallLog | Select-String -SimpleMatch -Pattern "OPatchInstall: Property 'SYS.PROC.RESULT' value" | Select-Object -Last 1
            If (!($oPatchInstallResultMessage -like "*value '0'*")) # Anything other than 0 means unsuccessful but that's not necessarily a bad thing
            {
                $null,$oPatchInstallResultCode = $oPatchInstallResultMessage.Line -split "OPatchInstall: Property 'SYS.PROC.RESULT' value '"
                $oPatchInstallResultCode = $oPatchInstallResultCode.TrimEnd("'")
                # OPatchInstall: Property 'SYS.PROC.RESULT' value '17028' means the patch was not needed or installed product was newer
                if ($oPatchInstallResultCode -eq "17028") {Write-Host -ForegroundColor Yellow "   - Patch not required; installed product is same or newer."}
                elseif ($oPatchInstallResultCode -eq "17031")
                {
                    Write-Warning "Error 17031: Detection: Invalid baseline"
                    Write-Warning "A baseline patch (e.g. March 2013 PU for SP2013, SP1 for SP2010) is missing!"
                    Write-Host -ForegroundColor Yellow "   - Either slipstream the missing patch first, or include the patch package in the ..\$spYear\Updates folder."
                    Pause "continue"
                }
                else
                {
                    Write-Host -ForegroundColor Yellow "   - $($oPatchInstallResultCodes.$oPatchInstallResultCode)"
                    if ($oPatchInstallResultCode -ne "17025") # i.e. "Patch already installed"
                    {
                        Write-Host -ForegroundColor Yellow "   - Please log on to this server ($env:COMPUTERNAME) now, and install the update manually."
                        Pause "continue once the update has been successfully installed manually" "y"
                    }
                }
            }
            Write-Host -ForegroundColor White "   - $splitUpdate install completed in $delta."
        }
        Write-Host -ForegroundColor White "  - Update installation complete."
    }
    Write-Host -ForegroundColor White " - Finished installing SharePoint updates on " -NoNewline
    Write-Host -ForegroundColor Black -BackgroundColor Green "$env:COMPUTERNAME"
    WriteLine
}
#endregion
