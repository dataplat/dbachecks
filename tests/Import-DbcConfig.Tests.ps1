$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Write-Host -Object "Running $PSCommandpath" -ForegroundColor Cyan
. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "Command executes properly and returns proper info" {
        BeforeAll {
            Export-DbcConfig *>$null
        }
        AfterAll {
            Remove-Item "$script:localapp\config.json" -ErrorAction SilentlyContinue
        }
        
        It "returns a bunch of results" {
            $results = Import-DbcConfig -Path "$script:localapp\config.json"
            ($results).Count -gt 10 | Should -BeTrue
        }
        It "returns some results for app.checkrepos" {
            $results | Where-Object name -eq app.checkrepos | Should Not Be $null
        }
    }
}