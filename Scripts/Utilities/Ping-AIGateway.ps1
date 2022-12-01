$IP = (Get-NetIPAddress -InterfaceAlias Ethernet -AddressFamily IPv4).IPAddress
Test-NetConnection -ComputerName ($IP.Replace('.16', '.2')) 