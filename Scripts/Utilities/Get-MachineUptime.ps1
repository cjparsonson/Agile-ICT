function Get-MachineUptime {
    param (
        $computernames = "localhost"
    )
    try {

        foreach ($computer in $computernames) {
            Write-Output $computer
            if ($computer -eq "localhost") {
                Get-Uptime
            }

            else {
                Invoke-Command -ComputerName $computer -ScriptBlock {Get-Uptime} -ErrorAction Stop
            }
        }
    }
        
    catch {
        Write-Error $_
    }
    
}

Get-MachineUptime -computernames localhost