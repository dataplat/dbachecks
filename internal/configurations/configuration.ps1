Set-PSFConfig -Module dbachecks -Name SqlServers -Value $null -Initialize -Description "List of SQL Server instances that SQL-based tests will run against"
Set-PSFConfig -Module dbachecks -Name WindowsServers -Value $null -Initialize -Description "List of Windows Servers that Windows-based tests will run against"
Set-PSFConfig -Module dbachecks -Name SqlCredential -Value $null -Initialize -Description "The universal SQL credential if Trusted/Windows Authentication is not used"
Set-PSFConfig -Module dbachecks -Name WinCredential -Value $null -Initialize -Description "The universal Windows if default Windows Authentication is not used"
