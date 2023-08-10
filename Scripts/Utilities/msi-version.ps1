param (
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [System.IO.FileInfo] $MSIPATH
)
if (!(Test-Path $MSIPATH.FullName)) {
    throw "File '{0}' does not exist" -f $MSIPATH.FullName
}


# Load windows installer COM object
$installer = New-Object -ComObject WindowsInstaller.Installer

# Open MSI database
$database = $installer.OpenDatabase("$msiPath", 0)
$query = "SELECT `Value` FROM `Property` WHERE `Property` = 'ProductVersion'"
$view = $database.OpenView($query)
$view.Execute()
$record = $view.Fetch()
$version = $record.StringData(1)
Write-Output "MSI version: $version"
return $version

# Release COM objects
$record.Close()
$view.Close()
$database.Close()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($installer) | Out-Null
