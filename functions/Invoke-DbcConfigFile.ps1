function Invoke-DbcConfigFile {
	<#
		.SYNOPSIS
			Invokes the default location of the config file for easy edits
		
		.DESCRIPTION
			Invokes the default location of the config file for easy edits. Follow with Import-DbcConfig to import changes.
	
		.PARAMETER Path
			The path to open, by default is "$script:localapp\config.json"
	
		.EXAMPLE
			Invoke-DbcConfigFile
		
			Opens "$script:localapp\config.json" for editing. Follow with Import-DbcConfig.
    #>
	[CmdletBinding()]
	param (
		[string]$Path = "$script:localapp\config.json"
	)

	process {
		if (-not (Test-Path -Path $Path)) {
			Stop-PSFFunction -Message "$Path does not exist. Run Export-DbcConfig to create a file."
			return
		}
		
		try {
			Invoke-Item -Path $Path
			Write-PSFMessage -Level	Output -Message "Remember to run Import-DbcConfig when you've finished your edits"
		}
		catch {
			Stop-PSFFunction -Message "Failure" -Exception $_
			return
		}
	}
}