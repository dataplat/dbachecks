function Start-DbcPowerBi {
	<#
		.SYNOPSIS
			Launches the PowerBi Template for dbachecks
		
		.DESCRIPTION
			Launches the PowerBi Template for dbachecks
	
		.PARAMETER Path
		If you've moved it
	
		.EXAMPLE
		PS C:\> Start-DbcPowerBi
		
		Shows PowerBi from "$script:ModuleRoot\bin\dbachecks.pbix"

		.EXAMPLE
		PS C:\> Start-DbcPowerBi -Path \\nas\projects\dbachecks.pbix
		
		Imports config from \\nas\projects\dbachecks.pbix
    #>
	[CmdletBinding()]
	param (
		[string]$Path = "$script:ModuleRoot\bin\dbachecks.pbix"
	)
	process {
		if (-not (Test-Path -Path $Path)) {
			Stop-PSFFunction -Message "$Path does not exist"
			return
		}
		
		if (-not (Test-Path -Path "$env:windir\Temp\dbachecks.json")) {
			Stop-PSFFunction -Message "json file not found. Run New-DbcPowerBiJson to auto generate"
			return
		}
		
		$association = Get-ItemProperty "Registry::HKEY_Classes_root\.pbix"
		
		if (-not $association) {
			Stop-PSFFunction -Message ".pbix not associated with any program. Please (re)install Power BI"
			return
		}
		
		try {
			Invoke-Item -Path "$script:ModuleRoot\bin\dbachecks.pbix"
		}
		catch {
			Stop-PSFFunction -Message "Failure" -Exception $_
			return
		}
	}
}