$Checks = 'ErrorLogCount', 'XESessionRunningAllowed','XESessionRunning','XESessionRunningAllowed', 'XESessionExists','XESessionStopped','XpCmdShellDisabled','WhoIsActiveInstalled','CLREnabled','TraceFlagsNotExpected','TraceFlagsExpected','TwoDigitYearCutoff','MaxDopInstance','ErrorLogCount','ModelDbGrowth','DefaultBackupCompression','SaExist','SaDisabled','SaRenamed','DefaultFilePath','AdHocDistributedQueriesEnabled','AdHocWorkload',  'DefaultTrace', 'OleAutomationProceduresDisabled', 'CrossDBOwnershipChaining', 'ScanForStartupProceduresDisabled', 'RemoteAccessDisabled', 'SQLMailXPsDisabled', 'DAC', 'OLEAutomation'
$Checks = 'XESessionRunningAllowed'
$Checks = 'ErrorLogCount'

Invoke-PerfAndValidateCheck -Checks $Checks 

$password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password
$show = 'All'

$v4code = Invoke-DbcCheck -SqlInstance $Sqlinstances -SqlCredential $cred -Check $Checks -legacy $true -Show $show -PassThru
# Run v5 checks
$v5code = Invoke-DbcCheck -SqlInstance $Sqlinstances -SqlCredential $cred -Check $Checks -legacy $false -Show $show -PassThru  -Verbose

Set-DbcConfig -Name policy.xevent.requiredrunningsession -Value system_health 
Set-DbcConfig -Name policy.xevent.requiredrunningsession -Value system_health ,AlwaysOn_health
Set-DbcConfig -Name policy.xevent.requiredrunningsession -Value system_health ,AlwaysOn_health,QuickSessionStandard

Set-DbcConfig -Name policy.xevent.validrunningsession -Value  system_health ,AlwaysOn_health
Set-DbcConfig -Name policy.xevent.validrunningsession -Value AlwaysOn_health