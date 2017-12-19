# setup
Set-PSFConfig -Module dbachecks -Name setup.sqlinstance -Value $null -Initialize -Description "List of SQL Server instances that SQL-based tests will run against"
Set-PSFConfig -Module dbachecks -Name setup.computername -Value $null -Initialize -Description "List of Windows Servers that Windows-based tests will run against"
Set-PSFConfig -Module dbachecks -Name setup.testrepo -Value "$script:ModuleRoot\tests-external" -Initialize -Description "Where tests are stored"
Set-PSFConfig -Module dbachecks -Name setup.sqlcredential -Value $null -Initialize -Description "The universal SQL credential if Trusted/Windows Authentication is not used"
Set-PSFConfig -Module dbachecks -Name setup.wincredential -Value $null -Initialize -Description "The universal Windows if default Windows Authentication is not used"

# skips
Set-PSFConfig -Module dbachecks -Name skip.backupdiffcheck -Value $false -Initialize -Description "If you don't use diffs in your enviornment, you can skip this"

# Policy
Set-PSFConfig -Module dbachecks -Name policy.diskspacepercentfree -Value 20 -Initialize -Description "Percent disk free"
Set-PSFConfig -Module dbachecks -Name policy.backupfullmaxdays -Value 1 -Initialize -Description "Maxmimum number of days before Full Backups are considered outdated"
Set-PSFConfig -Module dbachecks -Name policy.backupdiffmaxhours -Value 25 -Initialize -Description "Maxmimum number of hours before Diff Backups are considered outdated"
Set-PSFConfig -Module dbachecks -Name policy.backuplogmaxminutes -Value 15 -Initialize -Description "Maxmimum number of minutes before Log Backups are considered outdated"