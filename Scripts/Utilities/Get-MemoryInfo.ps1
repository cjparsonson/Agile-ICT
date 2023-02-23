$memory_obj = Get-CimInstance -ClassName CIM_PhysicalMemory 
$memory_array = @()

foreach ($obj in $memory_obj) {
    Write-Output "New Memory Object"
    Write-Output $obj
    $memory_info = [PSCustomObject]@{
        Name = $obj.Tag
        Capacity = "$($obj.Capacity / 1GB)GB"
        Speed = $obj.Speed
        Type = switch ($obj.MemoryType) {
            0 { "DDR4" }
            Default { "Unknown" }
        }
    }
    $memory_array += $memory_info

}

$memory_array | Format-Table