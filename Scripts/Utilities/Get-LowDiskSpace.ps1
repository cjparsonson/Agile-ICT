<#
.SYNOPSIS
Get-LowDiskSpace returns drives from one or more computers with less than a given threshold of free disk space.
.DESCRIPTION
Get-LowDiskSpace uses CIM to retrieve the Win32_LogicalDisk instances from one or more computers. It displays
each disks drive letter, free space, total size and % free. This script will only return disks which have
free space less than a given threshold.
.PARAMETER computername
Specify one or more computers. Default: LocalHost
.PARAMETER percentagethreshold
Specify percentage threshold. Default: 5 (5%)
.EXAMPLE
Get-LowDiskSpace -computername SRV01 -percentagethreshold 0.1
#>

[CmdletBinding()]
param (
    $computername = 'LocalHost',
    $percentagethreshold = 5
)


# Convert Percentage threshold
$minpercent = $percentagethreshold / 100

Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $computername -Filter "drivetype=3" |
Where-Object -FilterScript { ($_.FreeSpace / $_.Size) -lt $minpercent } |
Select-Object -Property DeviceID,
    @{label='FreeSpace(GB)';expression={$_.FreeSpace / 1GB -as [int]}},
    @{label='Size(GB)';expression={$_.Size / 1GB -as [int]}},
    @{label='%Free';expression={$_.FreeSpace / $_.Size * 100 -as [int]}}