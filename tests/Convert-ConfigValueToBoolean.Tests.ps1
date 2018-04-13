. "$PSScriptRoot/../internal/functions/Convert-ConfigValueToBoolean.ps1"

Describe "Testing the Convert-ToBoolean internal function" {
    $tests = @(
        @{ Test = "True"; Result = $true },
        @{ Test = "true"; Result = $true },
        @{ Test = "tRue"; Result = $true },
        @{ Test = "on"; Result = $true },
        @{ Test = "yes"; Result = $true },
        @{ Test = "YES"; Result = $true },
        @{ Test = "enable"; Result = $true },
        @{ Test = "ENABLED"; Result = $true },
        @{ Test = 1; Result = $true },
        @{ Test = "false"; Result = $false },
        @{ Test = "FALSE"; Result = $false },
        @{ Test = "off"; Result = $false },
        @{ Test = "no"; Result = $false },
        @{ Test = "DISABLED"; Result = $false },
        @{ Test = "disabled"; Result = $false },
        @{ Test = 0; Result = $false }
    )

    It "<Test> piped into Convert-ToBoolean returns <Result>" -TestCases $tests {
        param($Test, $Result) 
        ($Test | Convert-ConfigValueToBoolean) | Should -Be $Result 
    }

    It "<Test> passed as -Value parameter returns <Result>" -TestCases $tests {
        param($Test, $Result) 
        (Convert-ConfigValueToBoolean -Value $Test) | Should -Be $Result 
    }

    It "unssuported value passed to Convert-ToBool should throw" {
        { "something" | Convert-ConfigValueToBoolean } | Should -Throw -Because "we don't want implied values"
    }

}