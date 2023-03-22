# Clean Chromebook Mac List

$content = Get-Content .\mac.txt

$mac_list = @()

foreach ($line in $content) 
{
    $match = $line | Select-String -Pattern '(..\-){5}..'
    $MAC = $match.Matches.Value
    if ($MAC)
    {
        $MAC = $MAC.Trim()
        $MAC = $MAC -replace '-', ':'
        $mac_list += $MAC
    } 
}

#$mac_list | Out-File mac_list.txt

$mac_string = ""
foreach ($mac in $mac_list)
{
    $mac_string += " `"$mac`"" 
}
#Write-Output $mac_string

Write-Output "config firewall address" | Out-File script.txt -Append
Write-Output 'edit "Student - device - MAC Addresses"' | Out-File script.txt -Append
Write-Output "set macaddr $mac_string" | Out-File script.txt -Append
Write-Output "end" | Out-File script.txt -Append
