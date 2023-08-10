<#
    .SYNOPSIS
    Installs ESET Server Security
    .DESCRIPTION
    This script will install ESET server security on the local machine.
    It will attempt to find the latest MSI from the domain controller.
    Please make sure you have added the MSIs and are using standard paths.
    Please also copy in the config files to the same location as the MSIs.
    .PARAMETER domainController
    The domain controller hostname for path building. Optional.
    .PARAMETER oldPathFormat
    Use the old path format. Bool. Optional.
    .INPUTS
    None
    .OUTPUTS
    None
    .EXAMPLE
    ./Install-ServerSec.ps1
#>

param (
    [Parameter(Mandatory=$false)]
    [string]$domainController,

    [Parameter(Mandatory=$false)]
    [bool]$oldPathFormat=$false
)

# Set static paths
$esetPFPath = "C:\Program Files\ESET\ESET Security\"
$esetPDPath = "C:\ProgramData\ESET\ESET Security\"

# Set URIs
$agentURI = "https://download.eset.com/com/eset/apps/business/era/agent/latest/agent_x64.msi"
$serverURI = "https://download.eset.com/com/eset/apps/business/efs/windows/latest/efsw_nt64.msi"

# Set stubs based on path format
if ($oldPathFormat) {
    Write-Warning "Using old path format"
    $agentStub = "CoreSoftware\ESET\Agent"
    $serverStub = "CoreSoftware\ESET\Server Security"
    $serverStub2 = "CoreSoftware\ESET\Server"
}
else {
    $agentStub = "Core\ESET\Agent"
    $serverStub = "Core\ESET\Server Security"
    $serverStub2 = "Core\ESET\Server"
}



if ($domainController) {
    Write-Output "Domain Controller Parameter Set: $domainController"
}
else {

    # Build up path to MSI
    try {
        $domainController = Get-ADDomainController | Select-Object -ExpandProperty Name
    }
    catch {
        Write-Warning "No domain controller found, attempting to build path"
        $hostname = $env:COMPUTERNAME
        # Get the domain prefix
        $hostname -match '^\d{4}' | Out-Null
        $domainPrefix = $Matches.0
        $domainController = $domainPrefix+"DC01"
    }
}

# Validate
if ($domainController -match '^\d{4}DC\d+') {
    Write-Output "Domain Controller: $domainController"
}
else {
    Write-Warning "Domain Controller not found, exiting"
    exit
}

# Build paths
Write-Warning "Building paths...."
try {
    $agentPath = "\\$domainController\mansoft$\$agentStub"
    if (Test-Path "\\$domainController\mansoft$\$serverStub") {
        $serverPath = "\\$domainController\mansoft$\$serverStub"
    }
    else {
        $serverPath = "\\$domainController\mansoft$\$serverStub2"
    }

}
catch {
    Write-Warning "Failed to build paths, exiting"
    exit
}

Write-Output "Agent path: $agentPath"
Write-Output "Server path: $serverPath"

Write-Warning "Please type Y to download the MSIs or N to skip: "
$choice = Read-Host
if ($choice.ToLower() -eq "y") {
    # Download MSIs and create directories
    Write-Warning "Downloading MSIs...."
    # Agent
    Write-Warning "Downloading agent...."
    $agentDest = "$HOME\Downloads\agent_x64.msi"
    Invoke-WebRequest -Uri $agentURI -OutFile $agentDest

    Write-Warning "Downloading server...."
    # Server
    $serverDest = "$HOME\Downloads\efsw_nt64.msi"
    Invoke-WebRequest -Uri $serverURI -OutFile $serverDest

    # Get location of config
    $configLoc = Get-ChildItem -path $agentPath -Filter *.ini
    $config = $configLoc[0].FullName

    try {
        $WindowsInstaller = New-Object -com WindowsInstaller.Installer
        $Database = $WindowsInstaller.GetType().InvokeMember("OpenDatabase", "InvokeMethod", $Null, $WindowsInstaller, @($agentDest.FullName, 0))
        $Query = "SELECT Value FROM Property WHERE Property = 'ProductVersion'"
        $View = $database.GetType().InvokeMember("OpenView", "InvokeMethod", $Null, $Database, ($Query))
        $View.GetType().InvokeMember("Execute", "InvokeMethod", $Null, $View, $Null) | Out-Null
        $Record = $View.GetType().InvokeMember( "Fetch", "InvokeMethod", $Null, $View, $Null )
        $Version = $Record.GetType().InvokeMember( "StringData", "GetProperty", $Null, $Record, 1 )
        $agentVersion = $Version
        return $Version
    } catch {
        throw "Failed to get MSI file version: {0}." -f $_
    }

    try {
        $WindowsInstaller = New-Object -com WindowsInstaller.Installer
        $Database = $WindowsInstaller.GetType().InvokeMember("OpenDatabase", "InvokeMethod", $Null, $WindowsInstaller, @($serverDest.FullName, 0))
        $Query = "SELECT Value FROM Property WHERE Property = 'ProductVersion'"
        $View = $database.GetType().InvokeMember("OpenView", "InvokeMethod", $Null, $Database, ($Query))
        $View.GetType().InvokeMember("Execute", "InvokeMethod", $Null, $View, $Null) | Out-Null
        $Record = $View.GetType().InvokeMember( "Fetch", "InvokeMethod", $Null, $View, $Null )
        $Version = $Record.GetType().InvokeMember( "StringData", "GetProperty", $Null, $Record, 1 )
        $serverVersion = $Version
        return $Version
    } catch {
        throw "Failed to get MSI file version: {0}." -f $_
    }

    # Create directories
    Write-Warning "Creating directories...."
    # Agent
    $newAgentDir = "$agentPath\$agentVersion"
    New-Item -Path $newAgentDir -ItemType Directory
    Copy-Item -Path $config -Destination $newAgentDir
    Copy-Item -Path $agentDest -Destination $newAgentDir

    # Server
    $newServerDir = "$serverPath\$serverVersion"
    New-Item -Path $newServerDir -ItemType Directory
    Copy-Item -Path $serverDest -Destination $newServerDir


}
# Attempt to find latest MSI
# Agent
try {
    Write-Warning "Searching for latest MSI...."
    $contents = Get-ChildItem -Path $agentPath
    $sorted = $contents | Sort-Object Name
    $latest = $sorted[0]
    $agentMSIpath = $agentPath + "\" + $latest
    $agentMSI = Get-ChildItem -Path $agentMSIpath -Filter *.msi
    Write-Warning "Agent MSI: $agentMSI"
    $agentMSIpathFull = $agentMSIpath + "\" + $agentMSI
    Write-Output "Agent MSI path: $agentMSIpathFull"

    # Server
    Write-Warning "Searching for latest MSI...."
    $contents = Get-ChildItem -Path $serverPath
    $sorted = $contents | Sort-Object Name
    $latest = $sorted[0]
    $serverMSIpath = $serverPath + "\" + $latest
    $serverMSI = Get-ChildItem -Path $serverMSIpath -Filter *.msi
    Write-Warning "Server MSI: $serverMSI"
    $serverMSIpathFull = $serverMSIpath + "\" + $serverMSI
    Write-Output "Server MSI path: $serverMSIpathFull"
}
catch {
    Write-Warning "Failed to find MSI paths, exiting"
    exit
}

# Test for agent config file
Write-Warning "Searching for agent config file...."
if (-not(Test-Path "$agentMSIpath\install_config.ini")) {
    Write-Warning "Agent config file not found, exiting"
    Write-Output "Please copy the config file to the same location as the MSI, then press enter to continue"
    Read-Host
}
else {
    Write-Output "Agent config file found, continuing"
}

# Cleanup old files
Write-Warning "Cleaning up old ESET files...."
if (Test-Path $esetPFPath) {
    Write-Warning "ESET Program Files found, removing...."
    try {
        Remove-Item -Path $esetPFPath -Recurse -Force -ErrorAction SilentlyContinue
    }
    catch {
        Write-Warning "Failed to remove ESET Program Files, exiting"
        exit
    }
}
else {
    Write-Warning "ESET Program Files directory not found, continuing"
}

if (Test-Path $esetPDPath) {
    Write-Warning "ESET Program Data found, removing...."
    try {
        Remove-Item -Path $esetPDPath -Recurse -Force -ErrorAction SilentlyContinue
    }
    catch {
        Write-Warning "Failed to remove ESET Program Data, exiting"
        exit
    }
}
else {
    Write-Warning "ESET Program Data directory not found, continuing"
}

# Install Agent
Write-Warning "Installing ESET Agent...."
try {
    Start-Process -FilePath msiexec.exe -ArgumentList "/i $agentMSIpathFull /qn /norestart" -Wait -PassThru
}
catch {
    Write-Warning "Failed to install ESET Agent, exiting"
    exit
}

# Install Server
Write-Warning "Installing ESET Server Security...."
$arguments = "/i `"$serverMSIpathFull`" /qn /norestart"
try {
    Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments  -Wait -PassThru
}
catch {
    Write-Warning "Failed to install ESET Server, exiting"
    exit
}

Write-Output "ESET Server Security installed successfully"
Write-Output "Please wait 5 minutes for the product to activate"
