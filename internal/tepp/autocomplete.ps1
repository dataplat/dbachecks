# Register that script block
Register-PSFTeppScriptblock -Name SqlInstance -ScriptBlock { Get-PSFConfig -Module dbachecks -Name SqlInstance }
Register-PSFTeppScriptblock -Name ComputerName -ScriptBlock { Get-PSFConfig -Module dbachecks -Name ComputerName }
Register-PSFTeppScriptblock -Name confignames -ScriptBlock { (Get-PSFConfig -Module dbachecks).Name }
Register-PSFTeppScriptblock -Name tags -ScriptBlock { Get-DbcTagCollection }
Register-PSFTeppScriptblock -Name enviornments -ScriptBlock { "Production", "Development", "Test" }
Register-PSFTeppScriptblock -Name policy.datafilegrowthtype -ScriptBlock { "kb", "percent" }

# Register the actual auto completer
Register-PSFTeppArgumentCompleter -Command Update-DbcPowerBiDataSource -Parameter Enviornment -Name enviornments
Register-PSFTeppArgumentCompleter -Command Invoke-DbcCheck -Parameter Check -Name tags
Register-PSFTeppArgumentCompleter -Command Invoke-DbcCheck -Parameter ExcludeCheck  -Name tags
Register-PSFTeppArgumentCompleter -Command Get-DbcConfig -Parameter Name -Name confignames
Register-PSFTeppArgumentCompleter -Command Set-DbcConfig -Parameter Name -Name confignames
Register-PSFTeppArgumentCompleter -Command Get-DbcTagCollection -Parameter Name -Name tags
Register-PSFTeppArgumentCompleter -Command Set-DbcConfig -Parameter Value -Name policy.datafilegrowthtype