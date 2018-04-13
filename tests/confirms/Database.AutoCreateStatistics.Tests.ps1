. "$PSScriptRoot/../../confirms/Database.AutoCreateStatistics.ps1"

Describe "Testing Auto Create Statistics Assertion" -Tags AutoCreateStatistic {
    $cases = @(
        @{ ConfiguredValue = $true; ExpectedValue = "True"; ExpectedResult = "pass" },
        @{ ConfiguredValue = $true; ExpectedValue = "False"; ExpectedResult = "fail" },
        @{ ConfiguredValue = $false; ExpectedValue = "True"; ExpectedResult = "fail" },
        @{ ConfiguredValue = $false; ExpectedValue = "False"; ExpectedResult = "pass" }
    )

    It "The test should <ExpectedResult> when the expected value is <ExpectedValue> and configured value is <ConfiguredValue>" -TestCases $cases {
        param([Boolean]$ConfiguredValue, [String]$ExpectedValue, [String]$ExpectedResult)
        Mock Get-DbcConfigValue { return $ExpectedValue } -ParameterFilter { $Name -like "policy.database.autocreatestatistics" }
        $config = Get-ConfigForAutoCreateStatisticsCheck 
        if ($ExpectedResult -eq "pass") {
            @{
                AutoCreateStatistics = $ConfiguredValue
            } | Confirm-AutoCreateStatistics -With $config
        } else {
            {
                @{
                    AutoCreateStatistics = $ConfiguredValue
                } | Confirm-AutoCreateStatistics -With $config
            } | Should -Throw
        }
    }
}
