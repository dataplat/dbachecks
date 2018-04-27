$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Write-Host -Object "Running $PSCommandpath" -ForegroundColor Cyan
. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "Command executes properly and returns proper info" {
        BeforeAll {
            Remove-Item "$script:localapp\config.json" -ErrorAction SilentlyContinue
        }
        
        It "returns a warning" {
            Invoke-DbcConfigFile -Path "$script:localapp\config.json" -WarningAction SilentlyContinue -WarningVariable warning *>$null
            $warning | Should not be $null
        }
    }
}