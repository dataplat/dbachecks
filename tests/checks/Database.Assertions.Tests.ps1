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
        Mock Get-DbcConfigValue { return "mySpecialDbWithUniqueCollation" } -ParameterFilter { $Name -like "policy.database.wrongcollation" }
        
        $testSettings = Get-SettingsForDatabaseCollactionCheck

        It "The test should pass when the database is not on the exclusion list and the collations match" {
            @{
                Database = "db1"
                ServerCollation = "collation1"
                DatabaseCollation = "collation1"
            } |
            Assert-DatabaseCollation -With $testSettings
        }

        It "The test should pass when the database is on the exclusion list and the collations do not match" {
            @{
                Database = "mySpecialDbWithUniqueCollation"
                ServerCollation = "collation1"
                DatabaseCollation = "collation2"
            } |
            Assert-DatabaseCollation -With $testSettings
        }

        It "The test should pass when the database is ReportingServer and the collations do not match" {
            @{
                Database = "mySpecialDbWithUniqueCollation"
                ServerCollation = "collation1"
                DatabaseCollation = "collation2"
            } |
            Assert-DatabaseCollation -With $testSettings
        }

        It "The test should fail when the database is not on the exclusion list and the collations do not match" {
            {
                @{
                    Database = "db1"
                    ServerCollation = "collation1"
                    DatabaseCollation = "collation2"
                } |
                Assert-DatabaseCollation -With $testSettings
            } | Should -Throw
        }

        It "The test should pass when excluded datbase collation does not matche the instance collation" {
            @{
                Database = "mySpecialDbWithUniqueCollation"
                ServerCollation = "collation1"
                DatabaseCollation = "collation2"
            } |
            Assert-DatabaseCollation -With $testSettings
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
            Assert-DatabaseOwnerIsValid -With $testSettings       
        }
    
        It "The test should pass when the current owner is any of the expected owners" {
            @(@{ 
                Database="db1"
                CurrentOwner = "correctlogin2" 
            }) | 
            Assert-DatabaseOwnerIsValid -With $testSettings       
        }

        It "The test should pass even if an excluded database has an incorrect owner" {
            @(@{ 
                Database="db1"
                CurrentOwner = "correctlogin1" 
            }, @{
                Database = "myExcludedDb"
                CurrentOwner = "incorrectlogin"
            }) | 
            Assert-DatabaseOwnerIsValid -With $testSettings
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
                Assert-DatabaseOwnerIsValid -With $testSettings
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
            Assert-DatabaseOwnerIsNotInvalid -With $testSettings
        }

        It "The test should fail when the current owner is the invalid one" {
            {
                @(@{ 
                    Database="db1"
                    CurrentOwner = "invalidlogin1" 
                }) | 
                Assert-DatabaseOwnerIsNotInvalid -With $testSettings 
            } | Should -Throw
        }
        
        It "The test should fail when the current owner is any of the invalid ones" {
            {
                @(@{ 
                    Database="db1"
                    CurrentOwner = "invalidlogin2" 
                }) | 
                Assert-DatabaseOwnerIsNotInvalid -With $testSettings 
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
            Assert-DatabaseOwnerIsNotInvalid -With $testSettings 
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
