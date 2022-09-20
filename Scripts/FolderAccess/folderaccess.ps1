# Assign folders to iterate
$folders = Get-ChildItem -Path "D:\shares\teares" -Recurse -Directory

# Declare array to contain PSCustomObjects
$folderObjectArray = @()

# Iterate folders
foreach ($folder in $folders) {
    # Declare PSCustom Object and add full path as a note property 
    $folderObject = [PSCustomObject]@{}
    Add-Member -InputObject $folderObject -MemberType NoteProperty -Name "Path" -Value ($folder.FullName)
    # Store IdentityReferences for ACL as variable
    $access = (Get-Acl -Path $folder.FullName).Access | Select-Object -ExpandProperty IdentityReference
    # Declare array which we will use to store ACL references as an array of strings
    $access_array = @()
    foreach ($line in $access) {
        $access_array += $line.ToString()        
    }
    # Add access note property, concatenating array of strings as one string
    Add-Member -InputObject $folderObject -MemberType NoteProperty -Name "Access" -Value ($access_array -join ",") 
    # Add object to array of objects
    $folderObjectArray += $folderObject
}

$folderObjectArray | Export-Csv -Path "FolderAccess.csv"
