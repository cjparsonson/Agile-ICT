$newPassword = ([securestring]::new()) 

# Enter distinguished name of OU
$OU =  

$Users = Get-ADUser -SearchBase $OU -Filter *
foreach ($User in $Users) {

    # If the following doesn't work then uncomment the line below
    #Set-ADAccountPassword -Identity $User -NewPassword $newPassword
    Set-ADUser -Identity $User -PasswordNotRequired $True
    }
