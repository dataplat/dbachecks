function Import-DbcConfig {
	<#
		.SYNOPSIS
			Imports the Config from a JSON file
		
		.DESCRIPTION
			Imports the Config from a JSON file
	
		.PARAMETER Path
		The path to import from, by default is "$script:localapp\config.json"
	
		.EXAMPLE
			PS C:\> Export-DbcConfig
			
			Exports config to "$script:localapp\config.json"
    #>
	[CmdletBinding()]
	Param (
		[string]$Path = "$script:localapp\config.json"
	)
	process {
		if (-not (Test-Path -Path $path)) {
			Stop-PSFFunction -Message "$path does not exist. Run Export-DbcConfig to create."
		}
		
		try {
			$results = Get-Content -Path $path | ConvertFrom-Json
		}
		catch {
			Stop-PSFFunction -Message "Failure" -Exception $_
		}
		
		foreach ($result in $results) {
			Set-DbcConfig -Name $result.Name -Value $result.Value
		}
		
		$results
	}
}