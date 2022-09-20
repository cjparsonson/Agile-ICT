# Assign folders to iterate

$folders = Get-ChildItem -Path "D:\shares\teares" -Recurse -Directory

$folderObjectArray = @()

foreach ($folder in $folders) {
    $folderObject = [PSCustomObject]@{}
    Add-Member -InputObject $folderObject -MemberType NoteProperty -Name "Path" -Value ($folder.FullName)
    Add-Member -InputObject $folderObject -MemberType NoteProperty -Name "Access" -Value (get-acl -Path $folder).Access
    $folderObjectArray += $folderObject
}

Write-Output $folderObject
