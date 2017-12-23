$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Write-Host -Object "Running $PSCommandpath" -ForegroundColor Cyan
. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
	Context "Command executes properly and returns proper info" {
		It -Skip "runs a check" {
			$results = Invoke-DbcCheck -ComputerName localhost -Tag DiskCapacity -Passthru
			$results.TestResult | Should Not Be $null # Because nothing else works right now
		}
	}
}