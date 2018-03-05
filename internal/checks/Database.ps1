function Assert-DatabaseCollationsMatch {
    param (
        [object]$TestObject,
        [string]$Because
    )
    $TestObject.ServerCollation | Should -Be $TestObject.DatabaseCollation -Because $because
}