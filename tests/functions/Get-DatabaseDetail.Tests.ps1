[cmdletbinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification='Because they are used just doesnt see them')]
Param()
$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Remove-Module dbachecks -ErrorAction SilentlyContinue
Remove-Module dbatools  -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\dbachecks.psd1"

. "$PSScriptRoot/../../internal/functions/Get-DatabaseDetail.ps1"

Describe "Integration testing of $commandname" -Tags SqlIntegrationTests,IntegrationTests, Integration {
    @(Get-DbcConfigValue testing.integration.instance).ForEach{
        Context "Collecting database details for checks from $psitem" {
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

                $script:databases = (Get-DatabaseDetail -SqlInstance $psitem)
            }

            It "Execution of Get-DatabaseDetail should not throw exceptions" {
                { Get-DatabaseDetail -SqlInstance $psitem } | Should -Not -Throw -Because "we expect data not exceptions"
            }

            It "Get-DatabaseDetail should return at least the system databases" {
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
