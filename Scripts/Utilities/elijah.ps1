# Install the required module if not already installed
if (-not (Get-Module -Name ImportExcel -ErrorAction SilentlyContinue)) {
    Install-Module -Name ImportExcel -Force
}



# Import the required module
Import-Module -Name ImportExcel



# Specify the OU distinguished name (DN) for which you want to retrieve the AD accounts
$ouDN = "OU=Staff,OU=Users,OU=School,DC=SCH7023,DC=hants,DC=sch,DC=uk"



# Define the output Excel file path
$excelFilePath = "C:\AgileICT"



# Retrieve all enabled AD accounts within the specified OU and its sub-OUs
$accounts = Get-ADUser -Filter {Enabled -eq $true} -SearchBase $ouDN -SearchScope Subtree -Properties DisplayName, SamAccountName



# Create an empty array to store the results
$results = @()



# Loop through each account and retrieve the display name and username
foreach ($account in $accounts) {
    $displayName = $account.DisplayName
    $username = $account.SamAccountName



    # Create a custom object with the display name and username
    $result = [PSCustomObject]@{
        "Display Name" = $displayName
        "Username" = $username
    }



    # Add the result to the array
    $results += $result
}



# Export the results to an Excel file
$results | Export-Excel -Path $excelFilePath -AutoSize -NoHeader -FreezeTopRow



# Display a success message
Write-Host "AD account information exported to $excelFilePath."
