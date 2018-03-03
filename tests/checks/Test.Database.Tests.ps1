$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Write-Host -Object "Running $PSCommandpath" -ForegroundColor Cyan
. "$PSScriptRoot/../../internal/functions/Set-DatabaseForIntegrationTesting.ps1"

$checksScript = "./../checks/Database.Tests.ps1"
$sqlinstance = "localhost\SQL2017DEV", "localhost\SQL2016STD"
$testdb1 = "DbcChecksTestDb1"
$testlogin = "DbcChecksTestLogin"
$testloginpassword = (ConvertTo-SecureString -String "4([tyB)UJp64Vp%21~HQNUH" -AsPlainText -Force)

Describe "Tests database checks" {
    # there is no need to use Get-Instance as it is not the Invoke-DbcCheck run
    # there is no need to use configuration. It is just a unit test on predefined test servers. 
    $sqlinstance.ForEach{
        Context "Validate the database collation check on $psitem" {
            BeforeAll {
                Set-DatabaseForIntegrationTesting -SqlInstance $psitem -SqlCredential $sqlcredential -DatabaseName $testdb1
                $serverCollation = (Invoke-DbaSqlQuery -SqlInstance $psitem -SqlCredential $sqlcredential -Query "select serverproperty('Collation') ServerCollation")[0]
            }
            It "The test should pass when the database collation matches the instance collation" {
                Invoke-DbaSqlQuery -SqlInstance $psitem -SqlCredential $sqlcredential -Query "alter database $testdb1 collate $serverCollation"
                { Invoke-DbcCheck -Tags DatabaseCollation -Database $testdb1 -Script $checksScript -SqlInstance $psitem -SqlCredential $sqlcredential -Show None -PassThru } | Should -Not -Throw -Because "the collations match and the test failed to recognise it"
            }
            It "The test should fail when the database collation doesn't match the instance collation" {
                # Thai_CI_AS collation seems to be 'exotic' enough not to be the default server collation in any test environment. 
                Invoke-DbaSqlQuery -SqlInstance $psitem -SqlCredential $sqlcredential -Query "alter database $testdb1 collate Thai_CI_AS"
                { Invoke-DbcCheck -Tags DatabaseCollation -Database $testdb1 -Script $checksScript -SqlInstance $psitem -SqlCredential $sqlcredential -Show None -PassThru } | Should -Throw -Because "the collations don't match but the test failed to fail"
            }
        }
    }

    $sqlinstance.ForEach{
        Context "Validate the valid database owner check on $psitem" {
            BeforeAll {
                Set-DatabaseForIntegrationTesting -SqlInstance $psitem -SqlCredential $sqlcredential -DatabaseName $testdb1
                
                if (0 -lt (Get-DbaLogin -SqlInstance $psitem -SqlCredential $sqlcredential -Login $testlogin).Count) {
                    New-DbaLogin -SqlInstance $psitem -Login $testlogin -Password $testloginpassword -Force | Out-Null
                } else { 
                    Set-DbaLogin -SqlInstance $psitem -Login $testlogin -Password $testloginpassword
                }

                Set-DbcConfig -Name policy.validdbowner.name -Value $testlogin 
                $exclude = Get-DbcConfigValue policy.validdbowner.excludedb 
            }
            It "The test should pass when the database owner is set to the expected login" {
                Set-DbaDatabaseOwner -SqlInstance $psitem -Database $testdb1 -TargetLogin $testlogin  
                { Invoke-DbcCheck -Check ValidDatabaseOwner -Database $testdb1 -Script $checksScript -SqlInstance $psitem -SqlCredential $sqlcredential -Show None -PassThru } | Should -Not -Throw -Because "the owner is set to the expected value"
            }
            It "The test should fail when the database owner is set to something else than the expected login" {
                Set-DbaDatabaseOwner -SqlInstance $psitem -Database $testdb1 -TargetLogin sa
                { Invoke-DbaCheck -Tags ValidDatabaseOwner -Database $testdb1 -Script $checksScript -SqlInstance $psitem -SqlCredential $sqlcredential -Show None -PassThru } | Should -Throw -Because "the owner is set to sa but the expected value is $testlogin."
            }
        }
    }
}
