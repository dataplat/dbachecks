<# It is important to test our test. It really is. 
 # (http://jakubjares.com/2017/12/07/testing-your-environment-tests/)
 #
 #   To be able to do it with Pester one has to keep the test definition and the assertion 
 # in separate files. Write a new test, or modifying an existing one typically involves 
 # modifications to the three related files:
 #
 # /checks/Database.Assertions.ps1                          - where the assertions are defined
 # /checks/Database.Tests.ps1                               - where the assertions are used to check stuff
 # /tests/checks/Database.Assetions.Tests.ps1 (this file)   - where the assertions are unit tests
 #>

$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Write-Host -Object "Running $PSCommandpath" -ForegroundColor Cyan
. "$PSScriptRoot/../../internal/functions/Set-DatabaseForIntegrationTesting.ps1"
. "$PSScriptRoot/../../checks/Database.Assertions.ps1"

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

    Context "Validate database owner is valid check" {
        Mock Get-DbcConfigValue { return "correctlogin1","correctlogin2" } -ParameterFilter { $Name -like "policy.validdbowner.name" }
        Mock Get-DbcConfigValue { return "myExcludedDb" } -ParameterFilter { $Name -like "policy.validdbowner.excludedb" }
        
        $testSettings = Get-SettingsForDatabaseOwnerIsValid

        It "The test should pass when the current owner is one of the expected owners" {
            @(@{ 
                Database="db1"
                CurrentOwner = "correctlogin1" 
            }) | 
            Assert-DatabaseOwnerIsValid $testSettings       
        }
    
        It "The test should pass when the current owner is any of the expected owners" {
            @(@{ 
                Database="db1"
                CurrentOwner = "correctlogin2" 
            }) | 
            Assert-DatabaseOwnerIsValid $testSettings       
        }

        It "The test should pass even if an excluded database has an incorrect owner" {
            @(@{ 
                Database="db1"
                CurrentOwner = "correctlogin1" 
            }, @{
                Database = "myExcludedDb"
                CurrentOwner = "incorrectlogin"
            }) | 
            Assert-DatabaseOwnerIsValid $testSettings
        }
        
        It "The test should fail when the owner is not one of the expected ones" {
            {
                @(@{ 
                    Database="db1"
                    CurrentOwner = "correctlogin1" 
                }, @{ 
                    Database="db2"
                    CurrentOwner = "wronglogin" 
                }) |  
                Assert-DatabaseOwnerIsValid $testSettings
            } | Should -Throw
        }
    }

    Context "Validate database owner is not invalid check" {
        Mock Get-DbcConfigValue { return "invalidlogin1","invalidlogin2" } -ParameterFilter { $Name -like "policy.invaliddbowner.name" }
        Mock Get-DbcConfigValue { return "myExcludedDb" } -ParameterFilter { $Name -like "policy.invaliddbowner.excludedb" }
        
        $testSettings = Get-SettingsForDatabaseOwnerIsNotInvalid

        It "The test should pass when the current owner is not what is invalid" {
            @(@{ 
                Database="db1"
                CurrentOwner = "correctlogin" 
            }) | 
            Assert-DatabaseOwnerIsNotInvalid $testSettings
        }

        It "The test should fail when the current owner is the invalid one" {
            {
                @(@{ 
                    Database="db1"
                    CurrentOwner = "invalidlogin1" 
                }) | 
                Assert-DatabaseOwnerIsNotInvalid $testSettings 
            } | Should -Throw
        }
        
        It "The test should fail when the current owner is any of the invalid ones" {
            {
                @(@{ 
                    Database="db1"
                    CurrentOwner = "invalidlogin2" 
                }) | 
                Assert-DatabaseOwnerIsNotInvalid $testSettings 
            } | Should -Throw
        }

        It "The test should pass when the invalid user is on an excluded database" {
            @(@{ 
                Database="db1"
                CurrentOwner = "correctlogin" 
            },@{ 
                Database="myExcludedDb"
                CurrentOwner = "invalidlogin2" 
            }) | 
            Assert-DatabaseOwnerIsNotInvalid $testSettings 
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

    Context "Validate the suspect pages check" {
        It "The test should pass when there are no suspect pages" {
            @{
                SuspectPages = 0
            } |
            Assert-SuspectPageCount  
        }
        It "The test should fail when there is even one suspect page" {
            {
                @{
                    SuspectPages = 1
                } | 
                Assert-SuspectPageCount 
            } | Should -Throw
        }
        It "The test should fail when there are many suspect pages" {
            {
                @{
                    SuspectPages = 10
                } | 
                Assert-SuspectPageCount 
            } | Should -Throw
        }
    }
}
