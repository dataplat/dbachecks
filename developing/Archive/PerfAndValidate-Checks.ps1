## To Test performance - I pull the dbatools docker repo and cd to the samples/stackoverflow Directory

## I changed the ports because I have some of them already running SQL

##     line 17   - "7401:1433"
##     line 34   - "7402:1433"
##     line 52   - "7403:1433"

#then docker compose up -d

# cd to the root of dbachecks and checkout the pesterv5 branch

ipmo ./dbachecks.psd1

#

#$Checks = 'XpCmdShellDisabled','WhoIsActiveInstalled','CLREnabled','TraceFlagsNotExpected','TraceFlagsExpected','TwoDigitYearCutoff','MaxDopInstance','ErrorLogCount','ModelDbGrowth','DefaultBackupCompression','SaExist','SaDisabled','SaRenamed','DefaultFilePath','AdHocDistributedQueriesEnabled','AdHocWorkload',  'DefaultTrace', 'OleAutomationProceduresDisabled', 'CrossDBOwnershipChaining', 'ScanForStartupProceduresDisabled', 'RemoteAccessDisabled', 'SQLMailXPsDisabled', 'DAC', 'OLEAutomation'
$Checks = 'AsymmetricKeySize'

<#
When there are default skips (some of the CIS checks) we need to set the configs and check

Set-DbcConfig skip.security.sadisabled -Value $false
Set-DbcConfig skip.security.sadisabled -Value $true
Get-DbcConfigValue skip.security.sadisabled

Set-DbcConfig skip.security.saexist -Value $false
Set-DbcConfig skip.security.saexist -Value $true
Get-DbcConfigValue skip.security.saexist


Get-DbcConfigValue policy.instancemaxdop.userecommended
Get-DbcConfigValue policy.instancemaxdop.maxdop
Get-DbcConfigValue policy.instancemaxdop.excludeinstance

Set-DbcConfig policy.instancemaxdop.userecommended -Value $false
Set-DbcConfig policy.instancemaxdop.userecommended -Value $true
Set-DbcConfig policy.instancemaxdop.maxdop -Value 0
Set-DbcConfig policy.instancemaxdop.excludeinstance -Value $null
Set-DbcConfig policy.instancemaxdop.excludeinstance -Value 'localhost,7401'

Get-DbcConfigValue policy.traceflags.expected
Get-DbaTraceFlag -SqlInstance $Sqlinstances -SqlCredential $cred
Set-DbcConfig policy.traceflags.expected -Value 1117,1118
Set-DbcConfig policy.traceflags.expected -Value $null

Enable-DbaTraceFlag -SqlInstance $Sqlinstances -SqlCredential $cred -TraceFlag 1117,1118
Disable-DbaTraceFlag -SqlInstance $Sqlinstances -SqlCredential $cred -TraceFlag 1117,1118
Disable-DbaTraceFlag -SqlInstance $Sqlinstances -SqlCredential $cred -TraceFlag 1118

#>

# Load the function below and then you can keep running the checks defined above in v4 and v5 and compare the performance
# You can keep updating the .Tests.ps1 files and rerunning the function without needing to re-import hte module

# If you change any of the functions you WILL need to re-import or better still use a new session

# If you get odd results - or you dont get any checks run

# run the import module and the Invoke Dbc Check with Verbose and that might show you New-Json messing
# with your files or that you are looking in PSMOdulePath instead of Git Repo path (run Reset-dbcConfig to fix that)

function Invoke-PerfAndValidateChecks {
    param($Checks)
    $password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password
    $Sqlinstances = 'localhost,7401', 'localhost,7402', 'localhost,7403'

    $originalCode = {
        $global:v4code = Invoke-DbcCheck -SqlInstance $Sqlinstances -Check $Checks -SqlCredential $cred -legacy $true -Show None -PassThru
    }

    $NewCode = {
        $global:v5code = Invoke-DbcCheck -SqlInstance $Sqlinstances -Check $Checks -SqlCredential $cred -legacy $false  -Show None -PassThru
    }

    $originalCodetrace = Trace-Script -ScriptBlock $originalCode
    $NewCodetrace = Trace-Script -ScriptBlock $NewCode

    $originalCodeMessage = "With original Code it takes {0} MilliSeconds" -f $originalCodetrace.StopwatchDuration.TotalMilliseconds


$savingMessage = "
Running with

{3}

Checks against $($Sqlinstances.Count) SQL Containers

With original Code it takes {1} Seconds
With New Code it takes {4} Seconds

New Code for these {5} checks
is saving {0} seconds
from a run of {1} seconds
New Code runs in {2} % of the time
" -f ('{0:N2}' -f ($originalCodetrace.StopwatchDuration.TotalSeconds - $NewCodetrace.StopwatchDuration.TotalSeconds)),('{0:N2}' -f $originalCodetrace.StopwatchDuration.TotalSeconds),('{0:N2}' -f (($NewCodetrace.StopwatchDuration.TotalSeconds/$originalCodetrace.StopwatchDuration.TotalSeconds) * 100)),($Checks -split ',' -join ',') ,('{0:N2}' -f $NewCodetrace.StopwatchDuration.TotalSeconds), $Checks.Count

Write-PSFMessage -Message $savingMessage -Level Output


##validate we got the right answers too

If (Compare-Object $v5code.Configuration.Filter.Tag.Value $v4code.TagFilter) {
    $Message = "
Uh-Oh - The Tag filters between v4 and v5 are not the same somehow.
For v4 We returned
{0}
and
For v5 we returned
{1}
" -f ($v4code.TagFilter | Out-String), ($v5code.Configuration.Filter.Tag.Value | Out-String)
    Write-PSFMessage -Message $Message -Level Warning
}
else {
    $message = "
The Tags are the same"
    Write-PSFMessage -Message $Message -Level Output
}

If (($v5code.TotalCount - $v5code.NotRunCount) -ne $v4code.TotalCount) {
    $Message = "
Uh-Oh - The total tests run between v4 and v5 are not the same somehow.
For v4 We ran
{0} tests
and
For v5 we ran
{1} tests
The MOST COMMON REASON IS you have used Tags instead of Tag in your Describe block
but TraceFlagsNotExpected will change that also
" -f $v4code.TotalCount, ($v5code.TotalCount - $v5code.NotRunCount)
    Write-PSFMessage -Message $Message -Level Warning
}
else {
    $message = "
The Total Tests Run are the same {0} {1} " -f $v4code.TotalCount, ($v5code.TotalCount - $v5code.NotRunCount)
    Write-PSFMessage -Message $Message -Level Output
}

If ($v5code.PassedCount -ne $v4code.PassedCount) {
    $Message = "
Uh-Oh - The total tests Passed between v4 and v5 are not the same somehow.
For v4 We Passed 
{0} tests
and
For v5 we Passed 
{1} tests
" -f $v4code.PassedCount, $v5code.PassedCount
    Write-PSFMessage -Message $Message -Level Warning
}
else {
    $message = "
The Total Tests Passed are the same {0} {1} " -f $v4code.PassedCount, $v5code.PassedCount
    Write-PSFMessage -Message $Message -Level Output
}


If ($v5code.FailedCount -ne $v4code.FailedCount) {
    $Message = "
Uh-Oh - The total tests Failed between v4 and v5 are not the same somehow.
For v4 We Failed 
{0} tests
and
For v5 we Failed 
{1} tests
" -f $v4code.FailedCount, $v5code.FailedCount
    Write-PSFMessage -Message $Message -Level Warning
}
else {
    $message = "
The Total Tests Failed are the same {0} {1} " -f $v4code.FailedCount, $v5code.FailedCount
    Write-PSFMessage -Message $Message -Level Output
}

If ($v5code.SkippedCount -ne $v4code.SkippedCount) {
    $Message = "
Uh-Oh - The total tests Skipped between v4 and v5 are not the same somehow.
For v4 We Skipped 
{0} tests
and
For v5 we Skipped 
{1} tests
" -f $v4code.SkippedCount, $v5code.SkippedCount
    Write-PSFMessage -Message $Message -Level Warning
}
else {
    $message = "
The Total Tests Skipped are the same {0} {1} "-f $v4code.SkippedCount, $v5code.SkippedCount
    Write-PSFMessage -Message $Message -Level Output
}


}


# $Checks = 'DbaOperator'
Invoke-PerfAndValidateChecks -Checks 'VirtualLogFile'