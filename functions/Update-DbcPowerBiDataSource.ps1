function Update-DbcPowerBiDataSource {
	<#
		.SYNOPSIS
		Runs default tests and exports file in required format for launching the PowerBi command
		
		.DESCRIPTION
		Runs default tests and exports file in required format for launching the PowerBi command
	
		Basically does this:
			$InputObject = Invoke-DbcCheck -Show Summary -PassThru
			$InputObject.TestResult | Select-Object -First 20 | ConvertTo-Json -Depth 5 | Out-File "$env:windir\temp\dbachecks.json"

		.PARAMETER InputObject
		Resultset from Invoke-DbcCheck. If InputObject is not provided, it will be generated using a very generic resultset:
	
		Invoke-DbcCheck -Show Summary -PassThru
	
		.PARAMETER Path
		Where to store your JSON files. "$env:windir\temp\dbachecks.json" by default
	
		.EXAMPLE
		PS C:\> Update-DbcPowerBiDataSource
		
		Runs default tests, saves to json to "$env:windir\temp\dbachecks.json"
	
		.EXAMPLE
		PS C:\> Invoke-DbcCheck -SqlInstance sql2017 -Tag Backup -Show Summary -PassThru | Update-DbcPowerBiDataSource
		
		Runs backup tests against sql2017 then saves to json to "$env:windir\temp\dbachecks.json"

		.EXAMPLE
		PS C:\> Invoke-DbcCheck -SqlInstance sql2017 -Tag Backup -Show Summary -PassThru | Update-DbcPowerBiDataSource -Path \\nas\projects\dbachecks.json
		PS C:\> Start-DbcPowerBi -Path \\nas\projects\dbachecks.json
		
		Runs tests, saves to json to \\nas\projects\dbachecks.json
    #>
	[CmdletBinding()]
	param (
		[parameter(ValueFromPipeline)]
		[object]$InputObject,
		[string]$Path = "$env:windir\temp\dbachecks.json"
	)
	process {
		
		
		try {
			if (-not $InputObject) {
				$InputObject = Invoke-DbcCheck -Show Summary -PassThru
			}
			$InputObject.TestResult | ConvertTo-Json -Depth 5 | Out-File -FilePath $Path
		}
		catch {
			Stop-PSFFunction -Message "Failure" -Exception $_
			return
		}
	}
}