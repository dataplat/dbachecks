function Assert-DatabaseCollationsMatch {
    param (
        [object]$TestObject,
        [string]$Because
    )
    $TestObject.ServerCollation | Should -Be $TestObject.DatabaseCollation -Because $because
}

function Assert-SuspectPageCount {
    param (
        [object]$TestObject,
        [string]$Because
    )
    $TestObject.SuspectPages | Should -Be 0 -Because $Because
}

function Assert-DatabaseOwnerIs {
    param (
        [object]$TestObject,
        [string]$ExpectedOwner,
        [string]$Because
    )
    $TestObject.CurrentOwner | Should -Be $ExpectedOwner -Because $Because
}

function Assert-DatabaseOwnerIsNot {
    param (
        [object]$TestObject,
        [string]$InvalidOwner,
        [string]$Because
    )
    $TestObject.CurrentOwner | Should -Not -Be $InvalidOwner -Because $Because
}
