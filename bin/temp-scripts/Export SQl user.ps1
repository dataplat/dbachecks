Get-Help Export-SqlUser -ShowWindow

## Export users from an instance

Export-SqlUser -SqlInstance SQL2016N2 -FilePath C:\temp\SQL2016N2-Users.sql
Notepad C:\temp\SQL2016N2-Users.sql 

## Export users from a database

Export-SqlUser -SqlInstance SQL2016N2 -FilePath C:\temp\SQL2016N2-Fadetoblack.sql -Databases Fadetoblack
notepad C:\temp\SQL2016N2-Fadetoblack.sql   

## Export a single user from a database
Export-SqlUser -SqlInstance SQL2016N2 -FilePath C:\temp\SQL2016N2-Lars-Fadetoblack.sql -User UlrichLars -Databases Fadetoblack
notepad C:\temp\SQL2016N2-Lars-Fadetoblack.sql         

## replace permissions and create a new file
$LarsPermsFile = 'C:\temp\SQL2016N2-Lars-Fadetoblack.sql'
$ManagerPermsFile = 'C:\temp\SQL2016N2-Manager-Fadetoblack.sql'
Export-SqlUser -SqlInstance SQL2016N2 -FilePath $LarsPermsFile -User UlrichLars -Databases Fadetoblack
$ManagerPerms = Get-Content $LarsPermsFile
## replace permissions
$ManagerPerms = $ManagerPerms.Replace('DENY INSERT ON [dbo].[Finances]','GRANT INSERT ON [dbo].[Finances]')
$ManagerPerms = $ManagerPerms.Replace('DENY SELECT ON [dbo].[RealFinances]','GRANT SELECT ON [dbo].[RealFinances]')
$ManagerPerms = $ManagerPerms.Replace('UlrichLars','TheManager')
Set-Content -path $ManagerPermsFile -Value $ManagerPerms
code-insiders $LarsPermsFile , $ManagerPermsFile

## export for a different version
Export-SqlUser -SqlInstance SQL2016N2 -Databases FadetoBlack -User TheManager  -FilePath C:\temp\SQL2016N2-Manager-2000.sql  -DestinationVersion SQLServer2000
Notepad C:\temp\SQL2016N2-Manager-2000.sql 

  Export-SqlUser -SqlInstance SQL2016N2 -FilePath C:\temp\SQL2016N2-Users-2000.sql  -DestinationVersion SQLServer2000
 Notepad C:\temp\SQL2016N2-Users-2000.sql 

 Export-SqlUser -SqlInstance SQL2016N2 -FilePath C:\temp\SQL2016N2-Users-2005.sql  -DestinationVersion SQLServer2005
 Notepad C:\temp\SQL2016N2-Users-2005.sql 

  Export-SqlUser -SqlInstance SQL2016N2 -FilePath C:\temp\SQL2016N2-Users-2008.sql  -DestinationVersion SQLServer2008/2008R2
 Notepad C:\temp\SQL2016N2-Users-2008.sql 

   Export-SqlUser -SqlInstance SQL2016N2 -FilePath C:\temp\SQL2016N2-Users-2012.sql  -DestinationVersion SQLServer2012
 Notepad C:\temp\SQL2016N2-Users-2012.sql 

    Export-SqlUser -SqlInstance SQL2016N2 -FilePath C:\temp\SQL2016N2-Users-2014.sql  -DestinationVersion SQLServer2014
 Notepad C:\temp\SQL2016N2-Users-2014.sql 

    Export-SqlUser -SqlInstance SQL2016N2 -FilePath C:\temp\SQL2016N2-Users-2016.sql  -DestinationVersion SQLServer2016
 Notepad C:\temp\SQL2016N2-Users-2016.sql 