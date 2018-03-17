<# It is important to test our test. It really is. 
 # (http://jakubjares.com/2017/12/07/testing-your-environment-tests/)
 #
 #   To be able to do it with Pester one has to keep the test definition and the assertion 
 # in separate files. Write a new test, or modifying an existing one typically involves 
 # modifications to the three related files:
 #
 # /checks/Database.Assertions.ps1 (this file)      - where the assertions are defined
 # /checks/Database.Tests.ps1                       - where the assertions are used to check stuff
 # /tests/checks/Test.Database.Tests.ps1            - where the assertions are unit tests
 #>
function Assert-DatabaseCollationsMatch {
    param (
        [object]$TestObject,
        [string]$Because
    )
    $TestObject.ServerCollation | Should -Be $TestObject.DatabaseCollation -Because $because
}

function Assert-DatabaseCollationsMismatch {
    param (
        [object]$TestObject,
        [string]$Because
    )
    $TestObject.ServerCollation | Should -Not -Be $TestObject.DatabaseCollation -Because $because
}

function Assert-DatabaseOwnerIs {
    param (
        [object]$TestObject,
        [string[]]$ExpectedOwner,
        [string]$Because
    )
    $TestObject.CurrentOwner | Should -BeIn $ExpectedOwner -Because $Because
}

function Assert-DatabaseOwnerIsNot {
    param (
        [object]$TestObject,
        [string[]]$InvalidOwner,
        [string]$Because
    )
    $TestObject.CurrentOwner | Should -Not -BeIn $InvalidOwner -Because $Because
}

function Assert-RecoveryModel {
    param (
        [object]$TestObject,
        [string]$ExpectedRecoveryModel,
        [string]$Because
    )
    $TestObject.RecoveryModel | Should -Be $ExpectedRecoveryModel -Because $Because
}

function Assert-SuspectPageCount {
    param (
        [object]$TestObject,
        [string]$Because
    )
    $TestObject.SuspectPages | Should -Be 0 -Because $Because
}