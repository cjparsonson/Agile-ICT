# Read users from list
$users = Get-Content -Path "C:\Users\administrator.SCH2260\userlist.txt"
$homepath = "D:\users\homes"
$profilepath = "D:\users\profiles\staff"
# Iterate through list to build exisiting users

$exisiting_users = @()
$nonexistant_users = @()
foreach ($user in $users) {
    try {
        Get-ADUser -Identity $user -ErrorAction Stop
        $exisiting_users += $user
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        $nonexistant_users += $user
    }
}

# Delete AD accounts
foreach ($user in $exisiting_users) {
    Remove-ADUser -Identity $user -Confirm:$false
}

#Delete directories
foreach ($user in $users) {
    $homedir = Get-ChildItem -Path $homepath -Filter $user -Recurse -Depth 3 | Select-Object -ExpandProperty FullName
    try {
        Remove-Item -Path $homedir -Recurse -Force -ErrorAction Stop
    }
    catch {
        Write-Warning $_
    }
}

#Delete profiles
foreach ($user in $users) {
    $profiledir = Get-ChildItem -Path $profilepath -Filter $user -Force | Select-Object -ExpandProperty FullName
    try {
        Remove-Item -Path $profiledir -Recurse -Force -ErrorAction Stop
    }
    catch {
        Write-Warning $_
    }
}
