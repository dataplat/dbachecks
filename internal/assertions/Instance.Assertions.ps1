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

function Assert-TempDBSize {
    Param($Instance)

    @((Get-DbaDatabaseFile -SqlInstance $Instance -Database tempdb).Where{$_.Type -eq 0}.Size.Megabyte |Select-Object -Unique).Count | Should -Be 1 -Because "We want all the tempdb data files to be the same size - See https://blogs.sentryone.com/aaronbertrand/sql-server-2016-tempdb-fixes/ and https://www.brentozar.com/blitz/tempdb-data-files/ for more information"
}

function Assert-InstanceSupportedBuild {
	Param(
        
        [string]$Instance,
		[int]$BuildWarning,
        [string]$BuildBehind,
        [DateTime]$Date
    )
    #If $BuildBehind check against SP/CU parameter to determine validity of the build in addition to support dates
 	if ($BuildBehind) {
        $results = Test-DbaSQLBuild -SqlInstance $Instance -MaxBehind $BuildBehind
        $SupportedUntil = Get-Date $results.SupportedUntil -Format O
        $expected = ($Date).AddMonths($BuildWarning)
		$results.SupportedUntil | Should -BeGreaterThan $Date -Because "this build $($Results.Build) is now unsupported by Microsoft"
		$results.SupportedUntil | Should -BeGreaterThan $expected -Because "this build $($results.Build) will be unsupported by Microsoft on $SupportedUntil which is less than $BuildWarning months away"
		$results.Compliant | Should -Be $true -Because "this build $($Results.Build) should not be behind the required build"
	#If no $BuildBehind only check against support dates
     }	else {
        $Results = Test-DbaSQLBuild -SqlInstance $Instance -Latest
        $SupportedUntil = Get-Date $results.SupportedUntil -Format O
        $expected = ($Date).AddMonths($BuildWarning)
		$Results.SupportedUntil | Should -BeGreaterThan $Date -Because "this build $($Results.Build) is now unsupported by Microsoft"
        $Results.SupportedUntil | Should -BeGreaterThan $expected -Because "this build $($results.Build) will be unsupported by Microsoft on $SupportedUntil which is less than $BuildWarning months away"
    }
}
function Assert-TwoDigitYearCutoff {
    Param(
        [string]$Instance,
        [int]$TwoDigitYearCutoff
    )
    (Get-DbaSpConfigure -SqlInstance $Instance -ConfigName 'TwoDigitYearCutoff').ConfiguredValue | Should -Be $defaulTwoDigitYearCutofftbackupcompression -Because 'This is the value that you have chosen for Two Digit Year Cutoff configuration'
}