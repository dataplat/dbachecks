. "$PSScriptRoot/../../assertions/Database.RecoveryModel.ps1"

Describe "Testing Recovery Model Assertion" -Tags RecoveryModel {
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
}
