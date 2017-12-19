Get-Help Test-DbaLastBackup -ShowWindow

#one SQL Server but want to ensure that you are testing your backup files then as along as you have the diskspace you can simply run
Test-DbaLastBackup -SqlServer $ServerPath

## Test backups on a different server
Test-DbaLastBackup -SqlServer '' -Destination ''| OGV

## Limit the size of the databases that are tested and put results to a file

Test-DbaLastBackup -SqlServer ''-Destination '' -MaxMB 5 | Out-File C:\temp\Test-Restore.txt
notepad C:\temp\Test-Restore.txt

## to csv

Test-DbaLastBackup -SqlServer '' -Destination '' -MaxMB 5 | Export-Csv  C:\temp\Test-Restore.csv -NoTypeInformation

## to json

Test-DbaLastBackup -SqlServer '' -Destination ''| ConvertTo-Json | Out-file c:\temp\test-results.json

## to HTML

$Results = Test-DbaLastBackup -SqlServer '' -Destination ''
$Results | ConvertTo-Html | Out-File c:\temp\test-results.html

## TO a colour coded excel 

Import-Module dbatools
 
$TestServer = ''
$Server = ''
## Run the test and save to a variable
$Results = Test-DbaLastBackup -SqlServer $server -Destination $TestServer
# Set the filename
$TestDate = Get-Date
$Date = Get-Date -Format ddMMyyy_HHmmss
$filename = 'C:\Temp\TestResults_' + $Date + '.xlsx'
# Create a .com object for Excel
$xl = new-object -comobject excel.application
$xl.Visible = $true # Set this to False when you run in production
$wb = $xl.Workbooks.Add() # Add a workbook
$ws = $wb.Worksheets.Item(1) # Add a worksheet
$cells=$ws.Cells
$col = 1
$row = 3
## Create a legenc
$cells.item($row,$col)="Legend"
$cells.item($row,$col).font.size=16
$Cells.item($row,$col).Columnwidth = 10
$Cells.item($row,$col).Interior.ColorIndex = 34
$row ++
$cells.item($row,$col)="True or Success"
$cells.item($row,$col).font.size=12
$Cells.item($row,$col).Columnwidth = 10
$Cells.item($row,$col).Interior.ColorIndex = 10
$row ++
$cells.item($row,$col)="False or Failed"
$cells.item($row,$col).font.size=12
$Cells.item($row,$col).Columnwidth = 10
$Cells.item($row,$col).Interior.ColorIndex= 3
$row ++
$cells.item($row,$col)="Skipped"
$cells.item($row,$col).font.size=12
$Cells.item($row,$col).Columnwidth = 10
$Cells.item($row,$col).Interior.ColorIndex= 16
$row ++
$cells.item($row,$col)="Backup Under 7 days old"
$cells.item($row,$col).font.size=12
$Cells.item($row,$col).Columnwidth = 10
$Cells.item($row,$col).Interior.ColorIndex= 4
$row ++
$cells.item($row,$col)="Backup Over 7 days old"
$cells.item($row,$col).font.size=12
$Cells.item($row,$col).Columnwidth = 10
$Cells.item($row,$col).Interior.ColorIndex= 3
## Create a header
$col ++
$row = 3
$cells.item($row,$col)="Source Server"
$cells.item($row,$col).font.size=16
$Cells.item($row,$col).Columnwidth = 10
$Cells.item($row,$col).Interior.ColorIndex= 34
$col ++
$cells.item($row,$col)="Test Server"
$cells.item($row,$col).font.size=16
$Cells.item($row,$col).Columnwidth = 10
$Cells.item($row,$col).Interior.ColorIndex= 34
$col ++
$cells.item($row,$col)="Database"
$cells.item($row,$col).font.size=16
$Cells.item($row,$col).Columnwidth = 10
$Cells.item($row,$col).Interior.ColorIndex= 34
$col ++
$cells.item($row,$col)="File Exists"
$cells.item($row,$col).font.size=16
$Cells.item($row,$col).Columnwidth = 10
$Cells.item($row,$col).Interior.ColorIndex= 34
$col ++
$cells.item($row,$col)="Restore Result"
$cells.item($row,$col).font.size=16
$Cells.item($row,$col).Columnwidth = 10
$Cells.item($row,$col).Interior.ColorIndex= 34
$col ++
$cells.item($row,$col)="DBCC Result"
$cells.item($row,$col).font.size=16
$Cells.item($row,$col).Columnwidth = 10
$Cells.item($row,$col).Interior.ColorIndex= 34
$col ++
$cells.item($row,$col)="Size Mb"
$cells.item($row,$col).font.size=16
$Cells.item($row,$col).Columnwidth = 10
$Cells.item($row,$col).Interior.ColorIndex= 34
$col ++
$cells.item($row,$col)="Backup Date"
$cells.item($row,$col).font.size=16
$Cells.item($row,$col).Columnwidth = 10
$Cells.item($row,$col).Interior.ColorIndex= 34
$col ++
$cells.item($row,$col)="Backup Files"
$cells.item($row,$col).font.size=16
$Cells.item($row,$col).Columnwidth = 10
$Cells.item($row,$col).Interior.ColorIndex= 34
$col = 2
$row = 4
foreach($result in $results)
{
$col = 2
$cells.item($row,$col)=$Result.SourceServer
$cells.item($row,$col).font.size=12
$Cells.item($row,$col).Columnwidth = 10
$col ++
$cells.item($row,$col)=$Result.TestServer
$cells.item($row,$col).font.size=12
$Cells.item($row,$col).Columnwidth = 10
$col++
$cells.item($row,$col)=$Result.Database
$cells.item($row,$col).font.size=12
$Cells.item($row,$col).Columnwidth = 10
$col++
$cells.item($row,$col)=$Result.FileExists
$cells.item($row,$col).font.size=12
$Cells.item($row,$col).Columnwidth = 10
if($result.FileExists -eq 'True')
{
    $Cells.item($row,$col).Interior.ColorIndex= 10
}
elseif($result.FileExists -eq 'False')
{
    $Cells.item($row,$col).Interior.ColorIndex= 3
}
else
{
    $Cells.item($row,$col).Interior.ColorIndex= 16
}
$col++
$cells.item($row,$col)=$Result.RestoreResult
$cells.item($row,$col).font.size=12
$Cells.item($row,$col).Columnwidth = 10
if($result.RestoreResult -eq 'Success')
{
    $Cells.item($row,$col).Interior.ColorIndex= 10
}
elseif($result.RestoreResult -eq 'Failed')
{
    $Cells.item($row,$col).Interior.ColorIndex= 3
}
else
{
    $Cells.item($row,$col).Interior.ColorIndex= 16
}
$col++
$cells.item($row,$col)=$Result.DBCCResult
$cells.item($row,$col).font.size=12
$Cells.item($row,$col).Columnwidth = 10
if($result.DBCCResult -eq 'Success')
{
    $Cells.item($row,$col).Interior.ColorIndex= 10
}
elseif($result.DBCCResult -eq 'Failed')
{
    $Cells.item($row,$col).Interior.ColorIndex= 3
}
else
{
    $Cells.item($row,$col).Interior.ColorIndex= 16
}
$col++
$cells.item($row,$col)=$Result.SizeMb
$cells.item($row,$col).font.size=12
$Cells.item($row,$col).Columnwidth = 10
$col++
$cells.item($row,$col)=$Result.BackupTaken
$cells.item($row,$col).font.size=12
$Cells.item($row,$col).Columnwidth = 10
if($result.BackupTaken -gt (Get-Date).AddDays(-7))
{
    $Cells.item($row,$col).Interior.ColorIndex= 4
}
else
{
    $Cells.item($row,$col).Interior.ColorIndex= 3
}
$col++
$cells.item($row,$col)=$Result.BackupFiles
$cells.item($row,$col).font.size=12
$Cells.item($row,$col).Columnwidth = 10
$row++
}
[void]$ws.cells.entireColumn.Autofit()
## Add the title after the autofit
$col = 2
$row = 1
$cells.item($row,$col)="This report shows the results of the test backups performed on $TestServer for $Server on $TestDate"
$cells.item($row,$col).font.size=18
$Cells.item($row,$col).Columnwidth = 10
$wb.Saveas($filename)
$xl.quit()

## Email the results

Import-Module dbatools
$TestServer = ''
$Server = 'SQL2016N2'
## Run the test and save to a variable
$Results = Test-DbaLastBackup -SqlServer $server -Destination $TestServer -MaxMB 5
$to = ''
$smtp = 'smtp.gmail.com'
$port = 587
$cred = Get-Credential
$from = 'Beard@TheBeard.Local'
$subject = 'The Beard Reports on Backup Testing'
$Body = $Results | Format-Table | Out-String
Send-MailMessage -To $to -From $from -Body $Body -Subject $subject -SmtpServer $smtp -Priority High -UseSsl -Port $port -Credential $cred

## Add to database

<# Create table
USE [TestResults]
GO
CREATE TABLE [dbo].[backuptest](
[SourceServer] [nvarchar](250) NULL,
[TestServer] [nvarchar](250) NULL,
[Database] [nvarchar](250) NULL,
[FileExists] [nvarchar](10) NULL,
[RestoreResult] [nvarchar](200) NULL,
[DBCCResult] [nvarchar](200) NULL,
[SizeMB] [int] NULL,
[Backuptaken] [datetime] NULL,
[BackupFiles] [nvarchar](300) NULL
) ON [PRIMARY]
GO 
#>

Import-Module dbatools
$TestServer = ''
$Server = ''
$servers = '','','','',''
## Run the test for each server and save to a variable (This uses PowerShell v4 or above code)
$Results = $servers.ForEach{Test-DbaLastBackup -SqlServer $_ -Destination $TestServer -MaxMB 5}
## Convert to a daatatable.
$DataTable = Out-DbaDataTable -InputObject $Results
## Write to the database
Write-DbaDataTable -SqlServer $Server -Database TestResults -Schema dbo -Table backuptest -KeepNulls -InputObject $DataTable