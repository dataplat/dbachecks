. "$PSScriptRoot/../../confirms/Database.PageVerify.ps1"

Describe "Testing Page Verify Confirms" -Tags PageVerify {
    Context "Test configuration" {
        $cases = @(
            @{ Option = "CHECKSUM" },
            @{ Option = "TORN_PAGE_DETECTION" },
            @{ Option = "NONE" }
        )

        It "<Option> is acceptable as policy.pageverify value" -TestCases $cases {
            param($Option) 
            Mock Get-DbcConfigValue { return $Option } -ParameterFilter { $Name -like "policy.pageverify" }
            (Get-ConfigForPageVerifyCheck).PageVerify | Should -Be $Option
        }
        
        It "Throw exception when policy.pageverify is set to unsupported option" {
            Mock Get-DbcConfigValue { return "NOT_SUPPORTED_OPTION" } -ParameterFilter { $Name -like "policy.pageverify" }
            { Get-ConfigForPageVerifyCheck } | Should -Throw 
        }
    }

    Context "Test the assert function" {
        Mock Get-DbcConfigValue { return "CHECKSUM" } -ParameterFilter { $Name -like "policy.pageverify" }

        $config = Get-ConfigForPageVerifyCheck 

        It "The test should pass when the PageVerify is as configured" {
            @{
                PageVerify = "CHECKSUM"
            } | 
                Confirm-PageVerify -With $config 
        }

        It "The test should fail when the PageVerify is not as configured" {
            {
                @{
                    PageVerify = "NONE"
                } | 
                    Confirm-PageVerify -With $config
            } | Should -Throw 
        }
    }
}
