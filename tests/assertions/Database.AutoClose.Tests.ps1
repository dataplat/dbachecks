. "$PSScriptRoot/../../assertions/Database.AutoClose.ps1"

Describe "Testing Auto Close Assertion" -Tags AutoClose {
    Mock Get-DbcConfigValue { return "True" } -ParameterFilter { $Name -like "policy.database.autoclose" }

    Context "Test config value conversion" {
        It "'True' string is $true" {
            Mock Get-DbcConfigValue { return "True" } -ParameterFilter { $Name -like "policy.database.autoclose" }
            (Get-SettingsForAutoCloseCheck).AutoClose | Should -BeTrue
        }

        It "'1' string is $true" {
            Mock Get-DbcConfigValue { return "1" } -ParameterFilter { $Name -like "policy.database.autoclose" }
            (Get-SettingsForAutoCloseCheck).AutoClose | Should -BeTrue
        }

        It "'on' string is $true" {
            Mock Get-DbcConfigValue { return "On" } -ParameterFilter { $Name -like "policy.database.autoclose" }
            (Get-SettingsForAutoCloseCheck).AutoClose | Should -BeTrue
        }

        It "'yes' string is $true" {
            Mock Get-DbcConfigValue { return "yes" } -ParameterFilter { $Name -like "policy.database.autoclose" }
            (Get-SettingsForAutoCloseCheck).AutoClose | Should -BeTrue
        }

        It "'False' string is $true" {
            Mock Get-DbcConfigValue { return "False" } -ParameterFilter { $Name -like "policy.database.autoclose" }
            (Get-SettingsForAutoCloseCheck).AutoClose | Should -BeFalse
        }

        It "'0' string is $true" {
            Mock Get-DbcConfigValue { return "0" } -ParameterFilter { $Name -like "policy.database.autoclose" }
            (Get-SettingsForAutoCloseCheck).AutoClose | Should -BeFalse
        }

        It "'off' string is $true" {
            Mock Get-DbcConfigValue { return "off" } -ParameterFilter { $Name -like "policy.database.autoclose" }
            (Get-SettingsForAutoCloseCheck).AutoClose | Should -BeFalse
        }

        It "'no' string is $true" {
            Mock Get-DbcConfigValue { return "no" } -ParameterFilter { $Name -like "policy.database.autoclose" }
            (Get-SettingsForAutoCloseCheck).AutoClose | Should -BeFalse
        }

        It "policy.database.autoclose set to random string should thow an exception" {
            Mock Get-DbcConfigValue { return "somerandomvalue" } -ParameterFilter { $Name -like "policy.database.autoclose" }
            { Get-SettingsForAutoCloseCheck } | Should -Throw
        }
    }

    Context "Tests with expected Auto Close set to true" {
        Mock Get-DbcConfigValue { return "True" } -ParameterFilter { $Name -like "policy.database.autoclose" }

        $testSettings = Get-SettingsForAutoCloseCheck 

        It "The test should pass when the database's auto close is set to true" {
            @{
                AutoClose = $true
            } | 
            Assert-AutoClose -With $testSettings
        }

        It "The test should fail when the database's auto close is set to false" {
            {
                @{
                    AutoClose = $false 
                } | 
                Assert-AutoClose -With $testSettings
            } | Should -Throw 
        }
    }

    Context "Tests with expected Auto Close set to false" {
        Mock Get-DbcConfigValue { return "False" } -ParameterFilter { $Name -like "policy.database.autoclose" }

        $testSettings = Get-SettingsForAutoCloseCheck 

        It "The test should pass when the database's auto close is set to true" {
            @{
                AutoClose = $false 
            } | 
            Assert-AutoClose -With $testSettings
        }

        It "The test should fail when the database's auto close is set to false" {
            {
                @{
                    AutoClose = $true
                } | 
                Assert-AutoClose -With $testSettings
            } | Should -Throw 
        }
    }
}
