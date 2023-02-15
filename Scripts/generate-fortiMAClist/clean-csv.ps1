$content = Get-Content .\generate-fortiMAClist\Devices.csv
$MAClist = @()

foreach ($line in $content) {
    $match = $line | Select-String -Pattern "..:..:..:..:..:.."
    $MAClist += $match.Matches.Value 
}

Write-Output $MAClist

