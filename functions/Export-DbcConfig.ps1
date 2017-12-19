function Export-DbcConfig {
	<#
		.SYNOPSIS
			Exports the Config to a JSON file to make it easier to modify
		
		.DESCRIPTION
			Exports the Config to a JSON file to make it easier to modify
	
		.EXAMPLE
			PS C:\> Export-DbcConfig
			
			Exports config to "$script:localapp\config.json"
    #>
	[CmdletBinding()]
	Param ()
	Get-DbcConfig | Select-Object * | ConvertTo-Json -Depth 10 | Out-File -FilePath "$script:localapp\config.json"
}