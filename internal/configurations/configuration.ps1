# Can't persist yet
Set-PSFConfig -Module dbachecks -Name setup.sqlinstance -Value $null -Initialize -Description "List of SQL Server instances that SQL-based tests will run against"
Set-PSFConfig -Module dbachecks -Name setup.computername -Value $null -Initialize -Description "List of Windows Servers that Windows-based tests will run against"
Set-PSFConfig -Module dbachecks -Name setup.testrepo -Value "$script:ModuleRoot\tests-external" -Initialize -Description "Where tests are stored"

# Persists
Set-PSFConfig -Module dbachecks -Name setup.sqlcredential -Value $null -Initialize -Description "The universal SQL credential if Trusted/Windows Authentication is not used"
Set-PSFConfig -Module dbachecks -Name setup.wincredential -Value $null -Initialize -Description "The universal Windows if default Windows Authentication is not used"
Set-PSFConfig -Module dbachecks -Name policy.diskspacepercentfree -Value 20 -Initialize -Description "Percent disk free"