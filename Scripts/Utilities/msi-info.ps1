param (
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [System.IO.FileInfo] $MSIPATH
)
if (!(Test-Path $MSIPATH.FullName)) {
    throw "File '{0}' does not exist" -f $MSIPATH.FullName
}
try {
    $WindowsInstaller = New-Object -com WindowsInstaller.Installer
    $Database = $WindowsInstaller.GetType().InvokeMember("OpenDatabase", "InvokeMethod", $Null, $WindowsInstaller, @($MSIPATH.FullName, 0))
    $Query = "SELECT Value FROM Property WHERE Property = 'ProductVersion'"
    $View = $database.GetType().InvokeMember("OpenView", "InvokeMethod", $Null, $Database, ($Query))
    $View.GetType().InvokeMember("Execute", "InvokeMethod", $Null, $View, $Null) | Out-Null
    $Record = $View.GetType().InvokeMember( "Fetch", "InvokeMethod", $Null, $View, $Null )
    $Version = $Record.GetType().InvokeMember( "StringData", "GetProperty", $Null, $Record, 1 )
    return $Version
} catch {
    throw "Failed to get MSI file version: {0}." -f $_
}
