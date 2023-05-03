$input = Get-Content .\raw.txt

foreach ($line in $input)
{
    $colon_index = @(2, 5, 8, 11, 14)
    foreach ($index in $colon_index)
    {
        $line = $line.Insert($index, ':')
    }
    Write-Output $line
    $line | Out-File -FilePath formatted.txt -Append 
}