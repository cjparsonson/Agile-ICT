<#
.SYNOPSIS
generate-fortiMAClist takes a list of MAC addresses and generates a Fortigate CLI script.
.DESCRIPTION
Takes a .txt list of MAC addresses and converts them to Fortigate CLI. 
.PARAMETER Path
The filepath of the MAC list .txt file. 
.EXAMPLE
generate-fortiMAClist -Path .\testLIST.txt 
#>

[CmdletBinding()]
param (
    # MAC list Filepath 
    [Parameter(Mandatory=$true, HelpMessage="Please specify filepath of MAC list.")]
    [string]
    $Path
)

# Get contents of MAC list
$MAClist = Get-Content -Path $Path
$MACString = ""


Write-Output "Processing MAC address list`n"
# Build MAC address string
foreach ($MAC in $MAClist) {
    $MACString += "`"$MAC`" "
}
# Trim trailing whitespace
$MACString = $MACString.TrimEnd()

# Build script framework object
$ScriptObject = [PSCustomObject]@{
    Header = "config firewall address`n`tedit `"Staff - device - MAC Addresses`""
    Attributes = "`t`tunset color"
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
