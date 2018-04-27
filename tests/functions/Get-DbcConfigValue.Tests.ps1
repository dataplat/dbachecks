$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Write-Host -Object "Running $PSCommandpath" -ForegroundColor Cyan
. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "Command executes properly and returns proper info" {
        BeforeAll {
            $results = Get-DbcConfigValue -Name policy.database.autoclose
        }
        
        It "returns a single bool" {
            $results -eq $true -or $results -eq $false | Should -BeTrue
        }
    }
}