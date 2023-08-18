# Oslo Demo

./build.ps1 -tasks build

#region setup
$containers = $SQLInstances = $dbachecks1, $dbachecks2, $dbachecks3 = 'dbachecks1', 'dbachecks2', 'dbachecks3'
$password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password
$show = 'All'
#endregion

# lets run a couple of tests

Invoke-DbcCheck -SqlInstance $Sqlinstances -SqlCredential $cred -Check InstanceConnection, DatabaseStatus -legacy $true -Show $show

# that failed but shouldnt have - set config
Set-DbcConfig -Name policy.connection.authscheme -Value SQL

# run again

# what about skips?
Set-DbcConfig -Name skip.connection.remoting -Value $true

# run again

# ok now in v5 mode
Invoke-DbcCheck -SqlInstance $Sqlinstances -SqlCredential $cred -Check InstanceConnection, DatabaseStatus -legacy $false -Show $show

# So much quicker !!!

# show our perf test ????

$Checks = 'ErrorLogCount', 'XESessionExists', 'XESessionStopped', 'XpCmdShellDisabled', 'WhoIsActiveInstalled', 'CLREnabled', 'TwoDigitYearCutoff', 'MaxDopInstance', 'ErrorLogCount', 'ModelDbGrowth', 'DefaultBackupCompression', 'SaExist', 'SaDisabled', 'SaRenamed', 'DefaultFilePath', 'AdHocDistributedQueriesEnabled', 'AdHocWorkload', 'DefaultTrace', 'OleAutomationProceduresDisabled', 'CrossDBOwnershipChaining', 'ScanForStartupProceduresDisabled', 'RemoteAccessDisabled', 'SQLMailXPsDisabled', 'DAC', 'OLEAutomation', 'ServerNameMatch', 'OrphanedFile', 'MaxMemory', 'NetworkLatency', 'PublicPermission'

Invoke-PerfAndValidateCheck -Checks $Checks

# question turn off a container adn talk about hte fails?