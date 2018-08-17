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

function Assert-InstanceSupportedBuild {
	Param(
        [string]$Instance,
		[int]$BuildWarning,
		[string]$BehindValue
	)

	if ($BehindValue) {
        #If $BehindValue check against SP/CU parameter to determine validity of the build in addition to support dates
		$results = Test-DbaSQLBuild -SqlInstance $Instance -MaxBehind $BehindValue
		$results.SupportedUntil | Should -BeGreaterThan (Get-Date) -Because "this build is now unsupported by Microsoft"
		$results.SupportedUntil | Should -BeGreaterThan (Get-Date).AddMonths($BuildWarning) -Because "this build will soon be unsupported by Microsoft"
		$results.Compliant | Should -Be $true -Because "this build should not be behind the required build"
		
	}	else {
		#If no $BehindValue only check against support dates
        $SupportedUntil = (Test-DbaSQLBuild -SqlInstance $Instance -Latest).SupportedUntil 
		$SupportedUntil | Should -BeGreaterThan (Get-Date) -Because "this build is now unsupported by Microsoft"
		$SupportedUntil | Should -BeGreaterThan (Get-Date).AddMonths($BuildWarning) -Because "this build will soon be unsupported by Microsoft"
    }
}