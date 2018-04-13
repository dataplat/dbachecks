. "$PSScriptRoot/../../confirms/Database.RecoveryModel.ps1"

Describe "Testing Recovery Model Assertion" -Tags RecoveryModel {
    Context "Test configuration" {
        $cases = @(
            @{ Option = "FULL" },
            @{ Option = "SIMPLE" }
        )

        It "<Option> is acceptable as policy.recoverymodel.type value" -TestCases $cases {
            param($Option) 
            Mock Get-DbcConfigValue { return $Option } -ParameterFilter { $Name -like "policy.recoverymodel.type" }
            (Get-ConfigForRecoveryModelCheck).RecoveryModel | Should -Be $Option
        }
        
        It "Throw exception when policy.recoverymodel.type is set to unsupported option" {
            Mock Get-DbcConfigValue { return "NOT_SUPPORTED_OPTION" } -ParameterFilter { $Name -like "policy.recoverymodel.type" }
            { Get-ConfigForRecoveryModelCheck } | Should -Throw 
        }
    }

    Context "Validate recovery model checks" {
        Mock Get-DbcConfigValue { return "FULL" } -ParameterFilter { $Name -like "policy.recoverymodel.type" }
        Mock Get-DbcConfigValue { return "myExcludedDb" } -ParameterFilter { $Name -like "policy.recoverymodel.excludedb" }

        $config = Get-ConfigForRecoveryModelCheck 

        It "The test should pass when the current recovery model is as expected" {
            @{
                Database = "TestDB"
                RecoveryModel = "FULL"
            } |
            Confirm-RecoveryModel -With $config
        }

        It "The test should pass when the current recovery model is wrong, but database is excluded from checks" {
            @{
                Database = "myExcludedDb"
                RecoveryModel = "SIMPLE"
            } |
            Confirm-RecoveryModel -With $config
        }

        It "The test should fail when the current recovery model is not what is expected" {
            {
                @{
                    Database = "TestDB"
                    RecoveryModel = "SIMPLE"
                } |
                Confirm-RecoveryModel -With $config
            } | Should -Throw 
        }
    }
}
