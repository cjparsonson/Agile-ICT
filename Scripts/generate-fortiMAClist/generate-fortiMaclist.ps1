<#
.SYNOPSIS
generate-fortiMAClist takes a list of MAC addresses and generates a Fortigate CLI script.
.DESCRIPTION
Takes a .txt list of MAC addresses and converts them to Fortigate CLI. 
.PARAMETER Path
The filepath of the MAC list .txt or .csv file. 
.EXAMPLE
generate-fortiMAClist -Path .\Devices.csv 
#>

[CmdletBinding()]
param (
    # MAC list Filepath 
    [Parameter(Mandatory=$true, HelpMessage="Please specify filepath of MAC list.")]
    [string]
    $Path 
)

# Get contents of MAC list
$Content = Get-Content -Path $Path
[string]$MACString = [String]::Empty


Write-Output "Processing MAC address list`n"
# Build MAC address string
foreach ($line in $Content) {
    $match = $line | Select-String -Pattern "..:..:..:..:..:.."
    $MAC = $match.Matches.Value
    if ($MAC -ne "")
    {  
        $MACString += "`"$MAC`" "
    } 
        
}
# Trim trailing whitespace

$MACString = $MACString -replace '("")', '' 
$MACString = $MACString.TrimEnd()

# Build script framework object
$ScriptObject = [PSCustomObject]@{
    Header = "config firewall address`n`tedit `"Staff - device - MAC Addresses`""
    Attributes = "`t`tconfig dynamic_mapping`n`t`tedit `"St_Lawrence_CE_Primary_850-3001`"-`"root`"`n`t`tset associated-interface `"any`"`n`t`tunset color"
    MACList = "`t`tset macaddr $MACString"
    Footer = "`tnext"
    Close = "end" 
}

Write-Warning "Building CLI Script`n"
# Display preview
Write-Output $ScriptObject.Header
Write-Output $ScriptObject.Attributes
Write-Output $ScriptObject.MACList
Write-Output $ScriptObject.Footer
Write-Output $ScriptObject.Close

Write-Output "`nPress any key to write to file"
Read-Host

Write-Warning "Writing to file..."
# Write to file
foreach ($property in $ScriptObject.psobject.Properties) {
    $property.value | Out-File -FilePath .\test.txt -Append 
}

Write-Output "Output Fortigate CLI script to file complete"
