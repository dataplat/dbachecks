function Import-DbcConfig {
	<#
		.SYNOPSIS
			Imports the Config from a JSON file
		
		.DESCRIPTION
			Imports the Config from a JSON file
	
		.PARAMETER Path
			The path to import from, by default is "$script:localapp\config.json"
	
		.EXAMPLE
			PS C:\> Import-DbcConfig
		
			Imports config from "$script:localapp\config.json"

		.EXAMPLE
			PS C:\> Import-DbcConfig -Path \\nas\projects\config.json
		
			Imports config from \\nas\projects\config.json
    #>
	[CmdletBinding()]
	param (
		[string]$Path = "$script:localapp\config.json"
	)

	process {
		if (-not (Test-Path -Path $Path)) {
			Stop-PSFFunction -Message "$Path does not exist. Run Export-DbcConfig to create."
			return
		}
		
		try {
			$results = Get-Content -Path $Path | ConvertFrom-Json
		}
		catch {
			Stop-PSFFunction -Message "Failure" -Exception $_
			return
		}
		
		foreach ($result in $results) {
			Set-DbcConfig -Name $result.Name -Value $result.Value
		}
		
		$results
	}
}