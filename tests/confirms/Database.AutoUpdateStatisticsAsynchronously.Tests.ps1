. "$PSScriptRoot/../../confirms/Database.AutoUpdateStatisticsAsynchronously.ps1"

Describe "Testing Auto Update Statistics Asynchronously Assertion" -Tags AutoUpdateStatisticsAsynchronously {
    $cases = @(
        @{ ConfiguredValue = $true; ExpectedValue = "True"; ExpectedResult = "pass" },
        @{ ConfiguredValue = $true; ExpectedValue = "False"; ExpectedResult = "fail" },
        @{ ConfiguredValue = $false; ExpectedValue = "True"; ExpectedResult = "fail" },
        @{ ConfiguredValue = $false; ExpectedValue = "False"; ExpectedResult = "pass" }
    )

    It "The test should <ExpectedResult> when the expected value is <ExpectedValue> and configured value is <ConfiguredValue>" -TestCases $cases {
        param([Boolean]$ConfiguredValue, [String]$ExpectedValue, [String]$ExpectedResult)
        Mock Get-DbcConfigValue { return $ExpectedValue } -ParameterFilter { $Name -like "policy.database.autoupdatestatisticsasynchronously" }
        $config = Get-ConfigForAutoUpdateStatisticsAsynchronouslyCheck 
        if ($ExpectedResult -eq "pass") {
            @{
                AutoUpdateStatisticsAsynchronously = $ConfiguredValue
            } | Confirm-AutoUpdateStatisticsAsynchronously -With $config
        } else {
            {
                @{
                    AutoUpdateStatisticsAsynchronously = $ConfiguredValue
                } | Confirm-AutoUpdateStatisticsAsynchronously -With $config
            } | Should -Throw
        }
    }
}
