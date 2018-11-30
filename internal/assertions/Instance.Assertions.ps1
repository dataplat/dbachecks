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
    Param($Instance, $defaultbackupcompression)
    (Get-DbaSpConfigure -SqlInstance $Instance -ConfigName 'DefaultBackupCompression').ConfiguredValue -eq 1 | Should -Be $defaultbackupcompression -Because 'The default backup compression should be set correctly'
}

function Assert-TempDBSize {
    Param($Instance)

    @((Get-DbaDbFile -SqlInstance $Instance -Database tempdb).Where{$_.Type -eq 0}.Size.Megabyte |Select-Object -Unique).Count | Should -Be 1 -Because "We want all the tempdb data files to be the same size - See https://blogs.sentryone.com/aaronbertrand/sql-server-2016-tempdb-fixes/ and https://www.brentozar.com/blitz/tempdb-data-files/ for more information"
}

function Assert-InstanceSupportedBuild {
    Param(
        [string]$Instance,
        [int]$BuildWarning,
        [string]$BuildBehind,
        [DateTime]$Date
    )
    #If $BuildBehind check against SP/CU parameter to determine validity of the build
    if ($BuildBehind) {
        $results = Test-DbaSQLBuild -SqlInstance $Instance -MaxBehind $BuildBehind
        $Compliant = $results.Compliant
        $Build = $results.build
        $Compliant | Should -Be $true -Because "this build $Build should not be behind the required build"
        #If no $BuildBehind only check against support dates
    }
    else {
        $Results = Test-DbaSQLBuild -SqlInstance $Instance -Latest
        [DateTime]$SupportedUntil = Get-Date $results.SupportedUntil -Format O
        $Build = $results.build
        #If $BuildWarning, check for support date within the warning window
        if ($BuildWarning) {
            [DateTime]$expected = Get-Date ($Date).AddMonths($BuildWarning) -Format O
            $SupportedUntil | Should -BeGreaterThan $expected -Because "this build $Build will be unsupported by Microsoft on $(Get-Date $SupportedUntil -Format O) which is less than $BuildWarning months away"
        }
        #If neither, check for Microsoft support date
        else {
            $SupportedUntil | Should -BeGreaterThan $Date -Because "this build $Build is now unsupported by Microsoft"
        }
    }
}

function Assert-TwoDigitYearCutoff {
    Param(
        [string]$Instance,
        [int]$TwoDigitYearCutoff
    )
    (Get-DbaSpConfigure -SqlInstance $Instance -ConfigName 'TwoDigitYearCutoff').ConfiguredValue | Should -Be $TwoDigitYearCutoff -Because 'This is the value that you have chosen for Two Digit Year Cutoff configuration'
}

function Assert-TraceFlag {
    Param(
        [string]$SQLInstance,
        [int[]]$ExpectedTraceFlag
    )
    if($null -eq $ExpectedTraceFlag){
        $a = (Get-DbaTraceFlag -SqlInstance $SQLInstance).TraceFlag
        (Get-DbaTraceFlag -SqlInstance $SQLInstance).TraceFlag  | Should -BeNullOrEmpty -Because "We expect that there will be no Trace Flags set on $SQLInstance"
    }
    else {
        @($ExpectedTraceFlag).ForEach{
            (Get-DbaTraceFlag -SqlInstance $SQLInstance).TraceFlag  | Should -Contain $PSItem -Because "We expect that Trace Flag $PsItem will be set on $SQLInstance"
        }
    }
}
function Assert-NotTraceFlag {
    Param(
        [string]$SQLInstance,
        [int[]]$NotExpectedTraceFlag
    )

    if($null -eq $NotExpectedTraceFlag){
        (Get-DbaTraceFlag -SqlInstance $SQLInstance).TraceFlag  | Should -BeNullOrEmpty -Because "We expect that there will be no Trace Flags set on $SQLInstance"
    }
    else {
        @($NotExpectedTraceFlag).ForEach{
            (Get-DbaTraceFlag -SqlInstance $SQLInstance).TraceFlag  | Should -Not -Contain $PSItem -Because "We expect that Trace Flag $PsItem will not be set on $SQLInstance"
        }
    }
}

function Assert-CLREnabled {
    param (
        $SQLInstance,
        $CLREnabled
    )

    (Get-DbaSpConfigure -SqlInstance $SQLInstance -Name IsSqlClrEnabled).ConfiguredValue -eq 1 | Should -Be $CLREnabled -Because 'The CLR Enabled should be set correctly'
}
function Assert-CrossDBOwnershipChaining {
    param (
        $SQLInstance,
        $CrossDBOwnershipChaining
    )
   (Get-DbaSpConfigure -SqlInstance $SQLInstance -Name CrossDBOwnershipChaining).ConfiguredValue -eq 1 | Should -Be $CrossDBOwnershipChaining -Because 'The Cross Database Ownership Chaining setting should be set correctly'
}
function Assert-AdHocDistributedQueriesEnabled {
    param (
        $SQLInstance,
        $AdHocDistributedQueriesEnabled
    )
   (Get-DbaSpConfigure -SqlInstance $SQLInstance -Name AdHocDistributedQueriesEnabled).ConfiguredValue -eq 1 | Should -Be $AdHocDistributedQueriesEnabled -Because 'The AdHoc Distributed Queries Enabled setting should be set correctly'
}
function Assert-XpCmdShellDisabled {
    param (
        $SQLInstance,
        $XpCmdShellDisabled
    )
   (Get-DbaSpConfigure -SqlInstance $SQLInstance -Name XPCmdShellEnabled).ConfiguredValue -eq 0 | Should -Be $XpCmdShellDisabled -Because 'The XP CmdShell setting should be set correctly'
}

function Assert-ErrorLogCount {
    param (
        $SQLInstance,
        $errorLogCount
    )
    (Get-DbaErrorLogConfig -SqlInstance $SQLInstance).LogCount | Should -BeGreaterOrEqual $errorLogCount -Because "prevents quicker rollovers."
}


