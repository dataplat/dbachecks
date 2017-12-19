## create share

$FileShareParams=@{
 Name='SQLBackups'
 Description='The Place for SQL Backups'
 SourceVolume=(Get-Volume-DriveLetterD)
 FileServerFriendlyName='$BackupServer'
 }
New-FileShare @FileShareParams

## everyone permissions

$FileSharePermsParams=@{
 Name = 'SQLBackups'
 AccessRight = 'Modify'
 AccountName = 'Everyone'}
Grant-FileShareAccess @FileSharePermsParams

## revoke everyone

Revoke-FileShareAccess Name SQLBackups AccountName 'Everyone'

## perms for sql service accounts

$FileSharePermsParams = @{
Name = 'SQLBackups'
AccessRight = 'Modify'
AccountName = 'SQL_DBEngine_Service_Accounts'
}
Grant-FileShareAccess @FileSharePermsParams

## Deny DBA team

$BlockFileShareParams = @{
Name = 'SQLBackups'
AccountName = 'SQL_DBAs_The_Cool_Ones'
}
Block-FileShareAccess @BlockFileShareParams

Get-Help Test-DBASqlPath -Full

## Test one instance
Test-DBaSqlPath -SqlServer sql2016n1 -Path \\BackupServer\SQLBackups

## check numerous instances

$SQLServers = (Get-VM -ComputerName $HyperVServer).Where{$_.Name -like '*SQL*'}.Name
foreach($Server in $SQLServers)
{
$Test = Test-dbaSqlPath -SqlServer $Server -Path '\\BackupServer\SQLBackups'
    [PSCustomObject]@{
    Server = $Server
    Result = $Test
    }
}

