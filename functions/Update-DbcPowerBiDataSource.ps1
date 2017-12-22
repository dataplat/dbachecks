function Update-DbcPowerBiDataSource {
	<#
		.SYNOPSIS
			Converts Pester results and exports file in required format for launching the PowerBi command
		
		.DESCRIPTION
			Converts Pester results and exports file in required format for launching the PowerBi command
	
			Basically does this:
				$InputObject.TestResult | Select-Object -First 20 | ConvertTo-Json -Depth 3 | Out-File "$env:windir\temp\dbachecks.json"

		.PARAMETER InputObject
			Required. Resultset from Invoke-DbcCheck. If InputObject is not provided, it will be generated using a very generic resultset:
	
			Invoke-DbcCheck -Show Summary -PassThru
	
		.PARAMETER Path
			The directory to store your JSON files. "C:\windows\temp\dbachecks\*.json" by default
	
		PARAMETER Environment
			Tag your JSON filename with an enviornment
	
		.EXAMPLE
			Invoke-DbcCheck -SqlInstance sql2017 -Tag identity -Show Summary -PassThru | Update-DbcPowerBiDataSource
		
			Runs backup tests against sql2017 then saves to json to "$env:windir\temp\dbachecks\dbachecks_identity.json"
	
		.EXAMPLE
			Invoke-DbcCheck -SqlInstance sql2017 -Tag identity -Show Summary -PassThru | Update-DbcPowerBiDataSource
		
			Runs backup tests against sql2017 then saves to json to "$env:windir\temp\dbachecks\dbachecks_identity.json"

		.EXAMPLE
			Invoke-DbcCheck -SqlInstance sql2017 -Tag Backup -Show Summary -PassThru | Update-DbcPowerBiDataSource -Path \\nas\projects\dbachecks.json
			Start-DbcPowerBi -Path \\nas\projects\dbachecks.json
		
			Runs tests, saves to json to \\nas\projects\dbachecks.json but then you'll have to change your data source in Power BI because by default it points to C:\Windows\Temp (limitation of Power BI)
    #>
	[CmdletBinding()]
	param (
		[parameter(ValueFromPipeline, Mandatory)]
		[pscustomobject]$InputObject,
		[string]$Path = "$env:windir\temp\dbachecks",
		[string]$Enviornment
	)

	process {
		try {
			if (-not (Test-Path -Path $Path)) {
				New-Item -ItemType Directory -Path $Path -ErrorAction Stop
			}
		}
		catch {
			Stop-PSFFunction -Message "Failure" -Exception $_
			return
		}
		
		if (-not $InputObject.TestResult) {
			Stop-PSFFunction -Message "InputObject does not contain a TestResult"
			return
		}
		
		$basename = "dbachecks"
		if ($InputObject.TagFilter) {
			$basename = "$basename`_$($InputObject.TagFilter -join "_")"
		}
		
		if ($Enviornment) {
			$basename = "$basename`_$Enviornment"
		}
		
		$filename = "$Path\$basename.json"
		
		try {
			$InputObject.TestResult | ConvertTo-Json -Depth 3 | Out-File -FilePath $filename
			Write-PSFMessage -Level Output -Message "Wrote results to $filename"
		}
		catch {
			Stop-PSFFunction -Message "Failure" -Exception $_
			return
		}
	}
	end {
		if (-not $InputObject) {
			Stop-PSFFunction -Message "InputObject is null. Did you forget to specify -Passthru for your previous command?"
			return
		}
	}
}