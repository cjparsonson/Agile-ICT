# Import reservations from csv then add

Import-Csv -Path .\reservations.csv | Add-DhcpServerv4Reservation

