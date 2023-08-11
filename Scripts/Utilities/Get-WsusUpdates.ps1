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


# Get a list of updates
$updates = Get-WsusUpdate -Approval AnyExceptDeclined -Status Any -Classification All

# Display the table
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
