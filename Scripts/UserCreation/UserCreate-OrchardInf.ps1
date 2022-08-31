# Script to create users in bulk at Orchard Infant School

# Teacher OU = OU=Curriculum,OU=Staff,OU=Users,OU=School,DC=orchardinf,DC=local 


# Set CSV path
$CSVPath = 'C:\UserCreate\NewStaffUserCSV.csv'

# Load CSV into variable
$UsersFromCSV = Import-Csv $CSVPath
$UsersFromCSV

# Get DomainSuffix then use this to build the User Principal Name 
$DomainSuffix = (Get-CimInstance CIM_Computersystem).Domain
$PrincipalNameSuffix = -join ("@",$DomainSuffix) 

# Set staff homes location
$StaffHomeDir = "\\2230FS01\Staff\"
$ClassesHomeDir = "\\2230fs01\Learners\Classes\"
$LearnersHomeDir = "\\2230fs01\Learners\"


# Iterate Users
foreach ($usr in $UsersFromCSV) {
    Write-Host $usr.OU    
    if ($usr.OU -eq 'Curriculum') {
        $usr.OU = "OU=Curriculum,OU=Staff,OU=Users,OU=School,DC=orchardinf,DC=local"    
    }
    elseif ($usr.OU -match "(?i)^leavers") {
        $LeaversGroup = $usr.OU
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
    
    # Add groups 
    # Staff   
    if ($usr.OU -match '^OU=Curriculum') {
        Add-ADPrincipalGroupMembership -Identity $usr.UserName -MemberOf 'Staff'            
    } 
    # Classes
    if ($usr.OU -match 'OU=Classes') {
        Add-ADPrincipalGroupMembership -Identity $usr.UserName -MemberOf 'Classes'            
    } 
    # Students
    if ($usr.OU -match 'OU=Leavers\d{4}') {
        Add-ADPrincipalGroupMembership -Identity $usr.UserName -MemberOf "$LeaversGroup"
    }      
    # Add home folders and link them     
    # Staff
    if ($usr.OU -match '^OU=Curriculum') {
        $homepath = -join ($StaffHomeDir, $usr.UserName)        
        Set-ADUser -Identity $usr.UserName -HomeDirectory "$homepath\Documents" -HomeDrive Z 
        New-Item -Path $homepath -ItemType Directory
        # Add permissions
        $acl = Get-Acl $homepath
        $adusr = Get-ADUser -Identity $usr.UserName
        $filesystemrights = [System.Security.AccessControl.FileSystemRights]"Modify"
        $accesscontroltype = [System.Security.AccessControl.AccessControlType]::Allow 
        $inheritanceflags = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
        $propagationflags = [System.Security.AccessControl.PropagationFlags]"InheritOnly"
        $accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule ($adusr.SID, $filesystemrights, $inheritanceflags, $propagationflags, $accesscontroltype)
        $acl.SetAccessRule($accessrule)
        
        Set-Acl -Path $homepath -AclObject $acl
    }
    
    # Classes
    if ($usr.OU -match 'OU=Classes') {
        $homepath = -join ($ClassesHomeDir, $usr.UserName)        
        Set-ADUser -Identity $usr.UserName -HomeDirectory "$homepath\Documents" -HomeDrive Z 
        New-Item -Path $homepath -ItemType Directory
        # Add permissions
        $acl = Get-Acl $homepath
        $adusr = Get-ADUser -Identity $usr.UserName
        $filesystemrights = [System.Security.AccessControl.FileSystemRights]"Modify"
        $accesscontroltype = [System.Security.AccessControl.AccessControlType]::Allow 
        $inheritanceflags = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
        $propagationflags = [System.Security.AccessControl.PropagationFlags]"InheritOnly"
        $accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule ($adusr.SID, $filesystemrights, $inheritanceflags, $propagationflags, $accesscontroltype)
        $acl.SetAccessRule($accessrule)
        
        Set-Acl -Path $homepath -AclObject $acl
    }

    #Students 
    if ($usr.OU -match 'OU=Leavers\d{4}') {
        $homepath = -join ($LearnersHomeDir, $LeaversGroup)
        $homepath = -join ($homepath, "\")
        $homepath = -join ($homepath, $usr.UserName)
        Set-ADUser -Identity $usr.UserName -HomeDirectory "$homepath\Documents" -HomeDrive Z 
        New-Item -Path $homepath -ItemType Directory
        # Add permissions
        $acl = Get-Acl $homepath
        $adusr = Get-ADUser -Identity $usr.UserName
        $filesystemrights = [System.Security.AccessControl.FileSystemRights]"Modify"
        $accesscontroltype = [System.Security.AccessControl.AccessControlType]::Allow 
        $inheritanceflags = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
        $propagationflags = [System.Security.AccessControl.PropagationFlags]"InheritOnly"
        $accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule ($adusr.SID, $filesystemrights, $inheritanceflags, $propagationflags, $accesscontroltype)
        $acl.SetAccessRule($accessrule)
        
        Set-Acl -Path $homepath -AclObject $acl
    }
}







