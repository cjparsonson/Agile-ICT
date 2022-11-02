<#
.SYNOPSIS
Get-Physical adapter retrieves network adapter information.
.DESCRIPTION
Get-Physical adapter retrieves Name, MAC, Device Type, ID, NetConnection ID and Speed information from the win32_NetworkAdapter class.
.PARAMETER ComputerName
The computer name, or names, to query. Alias - hostname.
.EXAMPLE
Get-PhysicalAdapter -ComputerName Server01
#>

[CmdletBinding()]
param (
    # Computername with alias hostname
    [Parameter(Mandatory=$true, HelpMessage="Enter a hostname to query")]
    [Alias('hostname')]
    [String]
    $ComputerName = "localhost"
)
Write-Verbose "Querying hosname $ComputerName"
Write-Verbose "Querying adapters"
Get-CimInstance win32_networkadapter -ComputerName $ComputerName |
where { $_.PhysicalAdapter } |
select MACAddress,AdapterType,DeviceID,Name,Speed,NetConnectionID
Write-Verbose "Finished"
