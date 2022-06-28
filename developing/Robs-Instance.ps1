$Checks = 'XESessionExists','XESessionStopped','XpCmdShellDisabled','WhoIsActiveInstalled','CLREnabled','TraceFlagsNotExpected','TraceFlagsExpected','TwoDigitYearCutoff','MaxDopInstance','ErrorLogCount','ModelDbGrowth','DefaultBackupCompression','SaExist','SaDisabled','SaRenamed','DefaultFilePath','AdHocDistributedQueriesEnabled','AdHocWorkload',  'DefaultTrace', 'OleAutomationProceduresDisabled', 'CrossDBOwnershipChaining', 'ScanForStartupProceduresDisabled', 'RemoteAccessDisabled', 'SQLMailXPsDisabled', 'DAC', 'OLEAutomation'
$Checks = 'ErrorLogCount'

Invoke-PerfAndValidateCheck -Checks $Checks -Verbose 

$show = 'All'
$v4code = Invoke-DbcCheck -SqlInstance $Sqlinstances -SqlCredential $cred -Check $Checks -legacy $true -Show $show -PassThru
# Run v5 checks
$v5code = Invoke-DbcCheck -SqlInstance $Sqlinstances -SqlCredential $cred -Check $Checks -legacy $false -Show $show -PassThru