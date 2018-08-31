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

	if ($BuildBehind) {
        $results = Test-DbaSQLBuild -SqlInstance $Instance -MaxBehind $BuildBehind
        $SupportedUntil = Get-Date $results.SupportedUntil -Format O
        $expected = ($Date).AddMonths($BuildWarning)
        It "$Instance's build is supported by Microsoft" {
            $results.SupportedUntil | Should -BeGreaterThan $Date -Because "this build $($Results.Build) is now unsupported by Microsoft"
        }
        It "$Instance's build is supported by Microsoft within the warning window of $BuildWarning months" {
		    $results.SupportedUntil | Should -BeGreaterThan $expected -Because "this build $($results.Build) will be unsupported by Microsoft on $SupportedUntil which is less than $BuildWarning months away"
        }
        It "$Instance's build is not behind the latest build by more than $BuildBehind" {
            $results.Compliant | Should -Be $true -Because "this build $($Results.Build) should not be behind the required build"
        }
	#If no $BuildBehind only check against support dates
     }	else {
        $Results = Test-DbaSQLBuild -SqlInstance $Instance -Latest
        $SupportedUntil = Get-Date $results.SupportedUntil -Format O
        $expected = ($Date).AddMonths($BuildWarning)
        It "$Instance's build is supported by Microsoft" {
            $Results.SupportedUntil | Should -BeGreaterThan $Date -Because "this build $($Results.Build) is now unsupported by Microsoft"
        }
        It "$Instance's build is supported by Microsoft within the warning window of $BuildWarning months" {
            $Results.SupportedUntil | Should -BeGreaterThan $expected -Because "this build $($results.Build) will be unsupported by Microsoft on $SupportedUntil which is less than $BuildWarning months away"
        }
    }
}