# setup
Set-PSFConfig -Module dbachecks -Name setup.sqlinstance -Value $null -Initialize -Description "List of SQL Server instances that SQL-based tests will run against"
Set-PSFConfig -Module dbachecks -Name setup.computername -Value $null -Initialize -Description "List of Windows Servers that Windows-based tests will run against"
Set-PSFConfig -Module dbachecks -Name setup.sqlcredential -Value $null -Initialize -Description "The universal SQL credential if Trusted/Windows Authentication is not used"
Set-PSFConfig -Module dbachecks -Name setup.wincredential -Value $null -Initialize -Description "The universal Windows if default Windows Authentication is not used"
Set-PSFConfig -Module dbachecks -Name setup.backuppath -Value $null -Initialize -Description "Enables tests to check if servers have access to centralized backup location"
Set-PSFConfig -Module dbachecks -Name setup.backuptestserver -Value $null -Initialize -Description "Destination server for backuptests"
Set-PSFConfig -Module dbachecks -Name setup.backupdatadir -Value $null -Initialize -Description "Destination server data directory"
Set-PSFConfig -Module dbachecks -Name setup.backuplogdir -Value $null -Initialize -Description "Destination server log directory"

# skips - these are for whole checks (mytest.Tests.ps1) that should not run by default or internal commands that can't be skipped using ExcludeTag
Set-PSFConfig -Module dbachecks -Name skip.backupdiffcheck -Validation bool -Value $false -Initialize -Description "Skip diff check in backups"
Set-PSFConfig -Module dbachecks -Name skip.datapuritycheck -Validation bool -Value $false -Initialize -Description "Skip data purity check in last good dbcc command"
Set-PSFConfig -Module dbachecks -Name skip.backuptesting -Validation bool -Value $true -Initialize -Description "Don't run Test-DbaLastBackup by default (it's not read-only)"
Set-PSFConfig -Module dbachecks -Name skip.tempdb118 -Validation bool -Value $false -Initialize -Description "Don't run test for Trace Flag 118"
Set-PSFConfig -Module dbachecks -Name skip.tempdbfilegrowthpercent -Validation bool -Value $false -Initialize -Description "Don't run test for Temp Database File Growth in Percent"
Set-PSFConfig -Module dbachecks -Name skip.tempdbfilesonc -Validation bool -Value $false -Initialize -Description "Don't run test for Temp Database Files on C"
Set-PSFConfig -Module dbachecks -Name skip.tempdbfilesizemax -Validation bool -Value $false -Initialize -Description "Don't run test for Temp Database Files Max Size"
Set-PSFConfig -Module dbachecks -Name skip.remotingcheck -Validation bool -Value $false -Initialize -Description "Skip PowerShell remoting"
Set-PSFConfig -Module dbachecks -Name skip.hadr -Validation bool -Value $true -Initialize -Description "Skip the HADR Tests"

# Policy
Set-PSFConfig -Module dbachecks -Name policy.diskspacepercentfree -Validation integer -Value 20 -Initialize -Description "Percent disk free"
Set-PSFConfig -Module dbachecks -Name policy.backupfullmaxdays -Validation integer -Value 1 -Initialize -Description "Maxmimum number of days before Full Backups are considered outdated"
Set-PSFConfig -Module dbachecks -Name policy.backupdiffmaxhours -Validation integer -Value 25 -Initialize -Description "Maxmimum number of hours before Diff Backups are considered outdated"
Set-PSFConfig -Module dbachecks -Name policy.backuplogmaxminutes -Validation integer -Value 15 -Initialize -Description "Maxmimum number of minutes before Log Backups are considered outdated"
Set-PSFConfig -Module dbachecks -Name policy.integritycheckmaxdays -Validation integer -Value 7 -Initialize -Description "Maxmimum number of days before DBCC CHECKDB is considered outdated"
Set-PSFConfig -Module dbachecks -Name policy.identityusagepercent -Validation integer -Value 90 -Initialize -Description "Maxmimum percentage of max of identity column"
Set-PSFConfig -Module dbachecks -Name policy.networklatencymsmax -Validation integer -Value 40 -Initialize -Description "Max network latency average"
Set-PSFConfig -Module dbachecks -Name policy.recoverymodel -Value Full -Initialize -Description "Standard recovery model"
Set-PSFConfig -Module dbachecks -Name policy.dbownershould -Value sa -Initialize -Description "The database owner account should be this user"
Set-PSFConfig -Module dbachecks -Name policy.dbownershouldnot -Value sa -Initialize -Description "The database owner account should not be this user"
Set-PSFConfig -Module dbachecks -Name policy.dacallowed -Validation bool -Value $true -Initialize -Description "Alters the DAC check to say if it should be allowed `$true or disallowed `$false"
Set-PSFConfig -Module dbachecks -Name policy.authscheme -Value "Kerberos" -Initialize -Description "Auth requirement (Kerberos, NTLM, etc)"
Set-PSFConfig -Module dbachecks -Name policy.hadrclustername -Value "ClusterName" -Initialize -Description "The DNS Name of the Cluster(s) to check "
Set-PSFConfig -Module dbachecks -Name policy.hadrfqdn -Value "FQDN" -Initialize -Description "The FQDN for the Cluster Check"
Set-PSFConfig -Module dbachecks -Name policy.hadrtcpport -Value "1433" -Initialize -Description "The TCPPort for the HADR check"

# domain?
Set-PSFConfig -Module dbachecks -Name domain.name -Value $null -Initialize -Description "The Active Directory domain that your server is a part of"
Set-PSFConfig -Module dbachecks -Name domain.organizationalunit -Value $null -Initialize -Description "The OU that your server should be a part of"
Set-PSFConfig -Module dbachecks -Name domain.domaincontroller -Value $null -Initialize -Description "The domain controller to process your requests"

#agent
Set-PSFConfig -Module dbachecks -Name agent.dbaoperatorname -Value $null -Initialize -Description "Name of the DBA Operator in SQL Agent"
Set-PSFConfig -Module dbachecks -Name agent.dbaoperatoremail -Value $null -Initialize -Description "Email address of the DBA Operator in SQL Agent"
Set-PSFConfig -Module dbachecks -Name agent.failsafeoperator -Value $null -Initialize -Description "Email address of the DBA Operator in SQL Agent"

# some configs to help with autocompletes and other module level stuff
Set-PSFConfig -Module dbachecks -Name app.checkrepos -Value "$script:ModuleRoot\checks" -Initialize -Description "Where tests are stored"