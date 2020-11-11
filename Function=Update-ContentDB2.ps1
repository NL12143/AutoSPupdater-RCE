
$spVer, $useSqlSnapshot 

 $contentDatabases = Get-SPDatabase | Where-Object {$null -ne $_.WebApplication} | Sort-Object Name
#$contentDatabases = Get-SPContentDatabase

Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
$upgradeContentDBScriptBlock = 
    {
    $contentDatabases = Get-SPDatabase | Where-Object {$null -ne $_.WebApplication} | Sort-Object Name
    foreach ($contentDatabase in $contentDatabases) {
        $contentDatabase | Upgrade-SPContentDatabase -Confirm:$false @UseSnapshotParameter
    } 
#EndScriptblock 

Start-Job -Name "UpgradeContentDBJob" -ScriptBlock $upgradeContentDBScriptBlock | Receive-Job -Wait

============================================================================ 

Function Update-ContentDatabases
{
    [CmdletBinding()]
    param
    (
        [string]$spVer,
        [Switch]$useSqlSnapshot = $false
    )
    $upgradeContentDBScriptBlock = 
    {
        ##$Host.UI.RawUI.WindowTitle = "-- Upgrading Content Databases --"
        ##$Host.UI.RawUI.BackgroundColor = "Black"
        # Only allow use of SQL snapshots when updating content databases 
        # if we are on SP2013 or earlier, as there is no benefit with SP2016+ per 
        # https://blog.stefan-gossner.com/2016/04/29/sharepoint-2016-zero-downtime-patching-demystified/
        if ($useSqlSnapshot -and $spVer -le "15")
        {
            $UseSnapshotParameter = @{UseSnapshot = $true}
        }
        else
        {
            $UseSnapshotParameter = @{}
            Write-Verbose -Message " - Not using SQL snapshots to upgrade content databases, `
            either because useSQLSnapshot not specified or the SharePoint farm is 2016 or newer."
        }

        Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue

        # Updated to include all content databases, including ones that are "stopped"
        [array]$contentDatabases = Get-SPDatabase | Where-Object {$null -ne $_.WebApplication} | Sort-Object Name
        Write-Host -ForegroundColor White " - Upgrading SharePoint content databases:"
        foreach ($contentDatabase in $contentDatabases)
        {
            Write-Host -ForegroundColor White "  - $($contentDatabase.Name) ($($contentDatabases.IndexOf($contentDatabase)+1) of $($contentDatabases.Count))..."
            $contentDatabase | Upgrade-SPContentDatabase -Confirm:$false @UseSnapshotParameter
            Write-Host -ForegroundColor White "  - Done upgrading $($contentDatabase.Name)."
        }
    } #EndScriptblock 

    #region update content databases prior PSconfig 
    # Kick off a separate PowerShell process to update content databases prior to running PSConfig
    Write-Host -ForegroundColor White " - Upgrading content databases in a separate process..."

    # Some special accomodations for older OSes and PowerShell versions
    if (((Get-CimInstance -ClassName Win32_OperatingSystem).Version -like "6.1*" -or (Get-CimInstance -ClassName Win32_OperatingSystem).Version -like "6.2*" -or (Get-CimInstance -ClassName Win32_OperatingSystem).Version -like "6.3*") -and ($spVer -eq "14"))
    {
        $upgradeContentDBJob = Start-Job -Name "UpgradeContentDBJob" -ScriptBlock $upgradeContentDBScriptBlock
        Write-Host -ForegroundColor Cyan " - Waiting for content databases to finish upgrading..." -NoNewline
        While ($upgradeContentDBJob.State -eq "Running")
        {
            # Wait for job to complete
            Write-Host -ForegroundColor Cyan "." -NoNewline
            Start-Sleep -Seconds 1
        }
        Write-Host -ForegroundColor Green "$($upgradeContentDBJob.State)."
    }
    else
    {
    Start-Job -Name "UpgradeContentDBJob" -ScriptBlock $upgradeContentDBScriptBlock | Receive-Job -Wait
    }
    Write-Host -ForegroundColor White " - Done upgrading databases."
    #endregion update content databases prior PSconfig 
}


