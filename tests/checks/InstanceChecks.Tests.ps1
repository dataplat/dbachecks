# load all of the assertion functions
(Get-ChildItem $PSScriptRoot/../../internal/assertions/).ForEach{. $Psitem.FullName}

Describe "Checking Instance.Tests.ps1 checks" -Tag UnitTest {
    Context "Checking Backup Compression" {
        # Mock the version check for running tests
        Mock Connect-DbaInstance {@{Version = @{Major = 14}}}
        # Define test cases for the results to fail test and fill expected message
        # So the results of SPConfigure is 1, we expect $false but the result is true and the results of SPConfigure is 0, we expect $true but the result is false
        $TestCases = @{spconfig = 1; expected = $false; actual = $true}, @{spconfig = 0; expected = $true; actual = $false}
        It "Fails Check Correctly for Config <spconfig> and expected value <expected>" -TestCases $TestCases {
            Param($spconfig, $actual, $expected)
            Mock Get-DbaSpConfigure {@{"ConfiguredValue" = $spconfig}}
        {Assert-BackupCompression -Instance 'Dummy' -defaultbackupcompression $expected} | Should -Throw -ExpectedMessage "Expected `$$expected, because The default backup compression should be set correctly, but got `$$actual"
        }
        $TestCases = @{spconfig = 0; expected = $false}, @{spconfig = 1; expected = $true; }
        It "Passes Check Correctly for Config <spconfig> and expected value <expected>" -TestCases $TestCases {
            Param($spconfig, $expected)
            Mock Get-DbaSpConfigure {@{"ConfiguredValue" = $spconfig}}
        Assert-BackupCompression -Instance 'Dummy' -defaultbackupcompression $expected
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
    <#
        It "Should not run for SQL 2005 and below"{
            # Mock Get-Version
            function Get-Version {}
            Mock Get-Version {9} 
        # Mock the version check for not running the tests
        Mock Get-DbaSpConfigure {@{"ConfiguredValue" = 1}}
        $Pester = Invoke-DbcCheck -SQLInstance Dummy -Check DefaultBackupCompression -PassThru -Show None
       # $Pester.TotalCount | Should -Be 1
       # $Pester.SkippedCount | Should -Be 1
        $assertMockParams = @{
            'CommandName' = 'Get-Version'
            'Times'       = 1
            'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
    }
#>

    }
    Context "Checking Instance MaxDop" {
        # if Userecommended it should pass if CurrentInstanceMaxDop property returned from Test-DbaMaxDop matches the RecommendedMaxDop property
        It "Passes Check Correctly with the use recommended parameter set to true" {
            # Mock to pass
            Mock Test-DbaMaxDop {@{"CurrentInstanceMaxDop" = 0; "RecommendedMaxDop" = 0}}
            Assert-InstanceMaxDop  -Instance 'Dummy' -UseRecommended
        }
        # if Userecommended it should fail if CurrentInstanceMaxDop property returned from Test-DbaMaxDop does not match the RecommendedMaxDop property
        It "Fails Check Correctly with the use recommended parameter set to true" {
            # Mock to fail
            Mock Test-DbaMaxDop {@{"CurrentInstanceMaxDop" = 0; "RecommendedMaxDop" = 5}}
            {Assert-InstanceMaxDop -Instance 'Dummy' -UseRecommended} | Should -Throw -ExpectedMessage "Expected 5, because We expect the MaxDop Setting 0 to be the recommended value 5"
        }
        $TestCases = @{"MaxDopValue" = 5}
        # if not UseRecommended - it should pass if the CurrentInstanceMaxDop property returned from Test-DbaMaxDop matches the MaxDopValue parameter
        It "Passes Check Correctly with a specified value <MaxDopValue>" -TestCases $TestCases {
            Param($MaxDopValue)
            # Mock to pass
            Mock Test-DbaMaxDop {@{"CurrentInstanceMaxDop" = 5; "RecommendedMaxDop" = $MaxDopValue}}
            Assert-InstanceMaxDop -Instance 'Dummy' -MaxDopValue $MaxDopValue
        }
        $TestCases = @{"MaxDopValue" = 5}, @{"MaxDopValue" = 0}
        # if not UseRecommended - it should fail if the CurrentInstanceMaxDop property returned from Test-DbaMaxDop does not match the MaxDopValue parameter
        It "Fails Check Correctly with with a specified value <MaxDopValue>" -TestCases $TestCases {
            Param($MaxDopValue)
            # Mock to fail
            Mock Test-DbaMaxDop {@{"CurrentInstanceMaxDop" = 4; "RecommendedMaxDop" = 73}}
            {Assert-InstanceMaxDop -Instance 'Dummy' -MaxDopValue $MaxDopValue} | Should -Throw -ExpectedMessage "Expected $MaxDopValue, because We expect the MaxDop Setting 4 to be $MaxDopValue"
        }
             # Validate we have called the mock the correct number of times
             It "Should call the mocks" {
                $assertMockParams = @{
                    'CommandName' = 'Test-DbaMaxDop'
                    'Times'       = 5
                    'Exactly'     = $true
                }
                Assert-MockCalled @assertMockParams
            }
}
}
