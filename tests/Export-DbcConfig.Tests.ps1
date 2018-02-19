$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Write-Host -Object "Running $PSCommandpath" -ForegroundColor Cyan
. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "Command executes properly and returns proper info" {
        BeforeAll {
            Remove-Item "$script:localapp\config.json" -ErrorAction SilentlyContinue
        }
        AfterAll {
            Remove-Item "$script:localapp\config.json" -ErrorAction SilentlyContinue
        }
        
        Export-DbcConfig *>$null
        
        It "output a file" {
            (Get-ChildItem "$script:localapp\config.json") -ne $null | Should -BeTrue
        }
    }
}