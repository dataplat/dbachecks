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
            $results = Import-DbcConfig -Path "$script:localapp\config.json" -WarningAction SilentlyContinue -WarningVariable warns 3>$null
            ($results).Count -gt 10 | Should -BeTrue
        }
        It -Skip "returns some results for app.checkrepos" { #skip till I get the syntax right
            ($results | Where-Object name -eq app.checkrepos) -ne $null | Should -BeTrue
        }
    }
}