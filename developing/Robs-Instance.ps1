$Checks = 'ErrorLogCount', 'TraceFlagsNotExpected', 'TraceFlagsExpected', 'XESessionRunningAllowed', 'XESessionRunning', 'XESessionRunningAllowed', 'XESessionExists', 'XESessionStopped', 'XpCmdShellDisabled', 'WhoIsActiveInstalled', 'CLREnabled', 'TwoDigitYearCutoff', 'MaxDopInstance', 'ErrorLogCount', 'ModelDbGrowth', 'DefaultBackupCompression', 'SaExist', 'SaDisabled', 'SaRenamed', 'DefaultFilePath', 'AdHocDistributedQueriesEnabled', 'AdHocWorkload', 'DefaultTrace', 'OleAutomationProceduresDisabled', 'CrossDBOwnershipChaining', 'ScanForStartupProceduresDisabled', 'RemoteAccessDisabled', 'SQLMailXPsDisabled', 'DAC', 'OLEAutomation'

$Checks = 'XESessionRunningAllowed', 'XESessionRunning', 'XESessionRunningAllowed', 'XESessionExists', 'XESessionStopped', 'XpCmdShellDisabled'
$Checks = 'TraceFlagsNotExpected', 'TraceFlagsExpected'

Invoke-PerfAndValidateCheck -Checks $Checks
Invoke-PerfAndValidateCheck -Checks $Checks -PerfDetail
$containers = $SQLInstances = $dbachecks1, $dbachecks2, $dbachecks3 = 'dbachecks1', 'dbachecks2', 'dbachecks3'
$password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password
$show = 'All'

$v4code = Invoke-DbcCheck -SqlInstance $Sqlinstances -SqlCredential $cred -Check $Checks -legacy $true -Show $show -PassThru
# Run v5 checks
$v5code = Invoke-DbcCheck -SqlInstance $Sqlinstances -SqlCredential $cred -Check $Checks -legacy $false -Show $show -PassThru -Verbose

Set-DbcConfig -Name policy.xevent.requiredrunningsession -Value system_health
Set-DbcConfig -Name policy.xevent.requiredrunningsession -Value system_health , AlwaysOn_health
Set-DbcConfig -Name policy.xevent.requiredrunningsession -Value system_health , AlwaysOn_health, QuickSessionStandard

Set-DbcConfig -Name policy.xevent.validrunningsession -Value system_health , AlwaysOn_health
Set-DbcConfig -Name policy.xevent.validrunningsession -Value AlwaysOn_health

$traci = Trace-Script -ScriptBlock {
    $v5code = Invoke-DbcCheck -SqlInstance $Sqlinstances -SqlCredential $cred -Check $Checks -legacy $false -Show $show -PassThru
}