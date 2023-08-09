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
    .INPUTS
    None
    .OUTPUTS
    None
    .EXAMPLE
    ./Install-ServerSec.ps1
#>

param (
    [Parameter(Mandatory=$false)]
    [string]$domainController
)

# Set static paths
$esetPFPath = "C:\Program Files\ESET\ESET Security\"
$esetPDPath = "C:\ProgramData\ESET\ESET Security\"
$agentStub = "Core\ESET\Agent"
$serverStub = "Core\ESET\Server Security"
$serverStub2 = "Core\ESET\Server"


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
