$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Write-Host -Object "Running $PSCommandpath" -ForegroundColor Cyan
. "$PSScriptRoot\constants.ps1"

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "Command executes properly and returns proper info" {
        BeforeAll {
            $config = Get-DbcConfig -Name policy.dump.maxcount
        }
        AfterAll {
            $result = Set-DbcConfig -Name policy.dump.maxcount -Value $config.Value
        }
        $result = Set-DbcConfig -Name policy.dump.maxcount -Value ($config.Value + 1)
        It "sets a config" {
            $result.Value | Should -Be ($config.Value + 1)
        }
    }
}