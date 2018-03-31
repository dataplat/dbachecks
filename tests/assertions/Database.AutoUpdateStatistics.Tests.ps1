. "$PSScriptRoot/../../assertions/Database.AutoUpdateStatistics.ps1"

Describe "Testing Auto Update Statistics Assertion" -Tags AutoCreateStatistic {
    $cases = @(
        @{ ConfiguredValue = $true; ExpectedValue = "True"; ExpectedResult = "pass" },
        @{ ConfiguredValue = $true; ExpectedValue = "False"; ExpectedResult = "fail" },
        @{ ConfiguredValue = $false; ExpectedValue = "True"; ExpectedResult = "fail" },
        @{ ConfiguredValue = $false; ExpectedValue = "False"; ExpectedResult = "pass" }
    )

    It "The test should <ExpectedResult> when the expected value is <ExpectedValue> and configured value is <ConfiguredValue>" -TestCases $cases {
        param([Boolean]$ConfiguredValue, [String]$ExpectedValue, [String]$ExpectedResult)
        
        Mock Get-DbcConfigValue { return $ExpectedValue } -ParameterFilter { $Name -like "policy.database.autoupdatestatistics" }
        $testSettings = Get-SettingsForAutoUpdateStatisticsCheck 

        if ($ExpectedResult -eq "pass") {
            @{
                AutoUpdateStatistics = $ConfiguredValue
            } | Assert-AutoUpdateStatistics -With $testSettings
        } else {
            {
                @{
                    AutoUpdateStatistics = $ConfiguredValue
                } | Assert-AutoUpdateStatistics -With $testSettings
            } | Should -Throw
        }
    }
}
