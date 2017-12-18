Set-PSFConfig -Module dbachecks -Name sqlinstance -Value $null -Initialize -Description "List of SQL Server instances that SQL-based tests will run against"
Set-PSFConfig -Module dbachecks -Name computername -Value $null -Initialize -Description "List of Windows Servers that Windows-based tests will run against"
Set-PSFConfig -Module dbachecks -Name sqlcredential -Value $null -Initialize -Description "The universal SQL credential if Trusted/Windows Authentication is not used"
Set-PSFConfig -Module dbachecks -Name wincredential -Value $null -Initialize -Description "The universal Windows if default Windows Authentication is not used"
