$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Write-Host -Object "Running $PSCommandpath" -ForegroundColor Cyan
. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
	Context "Command executes properly and returns proper info" {
		BeforeAll {
			$results = Get-DbcConfig
			$specific = Get-DbcConfig -Name skip.remotingcheck
		}
		
		It "returns a number of configs" {
			($results).Count -gt 10 | Should Be $true
		}
		
		It "returns a single bool" {
			$specific.Value -eq $true -or $specific.Value -eq $false | Should Be $true
		}
	}
}