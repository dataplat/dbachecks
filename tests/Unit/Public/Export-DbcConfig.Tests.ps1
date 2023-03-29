
Describe "Export-DbcConfig Unit Tests" -Tags "IntegrationTests" {
    Context "Command executes properly and returns proper info" {
        BeforeAll {
            $localapp = Get-DbcConfigValue -Name 'app.localapp'
            Remove-Item "$localapp\config.json" -ErrorAction SilentlyContinue
            Export-DbcConfig -Path 'TestDrive:\config.json'
        }
        AfterAll {
            Remove-Item "$localapp\config.json" -ErrorAction SilentlyContinue
        }
        It "Should not throw" {
            { Export-DbcConfig } | Should -Not -Throw
        }

        It "outputs default file without errors" {
            (Get-ChildItem "$localapp\config.json" -ErrorAction SilentlyContinue) -ne $null | Should -BeTrue
        }

        It "outputs a named file without errors" {
            Test-Path 'TestDrive:\config.json' | Should -BeTrue
        }

        It "outputs an object" {
            $o = Export-DbcConfig -Force
            $o | Get-Member -Name Open | Should -Not -BeNullOrEmpty
        }
    }
}