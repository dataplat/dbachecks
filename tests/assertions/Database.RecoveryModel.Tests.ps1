. "$PSScriptRoot/../../assertions/Database.RecoveryModel.ps1"

Describe "Testing Recovery Model Assertion" -Tags RecoveryModel {
    Context "Test configuration" {
        $cases = @(
            @{ Option = "FULL" },
            @{ Option = "SIMPLE" }
        )

        It "<Option> is acceptable as policy.recoverymodel.type value" -TestCases $cases {
            param($Option) 
            Mock Get-DbcConfigValue { return $Option } -ParameterFilter { $Name -like "policy.recoverymodel.type" }
            (Get-SettingsForRecoveryModelCheck).RecoveryModel | Should -Be $Option
        }
        
        It "Throw exception when policy.recoverymodel.type is set to unsupported option" {
            Mock Get-DbcConfigValue { return "NOT_SUPPORTED_OPTION" } -ParameterFilter { $Name -like "policy.recoverymodel.type" }
            { Get-SettingsForRecoveryModelCheck } | Should -Throw 
        }
    }

    Context "Validate recovery model checks" {
        Mock Get-DbcConfigValue { return "FULL" } -ParameterFilter { $Name -like "policy.recoverymodel.type" }
        Mock Get-DbcConfigValue { return "myExcludedDb" } -ParameterFilter { $Name -like "policy.recoverymodel.excludedb" }

        $testSettings = Get-SettingsForRecoveryModelCheck 

        It "The test should pass when the current recovery model is as expected" {
            @{
                Database = "TestDB"
                RecoveryModel = "FULL"
            } |
            Assert-RecoveryModel -With $testSettings
        }

        It "The test should pass when the current recovery model is wrong, but database is excluded from checks" {
            @{
                Database = "myExcludedDb"
                RecoveryModel = "SIMPLE"
            } |
            Assert-RecoveryModel -With $testSettings
        }

        It "The test should fail when the current recovery model is not what is expected" {
            {
                @{
                    Database = "TestDB"
                    RecoveryModel = "SIMPLE"
                } |
                Assert-RecoveryModel -With $testSettings
            } | Should -Throw 
        }
    }
}
