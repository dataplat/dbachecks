$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
. "$PSScriptRoot\..\constants.ps1"

Describe "$commandname Unit Tests" -Tags UnitTest {
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