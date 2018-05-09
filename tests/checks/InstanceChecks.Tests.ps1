# load all of the assertion functions
(Get-ChildItem $PSScriptRoot/../../internal/assertions/).ForEach{. $Psitem.FullName}

Describe "Checking Instance.Tests.ps1 checks" -Tag UnitTest {
    Context "Checking Backup Compression" {
        # Mock the version check for running tests
        Mock Connect-DbaInstance {@{Version = @{Major = 14}}}
        # Define test cases for the results to fail test and fill expected message
        # So the results of SPConfigure is 1, we expect $false but the result is true and the results of SPConfigure is 0, we expect $true but the result is false
        $TestCases = @{spconfig= 1;expected = $false;actual = $true},@{spconfig= 0;expected = $true;actual = $false}
        It "Fails Check Correctly for Config <spconfig> and expected value <expected>" -TestCases $TestCases {
            Param($spconfig, $actual, $expected)
            Mock Get-DbaSpConfigure {@{"ConfiguredValue" = $spconfig}}
        {Assert-BackupCompression -Instance 'Dummy' -defaultbackupcompression $expected} | Should -Throw -ExpectedMessage "Expected `$$expected, because The default backup compression should be set correctly, but got `$$actual"
        }
        $TestCases = @{spconfig= 0;expected = $false},@{spconfig= 1;expected = $true;}
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
}
