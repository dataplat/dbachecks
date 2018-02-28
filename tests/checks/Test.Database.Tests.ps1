$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Write-Host -Object "Running $PSCommandpath" -ForegroundColor Cyan
. "$PSScriptRoot/../../internal/functions/Set-DatabaseForIntegrationTesting.ps1"

$checksScript = "./../checks/Database.Tests.ps1"
$sqlinstance = "localhost\SQL2017DEV", "localhost\SQL2016STD"
$testdb = "DbcChecksTestDb"

Describe "Tests database checks" {
    # there is no need to use Get-Instance as it is not the Invoke-DbcCheck run
    # there is no need to use configuration. It is just a unit test on predefined test servers. 
    $sqlinstance.ForEach{
        Context "Validate database collation check on $psitem" {
            BeforeAll {
                Set-DatabaseForIntegrationTesting -SqlInstance $psitem -SqlCredential $sqlcredential -DatabaseName $testdb 
                $serverCollation = (Invoke-DbaSqlQuery -SqlInstance $psitem -SqlCredential $sqlcredential -Query "select serverproperty('Collation') ServerCollation")[0]
            }
            It "The test should pass when the database collation matches the instance collation" {
                Invoke-DbaSqlQuery -SqlInstance $psitem -SqlCredential $sqlcredential -Query "alter database $testdb collate $serverCollation"
                { Invoke-DbcCheck -Tags DatabaseCollation -Script $checksScript -SqlInstance $psitem -SqlCredential $sqlcredential -Show None -PassThru } | Should -Not -Throw -Because "the collations match and the test failed to recognise it"
            }
            It "The test should fail when the database collation doesn't match the instance collation" {
                # Thai_CI_AS collation seems to be 'exotic' enough not to be the default server collation in any test environment. 
                Invoke-DbaSqlQuery -SqlInstance $psitem -SqlCredential $sqlcredential -Query "alter database $testdb collate Thai_CI_AS"
                { Invoke-DbaCheck -Tags DatabaseCollation -Script $checksScript -SqlInstance $psitem -SqlCredential $sqlcredential -Show None -PassThru } | Should -Throw -Because "the collations don't match but the test failed to fail"
            }
        }
    }
}
