function Get-DbcConfig {
	<#
		.SYNOPSIS
			Retrieves configuration elements by name.
		
		.DESCRIPTION
			Retrieves configuration elements by name.
			Can be used to search the existing configuration list.
	
		.PARAMETER Name
			Default: "*"
			The name of the configuration element(s) to retrieve.
			May be any string, supports wildcards.
		
		.EXAMPLE
			PS C:\> Get-DbcConfig Lists.SqlServers
			
			Retrieves the configuration element for the key "Lists.SqlServers"
    #>
	[CmdletBinding()]
	Param (
		[string]$Name = "*"
	)
	
	begin {
		$Module = "dbachecks"
	}
	process {
		$Name = $Name.ToLower()
		$results = [PSFramework.Configuration.ConfigurationHost]::Configurations.Values | Where-Object { ($_.Name -like $Name) -and ($_.Module -like $Module) -and ((-not $_.Hidden) -or ($Force)) } | Sort-Object Module, Name
		
		if ($Name -in 'setup.sqlinstance', 'setup.computername', 'setup.testrepo') {
			$results | Select-Object Name, @{ Name = "Value"; Expression = { $_.Value -split ',' } }, Description
		}
		else {
			$results | Select-Object Name, Value, Description
		}
	}
}
