. "$PSScriptRoot/../../assertions/Database.AutoCreateStatistics.ps1"

Describe "Testing Auto Create Statistics Assertion" -Tags AutoCreateStatistic {
    Context "Tests with expected Auto Create Statistics set to true" {
        $cases = @(
            @{ ConfiguredValue = $true; ExpectedValue = "True"; ExpectedResult = "pass" },
            @{ ConfiguredValue = $true; ExpectedValue = "False"; ExpectedResult = "fail" },
            @{ ConfiguredValue = $false; ExpectedValue = "True"; ExpectedResult = "fail" },
            @{ ConfiguredValue = $false; ExpectedValue = "False"; ExpectedResult = "pass" }
        )

        It "The test should <ExpectedResult> when the expected value is <ExpectedValue> and configured value is <ConfiguredValue>" -TestCases $cases {
            param([Boolean]$ConfiguredValue, [String]$ExpectedValue, [String]$ExpectedResult)
            Mock Get-DbcConfigValue { return $ExpectedValue } -ParameterFilter { $Name -like "policy.database.autocreatestatistics" }
            $testSettings = Get-SettingsForAutoCreateStatisticsCheck 
            if ($ExpectedResult -eq "pass") {
                @{
                    AutoCreateStatistics = $ConfiguredValue
                } | Assert-AutoCreateStatistics -With $testSettings
            } else {
                {
                    @{
                        AutoCreateStatistics = $ConfiguredValue
                    } | Assert-AutoCreateStatistics -With $testSettings
                } | Should -Throw
            }
        }
    }
}
