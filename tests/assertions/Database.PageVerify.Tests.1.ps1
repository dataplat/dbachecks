. "$PSScriptRoot/../../assertions/Database.PageVerify.ps1"

Describe "Testing Page Verify Assertions" -Tags PageVerify {
    Context "Test configuration" {
        $cases = @(
            @{ Option = "CHECKSUM" },
            @{ Option = "TORN_PAGE_DETECTION" },
            @{ Option = "NONE" }
        )

        It "<Option> is acceptable as policy.pageverify value" -TestCases $cases {
            param($Option) 
            Mock Get-DbcConfigValue { return $Option } -ParameterFilter { $Name -like "policy.pageverify" }
            (Get-SettingsForPageVerifyCheck).PageVerify | Should -Be $Option
        }
        
        It "Throw exception when policy.pageverify is set to unsupported option" {
            Mock Get-DbcConfigValue { return "NOT_SUPPORTED_OPTION" } -ParameterFilter { $Name -like "policy.pageverify" }
            { Get-SettingsForPageVerifyCheck } | Should -Throw 
        }
    }

    Context "Test the assert function" {
        Mock Get-DbcConfigValue { return "CHECKSUM" } -ParameterFilter { $Name -like "policy.pageverify" }

        $testSettings = Get-SettingsForPageVerifyCheck 

        It "The test should pass when the PageVerify is as configured" {
            @{
                PageVerify = "CHECKSUM"
            } | 
                Assert-PageVerify -With $testSettings 
        }

        It "The test should fail when the PageVerify is not as configured" {
            {
                @{
                    PageVerify = "NONE"
                } | 
                    Assert-PageVerify -With $testSettings
            } | Should -Throw 
        }
    }
}
