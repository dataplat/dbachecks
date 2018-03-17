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