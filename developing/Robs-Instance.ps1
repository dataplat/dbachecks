./build.ps1 -Tasks build

$Checks = 'ErrorLogCount', 'XESessionExists', 'XESessionStopped', 'XpCmdShellDisabled', 'WhoIsActiveInstalled', 'CLREnabled', 'TwoDigitYearCutoff', 'MaxDopInstance', 'ErrorLogCount', 'ModelDbGrowth', 'DefaultBackupCompression', 'SaExist', 'SaDisabled', 'SaRenamed', 'DefaultFilePath', 'AdHocDistributedQueriesEnabled', 'AdHocWorkload', 'DefaultTrace', 'OleAutomationProceduresDisabled', 'CrossDBOwnershipChaining', 'ScanForStartupProceduresDisabled', 'RemoteAccessDisabled', 'SQLMailXPsDisabled', 'DAC', 'OLEAutomation', 'ServerNameMatch', 'OrphanedFile', 'MaxMemory', 'NetworkLatency', 'PublicRolePermission'

$Checks = 'XESessionRunningAllowed', 'XESessionRunning', 'XESessionRunningAllowed', 'XESessionExists', 'XESessionStopped', 'XpCmdShellDisabled'
$Checks = 'TraceFlagsNotExpected', 'TraceFlagsExpected'
$Checks = 'ServerNameMatch'
$Checks = 'BackupPathAccess'
$Checks = 'LatestBuild'
$Checks = 'NetworkLatency'
$Checks = 'LinkedServerConnection'
$Checks = 'MaxMemory'
$Checks = 'OrphanedFile'
$Checks = 'MemoryDump'
$Checks = 'HideInstance'
$Checks = 'LoginAuditFailed'
$Checks = 'LoginAuditSuccessful'
$Checks = 'LoginCheckPolicy'
$Checks = 'SuspectPageLimit'
$Checks = 'SupportedBuild'
$Checks = 'LoginMustChange'
$Checks = 'LoginAuditSuccessful', 'LoginAuditFailed'
Set-DbcConfig -Name skip.security.PublicPermission -Value $false
$Checks = 'PublicRolePermission'
$Checks = 'PUblicPermission'

Invoke-PerfAndValidateCheck -Checks $Checks
Invoke-PerfAndValidateCheck -Checks $Checks -PerfDetail
$containers = $SQLInstances = $dbachecks1, $dbachecks2, $dbachecks3 = 'dbachecks1', 'dbachecks2', 'dbachecks3'
$password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password
$show = 'All'

$v4code = Invoke-DbcCheck -SqlInstance $Sqlinstances -SqlCredential $cred -Check $Checks -legacy $true -Show $show -PassThru -verbose
# Run v5 checks
$v5code = Invoke-DbcCheck -SqlInstance $Sqlinstances -SqlCredential $cred -Check $Checks -legacy $false -Show $show -PassThru -Verbose

Set-DbcConfig -Name policy.xevent.requiredrunningsession -Value system_health
Set-DbcConfig -Name policy.xevent.requiredrunningsession -Value system_health , AlwaysOn_health
Set-DbcConfig -Name policy.xevent.requiredrunningsession -Value system_health , AlwaysOn_health, QuickSessionStandard

Set-DbcConfig -Name policy.xevent.validrunningsession -Value system_health , AlwaysOn_health
Set-DbcConfig -Name policy.xevent.validrunningsession -Value AlwaysOn_health


$SQLInstances = $dbachecks1, $dbachecks2, $dbachecks3 = 'dbachecks1', 'dbachecks2', 'dbachecks3'
$password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password
$show = 'All'

$traci = Trace-Script -ScriptBlock {
    $v5code = Invoke-DbcCheck -SqlInstance $Sqlinstances -SqlCredential $cred -Check $Checks -legacy $false -Show $show -PassThru
}
$traci1 = Trace-Script -ScriptBlock {
    $v5code = Invoke-DbcCheck -SqlInstance $Sqlinstances -SqlCredential $cred -Check $Checks -legacy $false -Show $show -PassThru
}
$traci = Trace-Script -ScriptBlock {
    $v4code = Invoke-DbcCheck -SqlInstance $Sqlinstances -SqlCredential $cred -Check $Checks -legacy $true -Show $show -PassThru
}

Invoke-DbcCheck -SqlInstance $Sqlinstances -SqlCredential $cred -Check failsafeoperator -legacy $false -Show $show -verbose