Get-Help Get-DbaDatabaseFreespace -ShowWindow

# details for a single instance
$server = ''
Get-DbaDatabaseFreespace -sqlserver $server

# For a number of instances
$SQLServers == '',''
Get-DbaDatabaseFreespace -SqlInstance $SQLServers | Out-GridView

## Get the total size of a database

$server = ''
$dbName = ''
$database = @{Name = 'Database'; Expression = {$dbname}}
$FileSize = @{Name = 'FileSize'; Expression = {$_.Sum}}
Get-DbaDatabaseFreespace -SqlServer $server -database $dbName |
Select Database,FileSizeMB |
Measure-Object FileSizeMB -Sum |
Select $database ,Property, $filesize

## Total Size of all databases on an instance

$server = ''
$srv = Connect-DbaSqlServer $server
$SizeonDisk = @()
$srv.Databases |ForEach-Object {
$dbName = $_.Name
$database = @{Name = 'Database'; Expression = {$dbname}}
$FileSize = @{Name = 'FileSize'; Expression = {$_.Sum}}
$SizeOnDisk += Get-DbaDatabaseFreespace -SqlServer $server -database $dbName | Select Database,FileSizeMB |  Measure-Object FileSizeMb -Sum | Select $database ,Property, $Filesize
}
$SizeOnDisk

## Sort the sizes

$SizeOnDisk |Sort-Object Filesize -Descending

## Do things with thte results

## In a text file
$SizeonDisk | Out-file C:\temp\Sizeondisk.txt
Invoke-Item C:\temp\Sizeondisk.txt
## In a CSV
$SizeonDisk | Export-Csv C:\temp\Sizeondisk.csv -NoTypeInformation
notepad C:\temp\Sizeondisk.csv
## Email
Send-MailMessage -SmtpServer $smtp -From DBATeam@TheBeard.local -To JuniorDBA-Smurf@TheBeard.Local `
-Subject "Smurf this needs looking At" -Body $SizeonDisk
## Email as Attachment
Send-MailMessage -SmtpServer $smtp -From DBATeam@TheBeard.local -To JuniorDBA-Smurf@TheBeard.Local `
-Subject "Smurf this needs looking At" -Body "Smurf" -Attachments C:\temp\Sizeondisk.csv

## Only those 80% + full

Get-DbaDatabaseFreespace -SqlServer $server | Where-Object {$_.PercentUsed -gt 80}

## File growth settings

Get-DbaDatabaseFreespace -SqlServer $server | Where-Object {$_.AutoGrowType  -ne 'Mb'}

## Get FileSize, Used and Free Space per database
$server = ''
$srv = Connect-DbaSqlServer $server
$SizeonDisk = @()
$srv.Databases |ForEach-Object {
$dbName = $_.Name
$database = @{Name = 'Database'; Expression = {$dbname}}
$MB = @{Name = 'Mbs'; Expression = {$_.Sum}}
$SizeOnDisk += Get-DbaDatabaseFreespace -SqlServer $server -database $dbName | Select Database,FileSizeMB, UsedSpaceMB, FreeSpaceMb |  Measure-Object FileSizeMb , UsedSpaceMB, FreeSpaceMb -Sum  | Select $database ,Property, $Mb
}
$SizeOnDisk

