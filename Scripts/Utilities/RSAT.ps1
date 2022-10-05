# Script to install RSAT

#Set Windows Update Server Key to 0
Set-ItemProperty -Path HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name UseWUServer -Value 0

#Restart Windows Update Service
Restart-Service -Name wuauserv -Force

#Get RSAT Tools
Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online

#Set Windows Update Server Key to 1
Set-ItemProperty -Path HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name UseWUServer -Value 1

#Restart Windows Update Service
Restart-Service -Name wuauserv -Force 
#Done
