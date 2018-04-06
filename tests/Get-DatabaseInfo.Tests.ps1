$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Write-Host -Object "Running $PSCommandpath" -ForegroundColor Cyan
. "$PSScriptRoot/../internal/functions/Get-DatabaseInfo.ps1"

Describe "Integration testing of $commandname" -Tags SqlIntegrationTests,IntegrationTests {
    @(Get-DbcConfigValue testing.integration.instance).ForEach{
        Context "Collecting database configuration details for checks from $psitem" {
            BeforeAll {
                $expectedProperties = @{
                    InstanceCollation = [string]
                    InstanceCompatibilityLevel = [string]
                    SqlInstance = [string]
                    SqlVersion = [int]
                    DatabaseCollation = [string]
                    Owner = [string]
                    AutoShrink = [bool]
                    AutoClose = [bool]
                    AutoCreateStatistics = [bool]
                    AutoUpdateStatistics = [bool]
                    AutoUpdateStatisticsAsynchronously = [bool]
                    Trustworthy = [bool]
                    PageVerify = [string]
                    RecoveryModel = [string]
                    SuspectPages = [int]
                    Status = [string]
                    DataFilesWithoutBackup = [int]
                }

                $script:databases = (Get-DatabaseInfo -SqlInstance $psitem)
            }

            It "Execution of Get-DatabaseInfo should not throw exceptions" {
                { Get-DatabaseInfo -SqlInstance $psitem } | Should -Not -Throw -Because "we expect data not exceptions"
            }
  
            It "Get-DatabaseInfo should return at least the system databases" {
                $script:databases.Count | Should -BeGreaterOrEqual 4 -Because "we expect at least to have the system databases on any instance"
            }

            foreach($property in $expectedProperties.Keys) {
                It "Each database has $property which is not null or empty" {
                    $script:databases."$property".ForEach{
                        $psitem | Should -Not -BeNullOrEmpty
                    }
                }
            }

            foreach($property in $expectedProperties.Keys) {
                if ($expectedProperties[$property] -eq $null) {
                    continue
                }
                
                It "$property property should be of type $($expectedProperties[$property].ToString())" {
                    $script:databases."$property".ForEach{
                        $psitem | Should -BeOfType ($expectedProperties[$property])
                    }
                }
            }
        }
    }
}
