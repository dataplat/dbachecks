. "$PSScriptRoot/../../assertions/Database.AutoUpdateStatisticsAsynchronously.ps1"

Describe "Testing Auto Update Statistics Asynchronously Assertion" -Tags AutoCreateStatistic {
    $cases = @(
        @{ ConfiguredValue = $true; ExpectedValue = "True"; ExpectedResult = "pass" },
        @{ ConfiguredValue = $true; ExpectedValue = "False"; ExpectedResult = "fail" },
        @{ ConfiguredValue = $false; ExpectedValue = "True"; ExpectedResult = "fail" },
        @{ ConfiguredValue = $false; ExpectedValue = "False"; ExpectedResult = "pass" }
    )

    It "The test should <ExpectedResult> when the expected value is <ExpectedValue> and configured value is <ConfiguredValue>" -TestCases $cases {
        param([Boolean]$ConfiguredValue, [String]$ExpectedValue, [String]$ExpectedResult)
        Mock Get-DbcConfigValue { return $ExpectedValue } -ParameterFilter { $Name -like "policy.database.autoupdatestatisticsasynchronously" }
        $testSettings = Get-SettingsForAutoUpdateStatisticsAsynchronouslyCheck 
        if ($ExpectedResult -eq "pass") {
            @{
                AutoUpdateStatisticsAsynchronously = $ConfiguredValue
            } | Assert-AutoUpdateStatisticsAsynchronously -With $testSettings
        } else {
            {
                @{
                    AutoUpdateStatisticsAsynchronously = $ConfiguredValue
                } | Assert-AutoUpdateStatisticsAsynchronously -With $testSettings
            } | Should -Throw
        }
    }
}
