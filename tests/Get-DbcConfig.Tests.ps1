$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Write-Host -Object "Running $PSCommandpath" -ForegroundColor Cyan
. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "Command executes properly and returns proper info" {
        BeforeAll {
            $results = Get-DbcConfig
            $specific = Get-DbcConfig -Name policy.database.autoclose
        }
        
        It "returns a number of configs" {
            ($results).Count -gt 10 | Should -BeTrue
        }
        
        It "returns a single bool" {
            $specific.Value -eq $true -or $specific.Value -eq $false | Should -BeTrue
        }
    }
}