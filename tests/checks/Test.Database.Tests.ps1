$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Write-Host -Object "Running $PSCommandpath" -ForegroundColor Cyan

$instance = "localhost"
$testdb = "DbcChecksTestDb"
$checksScript = "./../checks/Database.Tests.ps1"

function Set-TestDatabase {
    $db = Get-DbaDatabase -SqlInstance $instance -SqlCredential $sqlcredential -Database $testdb 
    if ($db -eq $null) {
        $server = Connect-DbaInstance -SqlInstance $instance -SqlCredential $sqlcredential
        $server.Query("create database $testdb")
    }
}

Describe "Database Tests Integration Tests" {
    Context "Validate Database Collation Test" {
        BeforeAll {
            Set-TestDatabase
            $serverCollation = (Invoke-DbaSqlCmd -SqlInstance $instance -SqlCredential $sqlcredential -Query "select serverproperty('Collation') ServerCollation")[0]
        }
        It "The test should pass when the database collation matches the instance collation" {
            Invoke-DbaSqlCmd -SqlInstance $instance -SqlCredential $sqlcredential -Query "alter database $testdb collate $serverCollation"
            { Invoke-DbcCheck -Tags DatabaseCollation -Script $checksScript -SqlInstance $instance -SqlCredential $sqlcredential -Show None -PassThru } | Should -Not -Throw
        }
        It "The test should fail when the database collation doesn't match the instance collation" {
            Invoke-DbaSqlCmd -SqlInstance $instance -SqlCredential $sqlcredential -Query "alter database $testdb collate Thai_CI_AS"
            { Invoke-DbaCheck -Tags DatabaseCollation -Script $checksScript -SqlInstance $instance -SqlCredential $sqlcredential -Show None -PassThru } | Should -Throw
        }
    }
}