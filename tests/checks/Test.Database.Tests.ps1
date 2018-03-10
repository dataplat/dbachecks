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

    Context "Validate database owner checks" {
        It "The positive test should pass when the current owner is as expected" {
            $mock = [PSCustomObject]@{ CurrentOwner = "correctlogin" }
            Assert-DatabaseOwnerIs $mock -ExpectedOwner "correctlogin"
        }
        It "The positive test should fail when the current owner is not one that is expected" {
            $mock = [PSCustomObject]@{ CurrentOwner = "wronglogin" }
            { Assert-DatabaseOwnerIs $mock -ExpectedOwner "correctlogin" } | Should -Throw
        }
        It "The negative test should pass when the current owner is not what is invalid" {
            $mock = [PSCustomObject]@{ CurrentOwner = "correctlogin" }
            Assert-DatabaseOwnerIsNot $mock -InvalidOwner "invalidlogin"
        }
        It "The negative test should fail when the current owner is the invalid one" {
            $mock = [PSCustomObject]@{ CurrentOwner = "invalidlogin" }
            { Assert-DatabaseOwnerIsNot $mock -InvalidOwner "invalidlogin" } | Should -Throw
        }
    }

    Context "Validate recovery model checks" {
        It "The test should pass when the current recovery model is as expected" {
            $mock = [PSCustomObject]@{ RecoveryModel = "FULL" }
            Assert-RecoveryModel $mock -ExpectedRecoveryModel "FULL"
            $mock = [PSCustomObject]@{ RecoveryModel = "SIMPLE" }
            Assert-RecoveryModel $mock -ExpectedRecoveryModel "simple" # the assert should be case insensitive
        }

        It "The test should fail when the current recovery model is not what is expected" {
            $mock = [PSCustomObject]@{ RecoveryModel = "FULL" }
            { Assert-RecoveryModel $mock -ExpectedRecoveryModel "SIMPLE" } | Should -Throw
        }
    }

    Context "Validate the suspcet pages check" {
        It "The test should pass when there are no suspect pages" {
            $mock = [PSCustomObject]@{
                SuspectPages = 0
            }
            Assert-SuspectPageCount $mock 
        }
        It "The test should fail when there is even one suspect page" {
            $mock = [PSCustomObject]@{
                SuspectPages = 1
            }
            { Assert-SuspectPageCount $mock } | Should -Throw
        }
        It "The test should fail when there are many suspect pages" {
            $mock = [PSCustomObject]@{
                SuspectPages = 10
            }
            { Assert-SuspectPageCount $mock } | Should -Throw
        }
    }
}
