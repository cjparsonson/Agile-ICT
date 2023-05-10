$DNS = Get-DnsClientServerAddress -AddressFamily "IPv4" | Where-Object { $_.InterfaceAlias -like "*ethernet*" }
$Primary = $DNS.ServerAddresses[0]
$Secondary = "185.207.68.26"

Set-DnsClientServerAddress -InterfaceIndex ($DNS.InterfaceIndex) -ServerAddresses ($Primary, $Secondary)
