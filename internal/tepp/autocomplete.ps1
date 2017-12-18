Register-PSFTeppScriptblock -Name SqlInstance -ScriptBlock { Get-PSFConfig -Module dbachecks -Name SqlServers  }
Register-PSFTeppScriptblock -Name ComputerName -ScriptBlock { Get-PSFConfig -Module dbachecks -Name WindowsServers }
Register-PSFTeppScriptblock -Name confignames -ScriptBlock { (Get-PSFConfig -Module dbachecks).Name }
Register-PSFTeppArgumentCompleter -Command Get-DbcConfig -Parameter Name -Name confignames