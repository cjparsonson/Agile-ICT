$deviceObject = [PSCustomObject]@{
    Name = (Get-CimInstance -ClassName CIM_ComputerSystem).Name
    Manufacturer = (Get-CimInstance -ClassName Win32_BIOS).Manufacturer
    Model = (Get-CimInstance -ClassName CIM_ComputerSystem).Model
    Serial = (Get-CimInstance -ClassName Win32_BIOS).SerialNumber
    Location = Read-Host -Prompt "Enter Location: "
}

$deviceObject | Export-Csv test.csv -Append



