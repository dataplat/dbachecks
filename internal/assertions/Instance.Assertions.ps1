function Assert-InstanceMaxDop {
    Param(
        [string]$Instance,
        [switch]$UseRecommended,
        [int]$MaxDopValue
    )
    $MaxDop = @(Test-DbaMaxDop -SqlInstance $Instance)[0]
    if ($UseRecommended) {
        #if UseRecommended - check that the CurrentInstanceMaxDop property returned from Test-DbaMaxDop matches the the RecommendedMaxDop property
        $MaxDop.CurrentInstanceMaxDop | Should -Be $MaxDop.RecommendedMaxDop -Because "We expect the MaxDop Setting $($MaxDop.CurrentInstanceMaxDop) to be the recommended value $($MaxDop.RecommendedMaxDop)"
    }
    else {
        #if not UseRecommended - check that the CurrentInstanceMaxDop property returned from Test-DbaMaxDop matches the MaxDopValue parameter
        $MaxDop.CurrentInstanceMaxDop | Should -Be $MaxDopValue -Because "We expect the MaxDop Setting $($MaxDop.CurrentInstanceMaxDop) to be $MaxDopValue"
    }
}

function Assert-BackupCompression {
    Param($Instance,$defaultbackupcompression)
    (Get-DbaSpConfigure -SqlInstance $Instance -ConfigName 'DefaultBackupCompression').ConfiguredValue -eq 1 | Should -Be $defaultbackupcompression -Because 'The default backup compression should be set correctly'
}
