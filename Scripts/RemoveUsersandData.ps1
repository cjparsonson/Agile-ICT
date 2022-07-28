## Remove User Abbotswood quick script

# Set student home and profile directories

$Student_Homes = "D:\users\homes\students"
$Student_Profiles = "D:\users\profiles\students"

# Student input .txt file
$student_list = "C:\Users\administrator.SCH5202\removeStudents.txt"

#Set Student OU location in a variable
$studentOU = Get-ADOrganizationalUnit -Filter * | Where-Object -FilterScript {$_.Name -like 'Students'}

# Create list of Student objects
$studentObj = foreach ($student in $student_list) {
    Get-ADUser -SearchBase $StudentOU -Filter 'Name -like $student'
}


# Loop through students list and remove students
foreach ($student in $studentObj) {
    # Extract OU (Cohort Year) from Distinguished Name using positive lookbehind
    $OU = Select-String -InputObject $student -Pattern "(?<=OU=)\d{4}" | Select-Object -ExpandProperty Matches
    # Build Home and Profile paths
    $Home_Root = Join-Path -Path $Student_Homes -ChildPath $OU.Value
    $Profile_Root = Join-Path - Path $Student_Profiles -ChildPath $OU.Value
    $Home_Location = Join-Path -Path $Home_Root -ChildPath $student.SamAccountName
    $Profile_Location = Join-Path -Path $Profile_Root -ChildPath $student.SamAccountName
    
    Remove-ADUser -Identity $student -Confirm:$false -ErrorAction SilentlyContinue 
    Remove-Item -Path $Home_Location -Recurse -Force -ErrorAction SilentlyContinue 
    Remove-Item -Path $Profile_Location -Recurse -Force -ErrorAction SilentlyContinue
}


