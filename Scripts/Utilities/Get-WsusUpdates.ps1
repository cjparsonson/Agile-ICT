<#
    .SYNOPSIS
    Gets a list of updates from WSUS
    .DESCRIPTION
    This function will get a list of updates from WSUS and display them in a table.
    Optionally, you can sort the table by NeededCount, Classification, or IsSuperseded.
    .PARAMETER sortBy
    The column to sort by. Optional. Default is NeededCount. Possible values are NeededCount, Classification, IsSuperseded
    .INPUTS
    None
    .OUTPUTS
    None
    .EXAMPLE
    ./Get-WsusUpdates.ps1 -sortBy NeededCount
#>
param(
    [Parameter(Mandatory=$false)]
    [string]$sortBy = "NeededCount" # NeededCount, Classification, IsSuperseded
)

function Get-Updates {
    [CmdletBinding()]
    $updates = Get-WsusUpdate -Approval AnyExceptDeclined -Status Any -Classification All
    return $updates
}


function Show-Updates {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [array]$updates # An array of updates
    )

    # Check if updates were passed in
    if (!$updates) {
        $updates = Get-Updates
    }

    # Construct updates table
    $updatesTable = @()

    foreach ($update in $updates) {
        $superseded = $false
        if ($update.UpdatesSupersedingThisUpdate -ne "None") {
            $superseded = $true
        }
        else {
            $superseded = $false
        }
        $updateObject = [PSCustomObject]@{
            Name = $update.Update.Title
            Classification = $update.Classification
            NeededCount = $update.ComputersNeedingThisUpdate
            IsSuperseded = $superseded
        }
        $updatesTable += $updateObject
    }
    return $updatesTable
}

function Get-FilteredUpdates {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$searchString,
        [Parameter(Mandatory=$false)]
        [array]$updates # An array of updates
    )

    # Check if updates were passed in
    if (!$updates) {
        $updates = Get-Updates
    }
    # Construct filtered updates table
    $filteredUpdatesTable = @()

    foreach ($update in $updates) {
        if (($update.Update.Title | Select-String -Pattern $searchString) -or ($update.Update.Description | Select-String -Pattern $searchString))  {
            $filteredUpdatesTable += $update
        }
    }
    return $filteredUpdatesTable

}

# Get WSUS server
#$wsusServer = Get-WsusServer

# Get updates
$updates = Get-Updates
$updatesTable = Show-Updates -updates $updates

# Sort updates if parameter is passed
if ($sortBy) {
    $sortBy = $sortBy.ToLower()

    switch ($sortBy) {
        "neededcount" { $updatesTable | Sort-Object -Property NeededCount -Descending | Format-Table -AutoSize; break }
        "issuperseded" { $updatesTable | Sort-Object -Property IsSuperseded -Descending | Format-Table -AutoSize ; break }
        "classification" { $updatesTable | Sort-Object -Property Classification | Format-Table -AutoSize ; break }
        Default { $updatesTable | Format-Table -AutoSize }
    }
}
else {
    $updatesTable | Format-Table -AutoSize
}

$loop = $true
while ($loop) {
    $searchString = Read-Host "Enter search string (or q to quit)"
    if ($searchString.ToLower() -eq "q") {
        $loop = $false
    }
    else {
        $filteredUpdatesTable = Get-FilteredUpdates -updates $updates -searchString $searchString
        $toDisplay = @()
        foreach ($update in $filteredUpdatesTable) {
            $superseded = $false
            if ($update.UpdatesSupersedingThisUpdate -ne "None") {
                $superseded = $true
            }
            else {
                $superseded = $false
            }
            $updateObject = [PSCustomObject]@{
                Name = $update.Update.Title
                Classification = $update.Classification
                NeededCount = $update.ComputersNeedingThisUpdate
                IsSuperseded = $superseded
            }
            $toDisplay += $updateObject
        }
        $toDisplay | Format-Table -AutoSize
    }
}
