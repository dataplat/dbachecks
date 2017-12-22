function Get-DbcCheck {
	<#
		.SYNOPSIS
			Lists all checks, tags and unique identifiers
	
		.DESCRIPTION
			
		.PARAMETER Pattern
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
		[string]$Pattern
	)
	
	process {
		
		if (Test-PSFParameterBinding -ParameterName Pattern) {
			foreach ($result in (Get-Content "$script:localapp\checks.json" | ConvertFrom-Json)) {
				$result | Where-Object {
					$_.Group -match $Pattern -or $_.Description -match $Pattern -or
					$_.UniqueTag -match $Pattern -or $_.AllTags -match $Pattern
				}
			}
		}
		else {
			Get-Content "$script:localapp\checks.json" | ConvertFrom-Json
		}
	}
}