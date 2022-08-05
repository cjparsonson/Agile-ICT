# Script to create users in bulk at Orchard Infant School

# Teacher OU = OU=Curriculum,OU=Staff,OU=Users,OU=School,DC=orchardinf,DC=local 


# Set CSV path
$CSVPath = 'C:\Users\chris.parsonson\OneDrive - Agile ICT\Documents\Agile-ICT\Scripts\UserCreation\NewStaffUserCSV.csv'

# Load CSV into variable
$UsersFromCSV = Import-Csv $CSVPath
$UsersFromCSV

# Get DomainSuffix then use this to build the User Principal Name 
$DomainSuffix = (Get-CimInstance CIM_Computersystem).Domain
$PrincipalNameSuffix = -join ("@",$DomainSuffix) 

# Iterate Users
foreach ($usr in $UsersFromCSV) {
    Write-Host $usr.OU
    if ($usr.OU -eq 'Curriculum') {
        $usr.OU = "OU=Curriculum,OU=Staff,OU=Users,OU=School,DC=orchardinf,DC=local"    
    }
    elseif ($usr.OU -match "(?i)^leavers") {
        $usrOU = $usr.OU
        $usr.OU = "OU=$usrOU,OU=Learners,OU=Users,OU=School,DC=orchardinf,DC=local"
    }
    elseif ($usr.OU -match "^Y\S") {
        $usrOU = $usr.OU
        $usr.OU = "OU=$usrOU,OU=Classes,OU=Learners,OU=Users,OU=School,DC=orchardinf,DC=local"
    }
    Write-Host $usr.OU
    $UserFullname = (($usr.FirstName, $usr.LastName -join " "))
    $UserPrincipalName = -join ($usr.UserName,$PrincipalNameSuffix)
    New-ADUser -Path $usr.OU -Name $UserFullname -Surname $usr.LastName -SamAccountName $usr.UserName `
        -AccountPassword ($usr.Password | ConvertTo-SecureString -AsPlainText -Force) `
        -ChangePasswordAtLogon $true -Description $usr.Description -DisplayName $UserFullname -Enabled $true `
        -UserPrincipalName $UserPrincipalName   

}







