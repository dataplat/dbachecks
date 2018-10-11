function Assert-DatabaseMailEnabled {
    param (
        $SQLInstance,
        $DatabaseMailEnabled
    )
   (Get-DbaSpConfigure -SqlInstance $SQLInstance -Name DatabaseMailEnabled).ConfiguredValue -eq 1 | Should -Be $DatabaseMailEnabled -Because 'The Database Mail XPs setting should be set correctly'
}