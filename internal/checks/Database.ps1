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
