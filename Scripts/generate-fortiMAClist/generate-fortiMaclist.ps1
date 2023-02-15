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

# Build MAC address string
foreach ($MAC in $MAClist) {
    $MACString += "`"$MAC`" "
}

# Build script framework object
$ScriptObject = [PSCustomObject]@{
    Header = "config firewall address`n`tedit `"Staff - device - MAC Addresses`""
    Attributes = "`t`tunset color"
    MACList = "`t`tset macaddr $MACString"
    Footer = "`tnext"
    Close = "end" 
}


Write-Output $ScriptObject.Header
Write-Output $ScriptObject.Attributes
Write-Output $ScriptObject.MACList
Write-Output $ScriptObject.Footer
Write-Output $ScriptObject.Close



