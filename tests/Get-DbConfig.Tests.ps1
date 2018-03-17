$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Write-Host -Object "Running $PSCommandpath" -ForegroundColor Cyan
. "$PSScriptRoot/../internal/functions/Get-DbConfig.ps1"

$sqlinstance = "localhost"

Describe "Integration testing of $commandname" -Tags IntegrationTests,SqlIntegrationTests, Integration {
    @($sqlinstance).ForEach{
        Context "Collecting database configuration details for checks from $psitem" {
            BeforeAll {
                $expectedProperties = @{
                    ServerCollation = [string]
                    SqlInstance = [string]
                    SqlVersion = [int]
                    DatabaseCollation = [string]
                    CurrentOwner = [string]
                    AutoShrink = [bool]
                    AutoClose = [bool]
                    AutoCreateStatisticsEnabled = [bool]
                    AutoUpdateStatisticsEnabled = [bool]
                    AutoUpdateStatisticsAsync = [bool]
                    Trustworthy = [bool]
                    PageVerify = [string]
                    SuspectPages = [int]
                    Status = [string]
                }

                $script:databases = (Get-DbConfig -SqlInstance $psitem)
            }

            It "Execution of Get-DbConfig should not throw exceptions" {
                { Get-DbConfig -SqlInstance $psitem } | Should -Not -Throw -Because "we expect data not exceptions"
            }
  
            It "Get-DbConfig should return at least the system databases" {
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
