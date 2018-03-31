. "$PSScriptRoot/../../assertions/Database.AutoShrink.ps1"

Describe "Testing Auto Shrink Assertion" -Tags AutoShrink {
    $cases = @(
        @{ ConfiguredValue = $true; ExpectedValue = "True"; ExpectedResult = "pass" },
        @{ ConfiguredValue = $true; ExpectedValue = "False"; ExpectedResult = "fail" },
        @{ ConfiguredValue = $false; ExpectedValue = "True"; ExpectedResult = "fail" },
        @{ ConfiguredValue = $false; ExpectedValue = "False"; ExpectedResult = "pass" }
    )

    It "The test should <ExpectedResult> when the expected value is <ExpectedValue> and configured value is <ConfiguredValue>" -TestCases $cases {
        param([Boolean]$ConfiguredValue, [String]$ExpectedValue, [String]$ExpectedResult)
        Mock Get-DbcConfigValue { return $ExpectedValue } -ParameterFilter { $Name -like "policy.database.autoshrink" }
        $testSettings = Get-SettingsForAutoShrinkCheck 
        if ($ExpectedResult -eq "pass") {
            @{
                AutoShrink = $ConfiguredValue
            } | Assert-AutoShrink -With $testSettings
        } else {
            {
                @{
                    AutoShrink = $ConfiguredValue
                } | Assert-AutoShrink -With $testSettings
            } | Should -Throw
        }
    }
}
