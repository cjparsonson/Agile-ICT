[System.Net.Dns]::GetHostName()
[System.Net.Dns]::GetHostAddresses(($env:COMPUTERNAME)) | Where-Object { $_.AddressFamily -eq "InterNetwork"} | Select-Object IPAddressToString
