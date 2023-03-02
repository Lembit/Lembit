#sharepoint
$farm = Get-SPFarm
$farm.BuildVersion

#sql
Invoke-Sqlcmd -Query "SELECT @@VERSION;" -QueryTimeout 3 
sqlcmd -S SP\SQLEXPRESS -E -Q "SELECT @@VERSION" 
