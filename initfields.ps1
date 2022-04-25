
# We run Pester V4 here because the -legacy parameter of Invoke-DbcCheck is set to true by default
$password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password

$Sqlinstances = 'localhost,7401', 'localhost,7402', 'localhost,7403'
$smos = Connect-DbaInstance -SqlInstance $Sqlinstances -SqlCredential $cred 

$Fields2000_Db = 'Collation', 'CompatibilityLevel', 'CreateDate', 'ID', 'IsAccessible', 'IsFullTextEnabled', 'IsSystemObject', 'IsUpdateable', 'LastBackupDate', 'LastDifferentialBackupDate', 'LastLogBackupDate', 'Name', 'Owner', 'ReadOnly', 'RecoveryModel', 'ReplicationOptions', 'Status', 'Version'
$Fields200x_Db = $Fields2000_Db + @('BrokerEnabled', 'DatabaseSnapshotBaseName', 'IsMirroringEnabled', 'Trustworthy')
$Fields201x_Db = $Fields200x_Db + @('ActiveConnections', 'AvailabilityDatabaseSynchronizationState', 'AvailabilityGroupName', 'ContainmentType', 'EncryptionEnabled')

$Fields2000_Login = 'CreateDate', 'DateLastModified', 'DefaultDatabase', 'DenyWindowsLogin', 'IsSystemObject', 'Language', 'LanguageAlias', 'LoginType', 'Name', 'Sid', 'WindowsLoginAccessType'
$Fields200x_Login = $Fields2000_Login + @('AsymmetricKey', 'Certificate', 'Credential', 'ID', 'IsDisabled', 'IsLocked', 'IsPasswordExpired', 'MustChangePassword', 'PasswordExpirationEnabled', 'PasswordPolicyEnforced')
$Fields201x_Login = $Fields200x_Login + @('PasswordHashAlgorithm')

#see #7753
$Fields_Job = 'LastRunOutcome', 'CurrentRunStatus', 'CurrentRunStep', 'CurrentRunRetryAttempt', 'NextRunScheduleID', 'NextRunDate', 'LastRunDate', 'JobType', 'HasStep', 'HasServer', 'CurrentRunRetryAttempt', 'HasSchedule', 'Category', 'CategoryID', 'CategoryType', 'OperatorToEmail', 'OperatorToNetSend', 'OperatorToPage'


$initFieldsDb = New-Object System.Collections.Specialized.StringCollection
$initFieldsLogin = New-Object System.Collections.Specialized.StringCollection
$initFieldsJob = New-Object System.Collections.Specialized.StringCollection

foreach ($smo in $smos[0]) {
    $smo.SetDefaultInitFields($false)
    $smo.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database], $false)
    $smo.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Login], $false)
    $smo.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.Job], $false)
    $initfields = $smo.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Server])
    $initfields.Add("BackupDirectory")
    $smo.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Server], $initfields)

    $smo | Fl
}
foreach ($smo in $smos[0]) {
    $smo | Fl
}
$smo.GetDefaultInitFields($smo.Gettype())
$smo.GetDefaultInitFields($smo.Columns.Gettype())
$scriptBlock = { 
    Import-Module Pester
    Invoke-Pester
}
Trace-Script -ScriptBlock $scriptBlock


.BackupDirectory
$initfields = $server.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Server])
$initfields.Add("BackupDirectory")
$server.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Server], $initfields)





$flag = @{ _profiler = $true }
Invoke-Script -ScriptBlock $scriptBlock -Preheat 0 -Repeat 3 -Flag $flag