function Get-DbcConfigValue {
	<#
		.SYNOPSIS
			Retrieves configuration element values by name.
		
		.DESCRIPTION
			Retrieves configuration element values by name.
			
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
	param (
		[string]$Name = "*"
	)
	
	begin {
		$Module = "dbachecks"
	}
	process {
		$Name = $Name.ToLower()
		Get-DbcConfig -Name $name | Select-Object -ExpandProperty Value
	}
}
