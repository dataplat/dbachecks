function Get-DbcCheck {
	<#
		.SYNOPSIS
			Lists all checks, tags and unique identifiers
	
		.DESCRIPTION
			Lists all checks, tags and unique identifiers
			
		.PARAMETER Pattern
			May be any string, supports wildcards.

		.PARAMETER EnableException
			By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
			This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
			Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.
			
		.EXAMPLE
			Get-DbcCheck
			
			Retrieves all of the available checks

		.EXAMPLE
			Get-DbcCheck backups
			
			Retrieves all of the available tags that match backups
    #>
	[CmdletBinding()]
	param (
		[string]$Pattern,
		[switch]$EnableException
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