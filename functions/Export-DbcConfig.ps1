function Export-DbcConfig {
	<#
		.SYNOPSIS
			Exports the Config to a JSON file to make it easier to modify
		
		.DESCRIPTION
			Exports the Config to a JSON file to make it easier to modify
	
		.PARAMETER Path
			The path to export to, by default is "$script:localapp\config.json"
	
		.EXAMPLE
			Export-DbcConfig
			
			Exports config to "$script:localapp\config.json"
	
		.EXAMPLE
			Export-DbcConfig -Path \\nfs\projects\config.json
			
			Exports config to \\nfs\projects\config.json
    #>
	[CmdletBinding()]
	param (
		[string]$Path = "$script:localapp\config.json"
	)
	
	Get-DbcConfig | Select-Object * | ConvertTo-Json -Depth 10 | Out-File -FilePath $Path
	Write-PSFMessage -Message "Wrote file to $Path" -Level Output
}