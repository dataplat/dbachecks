docker run -p 52001:1433 dbatools/sqlinstance2 
docker run -p 52000:1433 -v sqlserver:/var/opt/sqlserver  -d dbatools/sqlinstance --name mssql1
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=dbatools.IO" -p 52002:1433 --name mssql3 --hostname mssql3 -v sqlserver:/var/opt/sqlserver -d  mcr.microsoft.com/mssql/server:2022-latest

# thank you Andrew

docker exec -u 0 mssql1  bash -c "chown mssql /var/opt/sqlserver"
docker exec -u 0 mssql3  bash -c "chown mssql /var/opt/sqlserver"
  
$mssql1cred = Get-Credential
$mssql2cred = Get-Credential
$mssql3cred = Get-Credential

$sql1 = Connect-DbaInstance -SqlInstance 'localhost,52000' -SqlCredential $mssql2cred
$sql2 = Connect-DbaInstance -SqlInstance 'localhost,52001' -SqlCredential $mssql2cred
$sql3 = Connect-DbaInstance -SqlInstance 'localhost,52002' -SqlCredential $mssql3cred

Get-DbaLogin -SqlInstance $sql1,$sql2,$sql3  | ft
Get-DbaDatabase -SqlInstance $sql1,$sql2,$sql3  | ft
Get-DbaAgentJob -SqlInstance $sql1,$sql2,$sql3  | ft
Get-DbaDbCertificate -SqlInstance $sql1,$sql2,$sql3  | ft
  
docker run -p 52000:1433 -v sqlserver:/var/opt/sqlserver  -d dbatools/sqlinstance --name mssql1
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=dbatools.IO" -p 52002:1433 --name mssql3 --hostname mssql3 -v sqlserver:/var/opt/sqlserver -d  mcr.microsoft.com/mssql/server:2022-latest

Backup-DbaDatabase -SqlInstance $sql1 -BackupDirectory /var/opt/sqlserver -Type Full 

Start-DbaMigration -Source $sql1 -Destination $sql3 -UseLastBackup 