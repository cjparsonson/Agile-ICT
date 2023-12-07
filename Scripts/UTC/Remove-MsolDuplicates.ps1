$content = Import-Csv .\syncErrors.csv

$succeeded = @()
$failed = @()

#Iterate through each line of the CSV file
foreach ($obj in $content)
{
    $GUID = $obj.ObjectGuid
    $name = $obj.DisplayName
    try {
        Remove-MsolGroup -ObjectId $GUID -Force
        $succeeded += $name
    }
    catch {
        Write-Host "Error removing group $name"
        $failed += $name
    }
}

Write-Host "Succeeded: $($succeeded.Count)"
Write-Host "Failed: $($failed.Count)"
foreach ($fail in $failed)
{
    Write-Host $fail.Name
}
