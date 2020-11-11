
Get-SPyear
$spVer,$spYear = Get-SPYear
$spVer 
Get-SPyear

function Get-SPYear
{
    $spYears = @{"14" = "2010"; "15" = "2013"; "16" = "2016"} # Can't use this hashtable to map SharePoint 2019 versions because it uses version 16 as well
    $farm = Get-SPFarm -ErrorAction SilentlyContinue
    [string]$spVer = $farm.BuildVersion.Major
    [string]$spBuild = $farm.BuildVersion.Build
    if (!$spVer -or !$spBuild)
    {
        Start-Sleep 10
        throw "Could not determine version of farm."
    }
    $spYear = $spYears.$spVer
    # Accomodate SharePoint 2019 (uses the same major version number, but 5-digit build numbers)
    if ($spBuild.Length -eq 5)
    {
        $spYear = "2019"
    }
    return $spVer, $spYear
}
