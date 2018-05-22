function Assert-DatabaseMaxDop {
    Param(
        [pscustomobject]$MaxDop,
        [int]$MaxDopValue
    )   
    $MaxDop.DatabaseMaxDop | Should -Be $MaxDopValue -Because "We expect the Database MaxDop Value $($MaxDop.DatabaseMaxDop) to be the specified value $MaxDopValue"
}