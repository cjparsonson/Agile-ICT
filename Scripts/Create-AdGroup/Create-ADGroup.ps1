$GroupList = Get-Content groups.txt 

foreach ($Group in $GroupList) {
    New-ADGroup -Name $Group -SamAccountName $Group -GroupCategory Security -GroupScope Global -DisplayName $Group 
}
