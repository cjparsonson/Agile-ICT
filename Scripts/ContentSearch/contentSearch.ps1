# Get the Search Group ID and the location of the CSV input file
$searchGroup = Read-Host 'Search Group ID'
$csvFile = Read-Host 'Source CSV file'

# Do a quick check to make sure our group name will not collide with other searches
$searchCounter = 1
import-csv $csvFile |
  ForEach-Object{

 $searchName = $searchGroup +'_' + $searchCounter
 $search = Get-ComplianceSearch $searchName -EA SilentlyContinue
 if ($search)
 {
    Write-Error "The Search Group ID conflicts with existing searches.  Please choose a search group name and restart the script."
    return
 }
 $searchCounter++
}

$searchCounter = 1
import-csv $csvFile |
  ForEach-Object{

 # Create the query
 $query = $_.ContentMatchQuery
 if(($_.StartDate -or $_.EndDate))
 {
       # Add the appropriate date restrictions.  NOTE: Using the Date condition property here because it works across Exchange, SharePoint, and OneDrive for Business.
       # For Exchange, the Date condition property maps to the Sent and Received dates; for SharePoint and OneDrive for Business, it maps to Created and Modified dates.
       if($query)
       {
           $query += " AND"
       }
       $query += " ("
       if($_.StartDate)
       {
           $query += "Date >= " + $_.StartDate
       }
       if($_.EndDate)
       {
           if($_.StartDate)
           {
               $query += " AND "
           }
           $query += "Date <= " + $_.EndDate
       }
       $query += ")"
 }

  # -ExchangeLocation can't be set to an empty string, set to null if there's no location.
  $exchangeLocation = $null
  if ( $_.ExchangeLocation)
  {
        $exchangeLocation = $_.ExchangeLocation
  }

 # Create and run the search
 $searchName = $searchGroup +'_' + $searchCounter
 Write-Host "Creating and running search: " $searchName -NoNewline
 $search = New-ComplianceSearch -Name $searchName -ExchangeLocation $exchangeLocation -SharePointLocation $_.SharePointLocation -ContentMatchQuery $query

 # Start and wait for each search to complete
 Start-ComplianceSearch $search.Name
 while ((Get-ComplianceSearch $search.Name).Status -ne "Completed")
 {
    Write-Host " ." -NoNewline
    Start-Sleep -s 3
 }
 Write-Host ""

 $searchCounter++
}