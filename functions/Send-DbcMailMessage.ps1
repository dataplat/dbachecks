function Send-DbcMailMessage {
	<#
		.SYNOPSIS
			Converts Pester results and emails results
		
		.DESCRIPTION
			Converts Pester results and emails results
	
			Basically does this:
				xyz
	
		.PARAMETER InputObject
			Required. Resultset from Invoke-DbcCheck. If InputObject is not provided, it will be generated using a very generic resultset:
	
			Invoke-DbcCheck -Show Summary -PassThru
	
		.EXAMPLE
			Invoke-DbcCheck -SqlInstance sql2017 -Tag identity -Show Summary -PassThru | Send-DbcMailMessage
		
			Runs backup tests against sql2017 then saves to json to "$env:windir\temp\dbachecks\dbachecks_identity.json"
	
		.EXAMPLE
			Invoke-DbcCheck -SqlInstance sql2017 -Tag identity -Show Summary -PassThru | Send-DbcMailMessage
		
			Runs backup tests against sql2017 then saves to json to "$env:windir\temp\dbachecks\dbachecks_identity.json"

		.EXAMPLE
			Invoke-DbcCheck -SqlInstance sql2017 -Tag Backup -Show Summary -PassThru | Send-DbcMailMessage -Path \\nas\projects\dbachecks.json
			Start-DbcPowerBi -Path \\nas\projects\dbachecks.json
		
			Runs tests, saves to json to \\nas\projects\dbachecks.json but then you'll have to change your data source in Power BI because by default it points to C:\Windows\Temp (limitation of Power BI)
    #>
	[CmdletBinding()]
	param (
		[parameter(ValueFromPipeline, Mandatory)]
		[pscustomobject]$InputObject
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
		
		$path = "$env:windir\temp\dbachecks.mail.json"
		
		# $InputObject.TagFilter
		
		try {
			$InputObject.TestResult | ConvertTo-Json -Depth 3 | Out-File -FilePath $path
			Write-PSFMessage -Level Verbose -Message "Wrote results to $path"
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