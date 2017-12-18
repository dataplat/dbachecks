function Set-DbcConfig {
<#
	.SYNOPSIS
		Sets configuration entries.
	
	.DESCRIPTION
		This function creates or changes configuration values.
		These can be used to provide dynamic configuration information outside the PowerShell variable system.
	
	.PARAMETER Name
		Name of the configuration entry.
	
	.PARAMETER Value
		The value to assign to the named configuration element.
	
	.PARAMETER Handler
		A scriptblock that is executed when a value is being set.
		Is only executed if the validation was successful (assuming there was a validation, of course)
	
	.PARAMETER EnableException
		Replaces user friendly yellow warnings with bloody red exceptions of doom!
		Use this if you want the function to throw terminating errors you want to catch.

	.EXAMPLE
		PS C:\> Set-DbcConfig -Name Lists.SqlServers -Value sql2016, sql2017, sqlcluster
		
		Resets the lists.sqlservers entry to sql2016, sql2017, sqlcluster
	
	.EXAMPLE
		PS C:\> Set-DbcConfig -Name Lists.SqlServers -Value sql2016, sql2017, sqlcluster -Append
		
		Addds on to the current lists.sqlservers entry with sql2016, sql2017, sqlcluster
#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
	[CmdletBinding(DefaultParameterSetName = "FullName")]
	Param (
		[string]$Name,
		[AllowNull()]
		[AllowEmptyCollection()]
		[AllowEmptyString()]$Value,
		[System.Management.Automation.ScriptBlock]$Handler,
		[switch]$Append,
		[switch]$EnableException
	)
	process {
		if ($append) {
			$Value = (Get-DbcConfigValue -Name $Name), $Value
		}
		
		$name = $name.ToLower()
		Set-PSFConfig -Module dbachecks -Name $name -Value $Value
		Register-PSFConfig -FullName dbachecks.$name -WarningAction SilentlyContinue
		
		# Still unsure if I'll persist it here - wondering if this impacts global or keeps local
		if ($name -eq 'sqlcredential') {
			Set-Variable -Scope 1 -Name PSDefaultParameterValues -Value @{ '*:SqlCredential' = $value }
		}
	}
}