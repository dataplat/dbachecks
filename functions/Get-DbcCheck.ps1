function Get-DbcCheck {
	<#
		.SYNOPSIS
			Lists all checks, tags and unique identifiers
	
		.DESCRIPTION
			
		.PARAMETER Name
			Default: "*"
			The name of the check to retrieve.
			May be any string, supports wildcards.

		.EXAMPLE
			PS C:\> Get-DbcCheck
			
			Retrieves all of the available checks

		.EXAMPLE
			PS C:\> Get-DbcCheck backups
			
			Retrieves all of the available tags that match backups
    #>
	[CmdletBinding()]
	param (
		[string]$Name = "*"
	)
	
	process {
		Get-Content "$script:localapp\checks.json" | ConvertFrom-Json
	}
}
