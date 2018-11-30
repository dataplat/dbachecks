# load all of the assertion functions
(Get-ChildItem $PSScriptRoot/../../internal/assertions/).ForEach{. $Psitem.FullName}

Describe "Checking Agent.Tests.ps1 checks" -Tag UnitTest {
    Context "Checking Database Mail XPs" {
        # Mock the version check for running tests
        Mock Connect-DbaInstance {}
        # Define test cases for the results to fail test and fill expected message
        # So the results of SPConfigure is 1, we expect $false but the result is true and the results of SPConfigure is 0, we expect $true but the result is false
        $TestCases = @{spconfig = 1; expected = $false; actual = $true}, @{spconfig = 0; expected = $true; actual = $false}
        It "Fails Check Correctly for Config <spconfig> and expected value <expected>" -TestCases $TestCases {
            Param($spconfig, $actual, $expected)
            Mock Get-DbaSpConfigure {@{"ConfiguredValue" = $spconfig}}
            {Assert-DatabaseMailEnabled -SQLInstance 'Dummy' -DatabaseMailEnabled $expected} | Should -Throw -ExpectedMessage "Expected `$$expected, because The Database Mail XPs setting should be set correctly, but got `$$actual"
        }
        $TestCases = @{spconfig = 0; expected = $false}, @{spconfig = 1; expected = $true; }
        It "Passes Check Correctly for Config <spconfig> and expected value <expected>" -TestCases $TestCases {
            Param($spconfig, $expected)
            Mock Get-DbaSpConfigure {@{"ConfiguredValue" = $spconfig}}
            Assert-DatabaseMailEnabled -SQLInstance 'Dummy' -DatabaseMailEnabled $expected
        }
        # Validate we have called the mock the correct number of times
        It "Should call the mocks" {
            $assertMockParams = @{
                'CommandName' = 'Get-DbaSpConfigure'
                'Times'       = 4
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
    }

    Context "Checking Job History" {
        # if configured value for MaximumHistoryRows is -1 and test value -1 it will pass
        It "Passes Check Correctly with Maximum History Rows disabled (-1)" {
            # Mock to pass
            Mock Get-DbaAgentServer {
                [PSCustomObject]@{
                    MaximumHistoryRows = -1;
                    MaximumJobHistoryRows = 0;
                }
            }
            $AgentServer = Get-DbaAgentServer -SqlInstance "Dummy" -EnableException:$false
            Assert-JobHistoryRowsDisabled -AgentServer $AgentServer -minimumJobHistoryRows -1
        }
        # if configured value for MaximumHistoryRows is -1 and test value -1 it will pass
        It "Fails Check Correctly with Maximum History Rows disabled (-1) but configured value is 1000" {
            # Mock to fail
            Mock Get-DbaAgentServer {
                [PSCustomObject]@{
                    MaximumHistoryRows = 1000;
                    MaximumJobHistoryRows = 0;
                }
            }
            $AgentServer = Get-DbaAgentServer -SqlInstance "Dummy" -EnableException:$false
            { Assert-JobHistoryRowsDisabled -AgentServer $AgentServer -minimumJobHistoryRows -1 } | Should -Throw -ExpectedMessage "Expected '-1', because Maximum job history configuration should be disabled, but got 1000."
        }
        # if configured value for MaximumHistoryRows is 10000 and test value 10000 it will pass
        It "Passes Check Correctly with Maximum History Rows being 10000" {
            # Mock to pass
            Mock Get-DbaAgentServer {
                [PSCustomObject]@{
                    MaximumHistoryRows = 10000;
                    MaximumJobHistoryRows = 0;
                }
            }
            $AgentServer = Get-DbaAgentServer -SqlInstance "Dummy" -EnableException:$false
            Assert-JobHistoryRows -AgentServer $AgentServer -minimumJobHistoryRows 10000
        }
        # if configured value for MaximumHistoryRows is -1 and test value -1 it will pass
        It "Fails Check Correctly with Maximum History Rows being less than 10000" {
            # Mock to fail
            Mock Get-DbaAgentServer {
                [PSCustomObject]@{
                    MaximumHistoryRows = 1000;
                    MaximumJobHistoryRows = 0;
                }
            }
            $AgentServer = Get-DbaAgentServer -SqlInstance "Dummy" -EnableException:$false
            { Assert-JobHistoryRows -AgentServer $AgentServer -minimumJobHistoryRows 10000 } | Should -Throw -ExpectedMessage "Expected the actual value to be greater than or equal to 10000, because We expect the maximum job history row configuration to be greater than the configured setting 10000, but got 1000."
        }
        # if configured value is 100 and test value 100 it will pass
        It "Passes Check Correctly with Maximum History Rows per job being 100" {
            # Mock to pass
            Mock Get-DbaAgentServer {
                [PSCustomObject]@{
                    MaximumHistoryRows = 1000;
                    MaximumJobHistoryRows = 100;
                }
            }
            $AgentServer = Get-DbaAgentServer -SqlInstance "Dummy" -EnableException:$false
            Assert-JobHistoryRowsPerJob -AgentServer $AgentServer -minimumJobHistoryRowsPerJob 100
        }
        # if configured value is -1 and test value -1 it will pass
        It "Fails Check Correctly with Maximum History Rows per job being less than 100" {
            # Mock to fail
            Mock Get-DbaAgentServer {
                [PSCustomObject]@{
                    MaximumHistoryRows = 100;
                    MaximumJobHistoryRows = 50;
                }
            }
            $AgentServer = Get-DbaAgentServer -SqlInstance "Dummy" -EnableException:$false
            { Assert-JobHistoryRowsPerJob -AgentServer $AgentServer -minimumJobHistoryRowsPerJob 100 } | Should -Throw -ExpectedMessage "Expected the actual value to be greater than or equal to 100, because We expect the maximum job history row configuration per agent job to be greater than the configured setting 100, but got 50."
        }
        # Validate we have called the mock the correct number of times
        It "Should call the mocks" {
            $assertMockParams = @{
                'CommandName' = 'Get-DbaAgentServer'
                'Times'       = 6
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
    }
}