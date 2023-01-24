$items = Get-ChildItem -Path 'C:\Users\chris.parsonson.TEAMORANGE\OneDrive - Agile ICT' 
foreach ($item in $items) {
    Write-Output "The lenth of the filename for $item is: " ($item).Length
    
}

