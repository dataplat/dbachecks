$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Write-Host -Object "Running $PSCommandpath" -ForegroundColor Cyan
. "$PSScriptRoot/../../internal/functions/Set-DatabaseForIntegrationTesting.ps1"
. "$PSScriptRoot/../../internal/checks/Database.ps1"

Describe "Testing the $commandname checks" -Tags CheckTests, "$($commandname)CheckTests" {
    Context "Validate the database collation check" {
        It "The test should pass when the datbase collation matches the instance collation" {
            $mock = [PSCustomObject]@{
                ServerCollation = "collation1"
                DatabaseCollation = "collation1"
            }
            Assert-DatabaseCollationsMatch $mock
        }

        It "The test should fail when the database and server collations do not match" {
            $mock = [PSCustomObject]@{
                ServerCollation = "collation1"
                DatabaseCollation = "collation2"
            }
            { Assert-DatabaseCollationsMatch $mock } | Should -Throw
        }
    }
}
