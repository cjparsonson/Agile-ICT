<#
.SYNOPSIS
Get-DiskSpace retrives disk information from one or more computers.
.DESCRIPTION
Get-DiskSpace uses CIM to retrieve the Win32_LogicalDisk instances from one or more computers. It displays
each disks drive letter, free space, total size and % free.
.PARAMETER ComputerName
The computer name, or names, to query. Default: LocalHost
.PARAMETER DriveType
The drive type to query. See Win32_LogicalDisk documentation for values.
3 is a fixed disk. Default: 3
.EXAMPLE
Get-DiskSpace -ComputerName SRV01 -DriveType 3
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true,HelpMessage="Enter a computer name to query")]
    [string]$ComputerName,

    [ValidateSet(2,3,4)]
    [int]$DriveType = 3
)

Write-Verbose "Querying $ComputerName"
Write-Verbose "Looking for Drive Type $DriveType"
Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $ComputerName `
 -Filter "drivetype=$DriveType" |
 Sort-Object -Property DeviceID |
Select-Object -Property DeviceID,
    @{label='FreeSpace(MB)';expression={$_.FreeSpace / 1MB -as [int]}},
    @{label='Size(GB)';expression={$_.Size / 1GB -as [int]}},
    @{label='%Free';expression={$_.FreeSpace / $_.Size * 100 -as [int]}}
Write-Verbose "Finished"