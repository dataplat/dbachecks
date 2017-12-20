function New-DbcPowerBiJson {
	<#
		.SYNOPSIS
		Runs default tests and exports file in required format for launching the PowerBi command
		
		.DESCRIPTION
		Runs default tests and exports file in required format for launching the PowerBi command
	
		Basically does this:
			$results = Invoke-DbcCheck -Show Summary -PassThru
			$results.TestResult | Select-Object -First 20 | ConvertTo-Json -Depth 5 | Out-File "$env:windir\temp\dbachecks.json"

		.PARAMETER Path
		If you've moved it. "$env:windir\temp\dbachecks.json" by default
	
		.EXAMPLE
		PS C:\> New-DbcPowerBiJson
		
		Runs tests, saves to json to "$env:windir\temp\dbachecks.json"

		.EXAMPLE
		PS C:\> New-DbcPowerBiJson -Path \\nas\projects\dbachecks.json
		
		Runs tests, saves to json to \\nas\projects\dbachecks.json
    #>
	[CmdletBinding()]
	param (
		[string]$Path = "$env:windir\temp\dbachecks.json"
	)
	process {
		
		
		try {
			$results = Invoke-DbcCheck -Show Summary -PassThru
			$results.TestResult | ConvertTo-Json -Depth 5 | Out-File -FilePath $Path
		}
		catch {
			Stop-PSFFunction -Message "Failure" -Exception $_
			return
		}
	}
}