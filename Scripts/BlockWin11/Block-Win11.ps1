#!ps
$wuKey = "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate"
$name  = "WSUS Clients"
#Block Windows 11
#Enable Target Release Version
Set-GPRegistryValue -Name "$name" -Key "$wuKey" -ValueName TargetReleaseVersion -Type DWord -Value 1 #Set Product version
Set-GPRegistryValue -Name "$name" -Key "$wuKey" -ValueName ProductVersion -Type String -Value "Windows 10" #Set Target Version Info
Set-GPRegistryValue -Name "$name" -Key "$wuKey" -ValueName TargetReleaseVersionInfo -Type String -Value 22H2