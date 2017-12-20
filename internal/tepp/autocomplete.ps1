# Register that script block
Register-PSFTeppScriptblock -Name SqlInstance -ScriptBlock { Get-PSFConfig -Module dbachecks -Name SqlInstance  }
Register-PSFTeppScriptblock -Name ComputerName -ScriptBlock { Get-PSFConfig -Module dbachecks -Name ComputerName }
Register-PSFTeppScriptblock -Name confignames -ScriptBlock { (Get-PSFConfig -Module dbachecks).Name }

# Register the actual auto completer
Register-PSFTeppArgumentCompleter -Command Get-DbcConfig -Parameter Name -Name confignames
Register-PSFTeppArgumentCompleter -Command Set-DbcConfig -Parameter Name -Name confignames