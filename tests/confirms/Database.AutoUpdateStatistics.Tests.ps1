. "$PSScriptRoot/../../confirms/Database.AutoUpdateStatistics.ps1"

Describe "Testing Auto Update Statistics Assertion" -Tags AutoUpdateStatistics {
    $cases = @(
        @{ ConfiguredValue = $true; ExpectedValue = "True"; ExpectedResult = "pass" },
        @{ ConfiguredValue = $true; ExpectedValue = "False"; ExpectedResult = "fail" },
        @{ ConfiguredValue = $false; ExpectedValue = "True"; ExpectedResult = "fail" },
        @{ ConfiguredValue = $false; ExpectedValue = "False"; ExpectedResult = "pass" }
    )

    It "The test should <ExpectedResult> when the expected value is <ExpectedValue> and configured value is <ConfiguredValue>" -TestCases $cases {
        param([Boolean]$ConfiguredValue, [String]$ExpectedValue, [String]$ExpectedResult)
        
        Mock Get-DbcConfigValue { return $ExpectedValue } -ParameterFilter { $Name -like "policy.database.autoupdatestatistics" }
        $config = Get-ConfigForAutoUpdateStatisticsCheck 

        if ($ExpectedResult -eq "pass") {
            @{
                AutoUpdateStatistics = $ConfiguredValue
            } | Confirm-AutoUpdateStatistics -With $config
        } else {
            {
                @{
                    AutoUpdateStatistics = $ConfiguredValue
                } | Confirm-AutoUpdateStatistics -With $config
            } | Should -Throw
        }
    }
}
