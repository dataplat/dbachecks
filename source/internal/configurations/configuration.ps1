# Fred magic
#Set-PSFConfig -Handler { if (Get-PSFTaskEngineCache -Module dbachecks -Name module-imported) { Write-PSFMessage -Level Warning -Message "This setting will only take effect on the next console start" } }

#Add some validation for values with limited options
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidAssignmentToAutomaticVariable', 'input')]
$LogFileComparisonValidationssb = { param ([string]$input) if ($input -in ('average', 'maximum')) { [PsCustomObject]@{Success = $true; value = $input } } else {
        [PsCustomObject]@{Success = $false; message = "must be average or maximum - $input" }
    } }
Register-PSFConfigValidation -Name validation.LogFileComparisonValidations -ScriptBlock $LogFileComparisonValidationssb
$EmailValidationSb = {
    param ([string]$input)
    $EmailRegEx = "^\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$"
    if (($input -match $EmailRegEx) -or -not ($input) ) {
        [PsCustomObject]@{Success = $true; value = $input }
    } else {
        [PsCustomObject]@{Success = $false; message = "does not appear to be an email address - $input" }
    }
}
Register-PSFConfigValidation -Name validation.EmailValidation -ScriptBlock $EmailValidationSb


# some configs to help with autocompletes and other module level stuff
#apps
$defaultRepo = Join-Path -Path $script:ModuleRoot -ChildPath checks
Set-PSFConfig -Module dbachecks -Name app.checkrepos -Value @($defaultRepo) -Initialize -Description "Where Pester tests/checks are stored"
Set-PSFConfig -Module dbachecks -Name app.sqlinstance -Value $null -Initialize -Description "List of SQL Server instances that SQL-based tests will run against"
Set-PSFConfig -Module dbachecks -Name app.computername -Value $null -Initialize -Description "List of Windows Servers that Windows-based tests will run against"
Set-PSFConfig -Module dbachecks -Name app.sqlcredential -Value $null -Initialize -Description "The universal SQL credential if Trusted/Windows Authentication is not used"
Set-PSFConfig -Module dbachecks -Name app.wincredential -Value $null -Initialize -Description "The universal Windows if default Windows Authentication is not used"

if ($IsLinux) {
    Set-PSFConfig -Module dbachecks -Name app.localapp -Value "$home/dbachecks" -Initialize -Description "Persisted files live here"
    Set-PSFConfig -Module dbachecks -Name app.maildirectory -Value "$home/dbachecks/dbachecks.mail" -Initialize -Description "Files for mail are stored here"
} else {
    Set-PSFConfig -Module dbachecks -Name app.localapp -Value "$env:localappdata\dbachecks" -Initialize -Description "Persisted files live here"
    Set-PSFConfig -Module dbachecks -Name app.maildirectory -Value "$env:localappdata\dbachecks\dbachecks.mail" -Initialize -Description "Files for mail are stored here"
}

Set-PSFConfig -Module dbachecks -Name app.cluster -Value $null -Initialize -Description "One host name for each cluster for the HADR checks"

# Policy Configs

#instance
Set-PSFConfig -Module dbachecks -Name policy.instance.sqlenginestart -Value 'Automatic' -Initialize -Description "The expected start type of the SQL Engine Service - Automatic, Manual, Disabled - Defaults to Automatic"
Set-PSFConfig -Module dbachecks -Name policy.instance.sqlenginestate -Value 'Running' -Initialize -Description "The expected state of the SQL Engine Service - Running, Stopped - Defaults to Running"
Set-PSFConfig -Module dbachecks -Name policy.instance.memorydumpsdaystocheck -Value $null -Initialize -Description "The number of days to go back and check for memory dumps"

#Storage
Set-PSFConfig -Module dbachecks -Name policy.storage.backuppath -Value $null -Initialize -Description "Enables tests to check if servers have access to centralized backup location"

#Backup
Set-PSFConfig -Module dbachecks -Name policy.backup.testserver -Value $null -Initialize -Description "Destination server for backuptests"
Set-PSFConfig -Module dbachecks -Name policy.backup.datadir -Value $null -Initialize -Description "Destination server data directory"
Set-PSFConfig -Module dbachecks -Name policy.backup.logdir -Value $null -Initialize -Description "Destination server log directory"
Set-PSFConfig -Module dbachecks -Name policy.backup.fullmaxdays -Value 7 -Initialize -Description "Maximum number of days before Full Backups are considered outdated"
Set-PSFConfig -Module dbachecks -Name policy.backup.diffmaxhours -Value 25 -Initialize -Description "Maximum number of hours before Diff Backups are considered outdated"
Set-PSFConfig -Module dbachecks -Name policy.backup.logmaxminutes -Value 15 -Initialize -Description "Maximum number of minutes before Log Backups are considered outdated"
Set-PSFConfig -Module dbachecks -Name policy.backup.newdbgraceperiod -Value 0 -Initialize -Description "The number of hours a newly created database is allowed to not have backups"
Set-PSFConfig -Module dbachecks -Name policy.backup.defaultbackupcompression -Validation bool -Value $true -Initialize -Description "Default Backup Compression should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.security.clrenabled -Validation bool -Value $false -Initialize -Description "CLR Enabled should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.security.crossdbownershipchaining -Validation bool -Value $false -Initialize -Description "Cross Database Ownership Chaining should be disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.security.databasemailenabled -Validation bool -Value $false -Initialize -Description "Database Mail XPs should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.security.adhocdistributedqueriesenabled -Validation bool -Value $false -Initialize -Description "Ad Hoc Distributed Queries should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.security.xpcmdshelldisabled -Validation bool -Value $true -Initialize -Description "XP CmdShell should be disabled `$true or enabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.security.oleautomationproceduresdisabled -Validation bool -Value $true -Initialize -Description "OLE Automation Procedures should be disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.security.remoteaccessdisabled -Value 0 -Initialize -Description "Remote Access should be disabled 0"
Set-PSFConfig -Module dbachecks -Name policy.security.scanforstartupproceduresdisabled -Validation bool -Value $true -Initialize -Description "Scan For Startup Procedures disabled `$true or enabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.security.latestbuild -Validation bool -Value $true -Initialize -Description "SQL Server should have the latest SQL build (service packs/CUs) installed"
Set-PSFConfig -Module dbachecks -Name policy.security.containedbautoclose -Validation bool -Value $false -Initialize -Description "Contained databases should have auto close enabled"

#diskspce
Set-PSFConfig -Module dbachecks -Name policy.diskspace.percentfree -Value 20 -Initialize -Description "Percent disk free"

#DBCC
Set-PSFConfig -Module dbachecks -Name policy.dbcc.maxdays -Value 7 -Initialize -Description "Maximum number of days before DBCC CHECKDB is considered outdated"

#Encryption
Set-PSFConfig -Module dbachecks -Name policy.certificateexpiration.excludedb -Value @('master', 'msdb', 'model', 'tempdb') -Initialize -Description "Databases to exclude from expired certificate checks"
Set-PSFConfig -Module dbachecks -Name policy.certificateexpiration.warningwindow -Value 1 -Initialize -Description "The number of months prior to a certificate being expired that you want warning about"

#Identity
Set-PSFConfig -Module dbachecks -Name policy.identity.usagepercent -Value 90 -Initialize -Description "Maximum percentage of max of identity column"

#Network
Set-PSFConfig -Module dbachecks -Name policy.network.latencymaxms -Value 40 -Initialize -Description "Max network latency average"

#Recovery Model
Set-PSFConfig -Module dbachecks -Name policy.recoverymodel.type -Value "Full" -Initialize -Description "Standard recovery model"
Set-PSFConfig -Module dbachecks -Name policy.recoverymodel.excludedb -Value @('master', 'tempdb') -Initialize -Description "Databases to exclude from standard recovery model check"

#Logins
Set-PSFConfig -Module dbachecks -Name policy.adloginuser.excludecheck -Value "" -Initialize -Description "Active Directory User logins to exclude from test."
Set-PSFConfig -Module dbachecks -Name policy.adlogingroup.excludecheck -Value "" -Initialize -Description "Active Directory Groups logins to exclude from test."

#DBOwners
Set-PSFConfig -Module dbachecks -Name policy.validdbowner.name -Value "sa" -Initialize -Description "The database owner account should be this user"
Set-PSFConfig -Module dbachecks -Name policy.validdbowner.excludedb -Value @('master', 'msdb', 'model', 'tempdb') -Initialize -Description "Databases to exclude from valid dbowner checks"
Set-PSFConfig -Module dbachecks -Name policy.invaliddbowner.name -Value "sa" -Initialize -Description "The database owner account should not be this user"
Set-PSFConfig -Module dbachecks -Name policy.invaliddbowner.excludedb -Value @('master', 'msdb', 'model', 'tempdb') -Initialize -Description "Databases to exclude from invalid dbowner checks"

#Error Log
Set-PSFConfig -Module dbachecks -Name policy.errorlog.warningwindow -Value 2 -Initialize -Description "The number of days prior to check for error log issues"
Set-PSFConfig -Module dbachecks -Name policy.errorlog.logcount -Value -1 -Initialize -Description "The minimum number of error log files that should be configured. -1 means off/default"

#DAC
Set-PSFConfig -Module dbachecks -Name policy.dacallowed -Validation bool -Value $true -Initialize -Description "DAC should be allowed `$true or disallowed `$false"

#OLE Automation
Set-PSFConfig -Module dbachecks -Name policy.oleautomation -Validation bool -Value $false -Initialize -Description "OLE Automation should be enabled `$true or disabled `$false"

#Two Digit Year Cutoff
Set-PSFConfig -Module dbachecks -Name policy.twodigityearcutoff -Value 2049 -Initialize -Description "The value for 'Two Digit Year Cutoff' configuration. Default is 2049. "

#Connectivity
Set-PSFConfig -Module dbachecks -Name policy.connection.authscheme -Value "Kerberos" -Initialize -Description "Auth requirement (Kerberos, NTLM, etc)"
Set-PSFConfig -Module dbachecks -Name policy.connection.pingmaxms -Value 10 -Initialize -Description "Maximum response time in ms"
Set-PSFConfig -Module dbachecks -Name policy.connection.pingcount -Value 3 -Initialize -Description "Number of times to ping a server to establish average response time"

#HADR
Set-PSFConfig -Module dbachecks -Name policy.hadr.agtcpport -Value "" -Initialize -Description "The TCPPort for the HADR listener check"
Set-PSFConfig -Module dbachecks -Name policy.hadr.tcpport -Value "1433" -Initialize -Description "The TCPPort for the HADR replica check"
Set-PSFConfig -Module dbachecks -Name policy.hadr.endpointname -Value "Hadr_Endpoint" -Initialize -Description "The name for the HADR Endpoint check"
Set-PSFConfig -Module dbachecks -Name policy.hadr.endpointport -Value 5022 -Initialize -Description "The TCPPort for the HADR endpoint check"
Set-PSFConfig -Module dbachecks -Name policy.hadr.failureconditionlevel -Value 3 -Initialize -Description "Availability Group flexible automatic failover policy for the HADR cluster check"
Set-PSFConfig -Module dbachecks -Name policy.hadr.healthchecktimeout -Value 30000 -Initialize -Description "Availability Group healthcheck timeout for the HADR cluster check"
Set-PSFConfig -Module dbachecks -Name policy.hadr.leasetimeout -Value 20000 -Initialize -Description "Availability Group Lease timeout for the HADR cluster check"
Set-PSFConfig -Module dbachecks -Name policy.hadr.sessiontimeout -Value 10 -Initialize -Description "Availability Group Replica Session timeout for the HADR replica check"
Set-PSFConfig -Module dbachecks -Name policy.cluster.NetworkProtocolsIPV4 -Value @('Internet Protocol Version 4 (TCP/IPv4)', 'Client for Microsoft Networks', 'File and Printer Sharing for Microsoft Networks') -Initialize -Description "Minimum Private Cluster Network protocols for the HADR Cluster check"
Set-PSFConfig -Module dbachecks -Name policy.cluster.hostrecordttl -Value 1200 -Initialize -Description "Cluster Network Resource - HostRecordTTL for the HADR Cluster check"
Set-PSFConfig -Module dbachecks -Name policy.cluster.registerallprovidersIP -Value 0 -Initialize -Description "Cluster Network Resource - RegisterAllProvidersIP for the HADR Cluster check"

#Dump Files
Set-PSFConfig -Module dbachecks -Name policy.dump.maxcount -Value 1 -Initialize -Description "Maximum number of expected dumps"

#pageverify
Set-PSFConfig -Module dbachecks -Name policy.pageverify -Value "Checksum" -Initialize -Description "Page verify option should be set to this value"

# InstanceMaxDop
Set-PSFConfig -Module dbachecks -Name policy.instancemaxdop.userecommended -Value $false -Initialize -Description "Use the recommendation from Test-DbaMaxDop to test the Max DOP settings - If set to false the value in policy.instancemaxdop.maxdop is used"
Set-PSFConfig -Module dbachecks -Name policy.instancemaxdop.maxdop -Value 0 -Initialize -Description "The value for the Instance Level MaxDop Settings we expect"
Set-PSFConfig -Module dbachecks -Name policy.instancemaxdop.excludeinstance -Value @() -Initialize -Description "Any Instances to exclude from checking Instance Level MaxDop - Useful if your estate contains SQL instances supporting Sharepoint for example"

# Database
Set-PSFConfig -Module dbachecks -Name policy.database.autoclose -Validation bool -Value $false -Initialize -Description "Auto Close should be allowed `$true or disallowed `$false"
Set-PSFConfig -Module dbachecks -Name policy.database.autoshrink -Validation bool -Value $false -Initialize -Description "Auto Shrink should be allowed `$true or disallowed `$false"
Set-PSFConfig -Module dbachecks -Name policy.database.maxvlf -Value 512 -Initialize -Description "Max virtual log files"
Set-PSFConfig -Module dbachecks -Name policy.database.autocreatestatistics -Validation bool -Value $true -Initialize -Description "Auto Create Statistics should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.database.autoupdatestatistics -Validation bool -Value $true -Initialize -Description "Auto Update Statistics should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.database.autoupdatestatisticsasynchronously -Validation bool -Value $false -Initialize -Description "Auto Update Statistics Asynchronously should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.database.filegrowthexcludedb -Value @() -Initialize -Description "Databases to exclude from the file growth check"
Set-PSFConfig -Module dbachecks -Name policy.database.filegrowthtype -Value "kb" -Initialize -Description "Growth Type should be 'kb' or 'percent'"
Set-PSFConfig -Module dbachecks -Name policy.database.filegrowthvalue -Value 65535 -Initialize -Description "The auto growth value (in kb) should be equal or higher than this value. Example: A value of 65535 means at least 64MB. "
Set-PSFConfig -Module dbachecks -Name policy.database.logfilecount -Value 1 -Initialize -Description "The number of Log files expected on a database"
Set-PSFConfig -Module dbachecks -Name policy.database.logfilesizepercentage -Value 100 -Initialize -Description "Maximum percentage of Data file Size that logfile is allowed to be."
Set-PSFConfig -Module dbachecks -Name policy.database.logfilesizecomparison -Validation validation.logfilecomparisonvalidations -Value 'average' -Initialize -Description "How to compare data and log file size, options are maximum or average"
Set-PSFConfig -Module dbachecks -Name policy.database.filebalancetolerance -Value 5 -Initialize -Description "Percentage for Tolerance for checking for balanced files in a filegroups"
Set-PSFConfig -Module dbachecks -Name policy.database.filegrowthfreespacethreshold -Value 20 -Initialize -Description "Integer representing percentage of free space within a database file before warning"
Set-PSFConfig -Module dbachecks -Name policy.database.wrongcollation -Value @('ReportingServer', 'ReportingServerTempDB') -Initialize -Description "Databases that doesnt match server collation check"
Set-PSFConfig -Module dbachecks -Name policy.database.maxdopexcludedb -Value @() -Initialize -Description "Database Names that we don't want to check for maxdop"
Set-PSFConfig -Module dbachecks -Name policy.database.maxdop -Value 0 -Initialize -Description "The value for the database maxdop that we expect"
Set-PSFConfig -Module dbachecks -Name policy.database.status.excludereadonly -Value @() -Initialize -Description "Database names that we expect to be readonly"
Set-PSFConfig -Module dbachecks -Name policy.database.status.excludeoffline -Value @() -Initialize -Description "Database names that we expect to be offline"
Set-PSFConfig -Module dbachecks -Name policy.database.status.excluderestoring -Value @() -Initialize -Description "Database names that we expect to be restoring"
Set-PSFConfig -Module dbachecks -Name database.querystoreenabled.excludedb -Value @('model', 'tempdb', 'master') -Initialize -Description "A List of databases that we do not want to check for Query Store enabled"
Set-PSFConfig -Module dbachecks -Name database.querystoredisabled.excludedb -Value @('model', 'tempdb', 'master') -Initialize -Description "A List of databases that we do not want to check for Query Store disabled"
Set-PSFConfig -Module dbachecks -Name database.compatibilitylevel.excludedb -Value @() -Initialize -Description "A list of databases that we do not want to check compatibility level"
Set-PSFConfig -Module dbachecks -Name database.guestuser.excludedb -Value @('master', 'tempdb', 'msdb') -Initialize -Description "A list of databases that we do not want to check guest user connect permissions for"

Set-PSFConfig -Module dbachecks -Name policy.database.filegrowthdaystocheck -Value $null -Initialize -Description "The number of days to go back to check for growth events"
Set-PSFConfig -Module dbachecks -Name policy.database.trustworthyexcludedb -Value @('msdb') -Initialize -Description "A List of databases that we do not want to check for Trustworthy being on"
Set-PSFConfig -Module dbachecks -Name policy.database.duplicateindexexcludedb -Value @('msdb', 'ReportServer', 'ReportServerTempDB') -Initialize -Description "A List of databases we do not want to check for Duplicate Indexes"
Set-PSFConfig -Module dbachecks -Name policy.database.clrassembliessafeexcludedb -Value @() -Initialize -Description "A List of database that we do not want to check for SAFE CLR Assemblies"
Set-PSFConfig -Module dbachecks -Name policy.database.containeddbautocloseexclude -Value @('msdb') -Initialize -Description "A List of contained database that we we do not want to check for autoclose"
Set-PSFConfig -Module dbachecks -Name policy.database.logfilepercentused -Value 75 -Initialize -Description " The % log used we should stay below"

# Policy for Ola Hallengren Maintenance Solution
Set-PSFConfig -Module dbachecks -Name policy.ola.installed -Validation bool -Value $true -Initialize -Description "Checks to see if Ola Hallengren solution is installed"
Set-PSFConfig -Module dbachecks -Name policy.ola.database -Validation string -Value 'master' -Initialize -Description "The database where Ola's maintenance solution is installed"
Set-PSFConfig -Module dbachecks -Name policy.ola.systemfullenabled -Validation bool -Value $true -Initialize -Description "Ola's Full System Database Backup should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.ola.userfullenabled -Validation bool -Value $true -Initialize -Description "Ola's Full User Database Backup should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.ola.userdiffenabled -Validation bool -Value $true -Initialize -Description "Ola's Diff User Database Backup should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.ola.userlogenabled -Validation bool -Value $true -Initialize -Description "Ola's Log User Database Backup should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.ola.systemfullscheduled -Validation bool -Value $true -Initialize -Description "Ola's Full System Database Backup should be scheduled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.ola.userfullscheduled -Validation bool -Value $true -Initialize -Description "Ola's Full User Database Backup should be scheduled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.ola.userdiffscheduled -Validation bool -Value $true -Initialize -Description "Ola's Diff User Database Backup should be scheduled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.ola.userlogscheduled -Validation bool -Value $true -Initialize -Description "Ola's Log User Database Backup should be scheduled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.ola.systemfullretention -Value 192 -Initialize -Description "Ola's Full System Database Backup retention number of hours"
Set-PSFConfig -Module dbachecks -Name policy.ola.userfullretention -Value 192 -Initialize -Description "Ola's Full User Database Backup retention number of hours"
Set-PSFConfig -Module dbachecks -Name policy.ola.userdiffretention -Value 192 -Initialize -Description "Ola's Diff User Database Backup retention number of hours"
Set-PSFConfig -Module dbachecks -Name policy.ola.userlogretention -Value 192 -Initialize -Description "Ola's Log User Database Backup retention number of hours"
Set-PSFConfig -Module dbachecks -Name policy.ola.CommandLogenabled -Validation bool -Value $true -Initialize -Description "Ola's CommandLog Cleanup should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.ola.CommandLogscheduled -Validation bool -Value $true -Initialize -Description "Ola's CommandLog Cleanup should be scheduled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.ola.CommandLogCleanUp -Value 30 -Initialize -Description "Ola's CommandLog Cleanup setting should be this many days"
Set-PSFConfig -Module dbachecks -Name policy.ola.SystemIntegrityCheckenabled -Validation bool -Value $true -Initialize -Description "Ola's System Database Integrity should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.ola.SystemIntegrityCheckscheduled -Validation bool -Value $true -Initialize -Description "Ola's System Database Integrity should be scheduled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.ola.UserIntegrityCheckenabled -Validation bool -Value $true -Initialize -Description "Ola's User Database Integrity should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.ola.UserIntegrityCheckscheduled -Validation bool -Value $true -Initialize -Description "Ola's User Database Integrity should be scheduled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.ola.UserIndexOptimizeenabled -Validation bool -Value $true -Initialize -Description "Ola's User Index Optimization should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.ola.UserIndexOptimizescheduled -Validation bool -Value $true -Initialize -Description "Ola's User Index Optimization should be scheduled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.ola.OutputFileCleanupenabled -Validation bool -Value $true -Initialize -Description "Ola's Output File Cleanup should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.ola.OutputFileCleanupscheduled -Validation bool -Value $true -Initialize -Description "Ola's Output File Cleanup should be scheduled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.ola.OutputFileCleanUp -Value 30 -Initialize -Description "Ola's OutputFile Cleanup setting should be this many days"
Set-PSFConfig -Module dbachecks -Name policy.ola.DeleteBackupHistoryenabled -Validation bool -Value $true -Initialize -Description "Ola's Delete Backup History should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.ola.DeleteBackupHistoryscheduled -Validation bool -Value $true -Initialize -Description "Ola's Delete Backup History should be scheduled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.ola.DeleteBackupHistoryCleanUp -Value 30 -Initialize -Description "Ola's Delete Backup History Cleanup setting should be this many days"
Set-PSFConfig -Module dbachecks -Name policy.ola.PurgeJobHistoryenabled -Validation bool -Value $true -Initialize -Description "Ola's Purge Job History should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.ola.PurgeJobHistoryscheduled -Validation bool -Value $true -Initialize -Description "Ola's Purge Job History should be scheduled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.ola.PurgeJobHistoryCleanUp -Value 30 -Initialize -Description "Ola's Purge Backup History Cleanup setting should be this many days"
Set-PSFConfig -Module dbachecks -Name ola.JobName.SystemFull -Value 'DatabaseBackup - SYSTEM_DATABASES - FULL' -Initialize -Description "The name for the Ola System Full Job"
Set-PSFConfig -Module dbachecks -Name ola.JobName.UserFull -Value 'DatabaseBackup - USER_DATABASES - FULL' -Initialize -Description "The name for the Ola User Full Job"
Set-PSFConfig -Module dbachecks -Name ola.JobName.UserDiff -Value 'DatabaseBackup - USER_DATABASES - DIFF' -Initialize -Description "The name for the Ola User Diff Job"
Set-PSFConfig -Module dbachecks -Name ola.JobName.UserLog -Value 'DatabaseBackup - USER_DATABASES - Log' -Initialize -Description "The name for the Ola User Log Job"
Set-PSFConfig -Module dbachecks -Name ola.JobName.CommandLogCleanup -Value 'CommandLog Cleanup' -Initialize -Description "The name for the Ola CommandLog Cleanup Job"
Set-PSFConfig -Module dbachecks -Name ola.JobName.SystemIntegrity -Value 'DatabaseIntegrityCheck - SYSTEM_DATABASES' -Initialize -Description "The name for the Ola System Integrity Job"
Set-PSFConfig -Module dbachecks -Name ola.JobName.UserIntegrity -Value 'DatabaseIntegrityCheck - USER_DATABASES' -Initialize -Description "The name for the Ola User Integrity Job"
Set-PSFConfig -Module dbachecks -Name ola.JobName.UserIndex -Value 'IndexOptimize - USER_DATABASES' -Initialize -Description "The name for the Ola User Index Job"
Set-PSFConfig -Module dbachecks -Name ola.JobName.OutputFileCleanup -Value 'Output File Cleanup' -Initialize -Description "The name for the Ola Output File Cleanup Job"
Set-PSFConfig -Module dbachecks -Name ola.JobName.DeleteBackupHistory -Value 'sp_delete_backuphistory' -Initialize -Description "The name for the Ola Delete Backup History Job"
Set-PSFConfig -Module dbachecks -Name ola.JobName.PurgeBackupHistory -Value 'sp_purge_jobhistory' -Initialize -Description "The name for the Ola Delete Purge History Job"

# xevents
Set-PSFConfig -Module dbachecks -Name policy.xevent.requiredexists -Value $null -Initialize -Description "List of XE Sessions that should exist. This does not check if they are running"
Set-PSFConfig -Module dbachecks -Name policy.xevent.validrunningsession -Value $null -Initialize -Description "List of XE Sessions that can be be running."
Set-PSFConfig -Module dbachecks -Name policy.xevent.requiredrunningsession -Value $null -Initialize -Description "List of XE Sessions that should be running."
Set-PSFConfig -Module dbachecks -Name policy.xevent.requiredstoppedsession -Value $null -Initialize -Description "List of XE Sessions that should not be running."

# sp_WhoIsActive
Set-PSFConfig -Module dbachecks -Name policy.whoisactive.database -Value "master" -Initialize -Description "Which database should contain the sp_WhoIsActive stored procedure"

#Build
Set-PSFConfig -Module dbachecks -Name policy.build.warningwindow -Value 6 -Initialize -Description "The number of months prior to a build being unsupported that you want warning about"
Set-PSFConfig -Module dbachecks -Name policy.build.behind -Value $null -Initialize -Description "The max number of service packs or cumulative updates a build can be behind by (ex. 1SP or 3CU). Null by default."

# The frequency of the Ola Hallengrens User Full backups
# See https://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.smo.agent.jobschedule.frequencyinterval.aspx
# for full options
# 1 for Sunday 127 for every day

# exclude databases
Set-PSFConfig -Module dbachecks -Name policy.asymmetrickeysize.excludedb -Value @('master', 'msdb', 'tempdb') -Initialize -Description "Databases to exclude from asymmetric key size checks"
Set-PSFConfig -Module dbachecks -Name policy.autoclose.excludedb -Value @() -Initialize -Description "Databases to exclude from autoclose key size checks"
Set-PSFConfig -Module dbachecks -Name policy.autoshrink.excludedb -Value @() -Initialize -Description "Databases to exclude from autoclose key size checks"
Set-PSFConfig -Module dbachecks -Name policy.vlf.excludedb -Value @('master', 'msdb', 'tempdb', 'model') -Initialize -Description "Databases to exclude from asymmetric key size checks"
Set-PSFConfig -Module dbachecks -Name policy.logfilecount.excludedb -Value @() -Initialize -Description "Databases to exclude from log file count checks"
Set-PSFConfig -Module dbachecks -Name policy.autocreatestats.excludedb -Value @() -Initialize -Description "Databases to exclude from the auto create stats checks"
Set-PSFConfig -Module dbachecks -Name policy.autoupdatestats.excludedb -Value @() -Initialize -Description "Databases to exclude from the auto update stats checks"
Set-PSFConfig -Module dbachecks -Name policy.autoupdatestatisticsasynchronously.excludedb -Value @() -Initialize -Description "Databases to exclude from the auto update stats asynchronously checks"
Set-PSFConfig -Module dbachecks -Name policy.database.statusexcludedb -Value @() -Initialize -Description "Databases to exclude from the database status checks"
Set-PSFConfig -Module dbachecks -Name policy.database.symmetrickeyencryptionlevelexcludedb -Value @('master', 'msdb', 'tempdb') -Initialize -Description "Databases to exclude from the Symmetric Key Encryption Level checks"



# skips - these are for whole checks that should not run by default or internal commands that can't be skipped using ExcludeTag
# instance
Set-PSFConfig -Module dbachecks -Name skip.instance.memorydump -Validation bool -Value $false -Initialize -Description "Skip the memory dump check"
Set-PSFConfig -Module dbachecks -Name skip.instance.modeldbgrowth -Validation bool -Value $false -Initialize -Description "Skip the model database growth settings check"
Set-PSFConfig -Module dbachecks -Name skip.instance.defaulttrace -Validation bool -Value $false -Initialize -Description "Skip the default trace check"
Set-PSFConfig -Module dbachecks -Name skip.instance.dac -Validation bool -Value $false -Initialize -Description "Skip Dedicated Administrator Connection (DAC) check"
Set-PSFConfig -Module dbachecks -Name skip.instance.CrossDBOwnershipChaining -Validation bool -Value $false -Initialize -Description "Skip Cross Database Ownership Chaining check"
Set-PSFConfig -Module dbachecks -Name skip.instance.SQLMailXPsDisabled -Validation bool -Value $false -Initialize -Description "Skip SQL Mail XPs Disabled check"
Set-PSFConfig -Module dbachecks -Name skip.instance.oleautomation -Validation bool -Value $false -Initialize -Description "Skip OLE Automation check"
Set-PSFConfig -Module dbachecks -Name skip.instance.oleautomationproceduresdisabled -Validation bool -Value $false -Initialize -Description "Skip OLE Automation Procedures check"
Set-PSFConfig -Module dbachecks -Name skip.instance.remoteaccessdisabled -Validation bool -Value $false -Initialize -Description "Skip the remote access check"
Set-PSFConfig -Module dbachecks -Name skip.instance.scanforstartupproceduresdisabled -Validation bool -Value $false -Initialize -Description "Skip the scan for startup procedures disabled check"
Set-PSFConfig -Module dbachecks -Name skip.instance.latestbuild -Validation bool -Value $false -Initialize -Description "Skip the scan the latest build of SQL Server check"
Set-PSFConfig -Module dbachecks -Name skip.instance.suspectpagelimit -Validation bool -Value $false -Initialize -Description "Skip the check for whether the suspect_pages table is nearing the row limit of 1000"
Set-PSFConfig -Module dbachecks -Name skip.instance.AdHocWorkload -Validation bool -Value $false -Initialize -Description "Skip the check for whether AdHocWorkload Optimization is enabled"
Set-PSFConfig -Module dbachecks -Name skip.instance.AdHocDistributedQueriesEnabled -Validation bool -Value $false -Initialize -Description "Skip the check for whether AdHoc Distributed Queries Enabled settings"
Set-PSFConfig -Module dbachecks -Name skip.instance.DefaultFilePath -Validation bool -Value $false -Initialize -Description "Skip the check for Default File Path"
Set-PSFConfig -Module dbachecks -Name skip.instance.SaRenamed -Validation bool -Value $false -Initialize -Description "Skip the check for Sa Renamed"
Set-PSFConfig -Module dbachecks -Name skip.security.sadisabled -Validation bool -Value $true -Initialize -Description "Skip the check for if the sa login is disabled"
Set-PSFConfig -Module dbachecks -Name skip.security.saexist -Validation bool -Value $true -Initialize -Description "Skip the check for a login named sa does not exist"
Set-PSFConfig -Module dbachecks -Name skip.instance.DefaultBackupCompression -Validation bool -Value $false -Initialize -Description "Skip the check for default backup compression"
Set-PSFConfig -Module dbachecks -Name skip.instance.ErrorLogCount -Validation bool -Value $false -Initialize -Description "Skip the check for the number of Error Log Entries"
Set-PSFConfig -Module dbachecks -Name skip.instance.MaxDopInstance -Validation bool -Value $false -Initialize -Description "Skip the check for the Max Dop Instance"
Set-PSFConfig -Module dbachecks -Name skip.instance.TwoDigitYearCutoff -Validation bool -Value $false -Initialize -Description "Skip the check for the Two Digit Year Cut off setting"
Set-PSFConfig -Module dbachecks -Name skip.instance.TraceFlagsExpected -Validation bool -Value $false -Initialize -Description "Skip the check for expected Trace Flags"
Set-PSFConfig -Module dbachecks -Name skip.instance.TraceFlagsNotExpected -Validation bool -Value $false -Initialize -Description "Skip the check for not expected Trace Flags"
Set-PSFConfig -Module dbachecks -Name skip.instance.CLREnabled -Validation bool -Value $false -Initialize -Description "Skip the check for CLR Enabled"
Set-PSFConfig -Module dbachecks -Name skip.instance.WhoIsActiveInstalled -Validation bool -Value $false -Initialize -Description "Skip the check for whether WhoIsActive is Installed"
Set-PSFConfig -Module dbachecks -Name skip.instance.XpCmdShellDisabled -Validation bool -Value $false -Initialize -Description "Skip the check for whether XpCmdShell is Disabled"
Set-PSFConfig -Module dbachecks -Name skip.instance.XESessionStopped -Validation bool -Value $false -Initialize -Description "Skip the check for XESessions that are stopped"
Set-PSFConfig -Module dbachecks -Name skip.instance.XESessionRunning -Validation bool -Value $false -Initialize -Description "Skip the check for XESessions that should be running"
Set-PSFConfig -Module dbachecks -Name skip.instance.XESessionRunningAllowed -Validation bool -Value $false -Initialize -Description "Skip the check for XESessions that are allowed to be running"
Set-PSFConfig -Module dbachecks -Name skip.instance.errorlogentries -Validation bool -Value $false -Initialize -Description "Skip the check for errorlog entries"
Set-PSFConfig -Module dbachecks -Name skip.instance.tempdb -Validation bool -Value $false -Initialize -Description "Skip all the checks for the tempdb database"
Set-PSFConfig -Module dbachecks -Name skip.instance.BackupPathAccess -Validation bool -Value $false -Initialize -Description "Skip the check for the backup path access check"
Set-PSFConfig -Module dbachecks -Name skip.instance.networklatency -Validation bool -Value $false -Initialize -Description "Skip the check for network latency"
Set-PSFConfig -Module dbachecks -Name skip.instance.linkedserverconnection -Validation bool -Value $false -Initialize -Description "Skip the check for linked server connection"
Set-PSFConfig -Module dbachecks -Name skip.instance.maxmemory -Validation bool -Value $false -Initialize -Description "Skip the check for max memory"
Set-PSFConfig -Module dbachecks -Name skip.instance.orphanedfile -Validation bool -Value $false -Initialize -Description "Skip the check for orphaned file"
Set-PSFConfig -Module dbachecks -Name skip.instance.servernamematch -Validation bool -Value $false -Initialize -Description "Skip the check for server name match"
Set-PSFConfig -Module dbachecks -Name skip.instance.supportedbuild -Validation bool -Value $false -Initialize -Description "Skip the checks for supported build"




Set-PSFConfig -Module dbachecks -Name skip.dbcc.datapuritycheck -Validation bool -Value $false -Initialize -Description "Skip data purity check in last good dbcc command"
Set-PSFConfig -Module dbachecks -Name skip.backup.testing -Validation bool -Value $true -Initialize -Description "Don't run Test-DbaLastBackup by default (it's not read-only)"
Set-PSFConfig -Module dbachecks -Name skip.backup.readonly -Validation bool -Value $false -Initialize -Description "Check read-only databases for last backup"
Set-PSFConfig -Module dbachecks -Name skip.backup.secondaries -Validation bool -Value $false -Initialize -Description "Check hadr secondary databases for last backup"
Set-PSFConfig -Module dbachecks -Name skip.tempdb1118 -Validation bool -Value $false -Initialize -Description "Don't run test for Trace Flag 1118"
Set-PSFConfig -Module dbachecks -Name skip.tempdbfilecount -Validation bool -Value $false -Initialize -Description "Don't run test for Temp Database File Count"
Set-PSFConfig -Module dbachecks -Name skip.tempdbfilegrowthpercent -Validation bool -Value $false -Initialize -Description "Don't run test for Temp Database File Growth in Percent"
Set-PSFConfig -Module dbachecks -Name skip.tempdbfilesonc -Validation bool -Value $false -Initialize -Description "Don't run test for Temp Database Files on C"
Set-PSFConfig -Module dbachecks -Name skip.tempdbfilesizemax -Validation bool -Value $false -Initialize -Description "Don't run test for Temp Database Files Max Size"
Set-PSFConfig -Module dbachecks -Name skip.connection.remoting -Validation bool -Value $false -Initialize -Description "Skip PowerShell remoting check for connectivity"
Set-PSFConfig -Module dbachecks -Name skip.connection.ping -Validation bool -Value $false -Initialize -Description "Skip the ping check for connectivity"
Set-PSFConfig -Module dbachecks -Name skip.connection.auth -Validation bool -Value $false -Initialize -Description "Skip the authenticaton scheme check for connectivity"
Set-PSFConfig -Module dbachecks -Name skip.connection -Validation bool -Value $false -Initialize -Description "Skip the connection checks"
Set-PSFConfig -Module dbachecks -Name skip.datafilegrowthdisabled -Validation bool -Value $true -Initialize -Description "Skip validation of datafiles which have growth value equal to zero."
Set-PSFConfig -Module dbachecks -Name skip.logfilecounttest -Validation bool -Value $false -Initialize -Description "Skip the logfilecount test"
Set-PSFConfig -Module dbachecks -Name skip.diffbackuptest -Validation bool -Value $false -Initialize -Description "Skip the Differential backup test"
Set-PSFConfig -Module dbachecks -Name skip.database.filegrowthdisabled -Validation bool -Value $true -Initialize -Description "Skip validation of datafiles which have growth value equal to zero."
Set-PSFConfig -Module dbachecks -Name skip.database.logfilecounttest -Validation bool -Value $false -Initialize -Description "Skip the logfilecount test"
Set-PSFConfig -Module dbachecks -Name skip.database.validdatabaseowner -Validation bool -Value $false -Initialize -Description "Skip the valid database owner test"
Set-PSFConfig -Module dbachecks -Name skip.database.invaliddatabaseowner -Validation bool -Value $false -Initialize -Description "Skip the invalid database owner test"
Set-PSFConfig -Module dbachecks -Name skip.database.databasecollation -Validation bool -Value $false -Initialize -Description "Skip the database collation test"
Set-PSFConfig -Module dbachecks -Name skip.database.suspectpage -Validation bool -Value $false -Initialize -Description "Skip the suspect pages test"
Set-PSFConfig -Module dbachecks -Name skip.database.autoclose -Validation bool -Value $false -Initialize -Description "Skip the autoclose test"
Set-PSFConfig -Module dbachecks -Name skip.database.vlf -Validation bool -Value $false -Initialize -Description "Skip the virtual log file test"
Set-PSFConfig -Module dbachecks -Name skip.database.autocreatestatistics -Validation bool -Value $false -Initialize -Description "Skip the auto create statistics test"
Set-PSFConfig -Module dbachecks -Name skip.database.autoupdatestatistics -Validation bool -Value $false -Initialize -Description "Skip the auto update statistics test"
Set-PSFConfig -Module dbachecks -Name skip.database.autoupdatestatisticsasynchronously -Validation bool -Value $false -Initialize -Description "Skip the auto update statistics asynchronously test"
Set-PSFConfig -Module dbachecks -Name skip.database.trustworthy -Validation bool -Value $false -Initialize -Description "Skip the trustworthy database test"
Set-PSFConfig -Module dbachecks -Name skip.database.status -Validation bool -Value $false -Initialize -Description "Skip the database status test"
Set-PSFConfig -Module dbachecks -Name skip.database.compatibilitylevel -Validation bool -Value $false -Initialize -Description "Skip the database compatibility test"


Set-PSFConfig -Module dbachecks -Name skip.logshiptesting -Validation bool -Value $false -Initialize -Description "Skip the logshipping test"

Set-PSFConfig -Module dbachecks -Name skip.cluster.netclusterinterface -Validation bool -Value $false -Initialize -Description "Skip cluster private network interface checks"
Set-PSFConfig -Module dbachecks -Name skip.hadr.listener.pingcheck -Validation bool -Value $false -Initialize -Description "Skip the HADR listener ping test (especially useful for Azure and AWS)"
Set-PSFConfig -Module dbachecks -Name skip.hadr.listener.tcpport -Validation bool -Value $false -Initialize -Description "Skip the HADR AG Listener TCP port number (If port number is not standard across the entire AG architecture)"
Set-PSFConfig -Module dbachecks -Name skip.hadr.replica.tcpport -Validation bool -Value $false -Initialize -Description "Skip the HADR Replica TCP port number (If port number is not standard across the entire AG architecture)"
Set-PSFConfig -Module dbachecks -Name skip.hadr.listener.pingcheck -Validation bool -Value $false -Initialize -Description "Skip the HADR listener ping test (especially useful for Azure and AWS)"

Set-PSFConfig -Module dbachecks -Name skip.agent.databasemailenabled -Validation bool -Value $false -Initialize -Description "Skip the Database Mail Enabled agent check"
Set-PSFConfig -Module dbachecks -Name skip.agent.servicestartmode -Validation bool -Value $false -Initialize -Description "Skip the Agent Service State check"
Set-PSFConfig -Module dbachecks -Name skip.agent.servicestate -Validation bool -Value $false -Initialize -Description "Skip the Agent Service Start Mode check"
Set-PSFConfig -Module dbachecks -Name skip.agent.operatorname -Validation bool -Value $false -Initialize -Description "Skip the Agent Operator Name check"
Set-PSFConfig -Module dbachecks -Name skip.agent.operatoremail -Validation bool -Value $false -Initialize -Description "Skip the Agent Operator Email check"
Set-PSFConfig -Module dbachecks -Name skip.agent.longrunningjobs -Validation bool -Value $false -Initialize -Description "Skip the long running agent jobs check"
Set-PSFConfig -Module dbachecks -Name skip.agent.lastjobruntime -Validation bool -Value $false -Initialize -Description "Skip the last agent job time check"


Set-PSFConfig -Module dbachecks -Name skip.security.containedbautoclose -Validation bool -Value $true -Initialize -Description "Skips the scan for contained databases should have auto close enabled"
Set-PSFConfig -Module dbachecks -Name skip.security.sqlagentproxiesnopublicrole -Validation bool -Value $true -Initialize -Description "Skips the scan for if the public role has access to SQL Agent proxies"
Set-PSFConfig -Module dbachecks -Name skip.security.symmetrickeyencryptionlevel -Validation bool -Value $true -Initialize -Description "Skips the test for if the Symmetric Encryption is at least AES_128 or higher in non-system databases"
Set-PSFConfig -Module dbachecks -Name skip.security.asymmetrickeysize -Validation bool -Value $true -Initialize -Description "Skips the test for the size of the Assymetric Key sizes being above 2048 in non-system databases"
Set-PSFConfig -Module dbachecks -Name skip.security.hideinstance -Validation bool -Value $true -Initialize -Description "Skips the scan for if hide instance is set to YES on the instance"
Set-PSFConfig -Module dbachecks -Name skip.security.clrassembliessafe -Validation bool -Value $true -Initialize -Description "Skips the scan for CLR Assemblies set to SAFE_ACCESS"
Set-PSFConfig -Module dbachecks -Name skip.security.engineserviceadmin -Validation bool -Value $true -Initialize -Description "Skips the scan for the SQL Server Engine account is a local administrator"
Set-PSFConfig -Module dbachecks -Name skip.security.agentserviceadmin -Validation bool -Value $true -Initialize -Description "Skips the scan for the SQL Server Agent account is a local administrator"
Set-PSFConfig -Module dbachecks -Name skip.security.fulltextserviceadmin -Validation bool -Value $true -Initialize -Description "Skips the scan for the SQL Server Full Text account is a local administrator"
Set-PSFConfig -Module dbachecks -Name skip.security.querystoredisabled -Validation bool -Value $true -Initialize -Description "Skips the check for if Query Store is disabled"
Set-PSFConfig -Module dbachecks -Name skip.security.querystoreenabled -Validation bool -Value $false -Initialize -Description "Skips the check for if Query Store is enabled"
Set-PSFConfig -Module dbachecks -Name skip.security.loginauditlevelfailed -Validation bool -Value $true -Initialize -Description "Skips the scan for if server login level records failed logins"
Set-PSFConfig -Module dbachecks -Name skip.security.loginauditlevelsuccessful -Validation bool -Value $true -Initialize -Description "Skips the scan for if server login level records successful and failed logins"
Set-PSFConfig -Module dbachecks -Name skip.security.localwindowsgroup -Validation bool -Value $true -Initialize -Description "Skips the scan for if local windows groups have SQL Logins"
Set-PSFConfig -Module dbachecks -Name skip.security.publicrolepermission -Validation bool -Value $true -Initialize -Description "Skips the scan for if the public server role has permissions"
Set-PSFConfig -Module dbachecks -Name skip.security.builtinadmin -Validation bool -Value $true -Initialize -Description "Skips the scan for BUILTIN\Administrators login"
Set-PSFConfig -Module dbachecks -Name skip.security.guestuserconnect -Validation bool -Value $true -Initialize -Description "Skips the scan for guest user have CONNECT permission"
Set-PSFConfig -Module dbachecks -Name skip.security.ContainedDBSQLAuth -Validation bool -Value $true -Initialize -Description "Skips the scan for if a contained database as sql authenticated users"
Set-PSFConfig -Module dbachecks -Name skip.agent.alert -Validation bool -Value $false -Initialize -Description "Skips the agent alerts checks"
Set-PSFConfig -Module dbachecks -Name skip.security.LoginCheckPolicy -Validation bool -Value $true -Initialize -Description "Skips the scan for CHECK_POLICY on for all logins"
Set-PSFConfig -Module dbachecks -Name skip.security.LoginPasswordExpiration -Validation bool -Value $true -Initialize -Description "Skips the scan for password expiration on for all logins in sysadmin role"
Set-PSFConfig -Module dbachecks -Name skip.security.LoginMustChange -Validation bool -Value $true -Initialize -Description "Skips the scan for new logins must have password change turned on"
Set-PSFConfig -Module dbachecks -Name skip.security.nonstandardport -Validation bool -Value $true -Initialize -Description "Skips the check for whether SQL Server should be configured with a non standard port"
Set-PSFConfig -Module dbachecks -Name skip.security.SQLMailXPsDisabled -Validation bool -Value $true -Initialize -Description "Skip the check for Sql Mail XPs being disabled"
Set-PSFConfig -Module dbachecks -Name skip.security.PublicPermission -Validation bool -Value $true -Initialize -Description "Skips the check for whether public role has permissions"
Set-PSFConfig -Module dbachecks -Name skip.security.serverprotocol -Validation bool -Value $true -Initialize -Description "Skips the check for whether SQL Server is running on any other protocols but TCP/IP"
#agent
Set-PSFConfig -Module dbachecks -Name agent.dbaoperatorname -Value $null -Initialize -Description "Name of the DBA Operator in SQL Agent"
Set-PSFConfig -Module dbachecks -Name agent.dbaoperatoremail -Value $null -Initialize -Description "Email address of the DBA Operator in SQL Agent"
Set-PSFConfig -Module dbachecks -Name agent.failsafeoperator -Value $null -Initialize -Description "Email address of the DBA Operator in SQL Agent"
Set-PSFConfig -Module dbachecks -Name agent.databasemailprofile -Value $null -Initialize -Description "Name of the Database Mail Profile in SQL Agent"
Set-PSFConfig -Module dbachecks -Name agent.validjobowner.name -Value "sa" -Initialize -Description "Agent job owner account should be this user"
Set-PSFConfig -Module dbachecks -Name agent.invalidjobowner.name -Value $null -Initialize -Description "Agent job owner account should not be this user"
Set-PSFConfig -Module dbachecks -Name agent.alert.messageid -Value @('823', '824', '825') -Initialize -Description "Agent alert messageid to validate; https://www.brentozar.com/blitz/configure-sql-server-alerts/"
Set-PSFConfig -Module dbachecks -Name agent.alert.severity -Value @('16', '17', '18', '19', '20', '21', '22', '23', '24', '25') -Initialize -Description "Agent alert severity to validate; https://www.brentozar.com/blitz/configure-sql-server-alerts/"
Set-PSFConfig -Module dbachecks -Name agent.alert.job -Value $false -Initialize -Description "Should we check for an agent job for the Agent Alert checks?"
Set-PSFConfig -Module dbachecks -Name agent.alert.notification -Value $true -Initialize -Description "Should we check for a notification for the Agent Alert checks?"
Set-PSFConfig -Module dbachecks -Name agent.history.maximumhistoryrows -Value 1000 -Initialize -Description "Maximum job history log size (in rows). The value -1 means disabled"
Set-PSFConfig -Module dbachecks -Name agent.history.maximumjobhistoryrows -Value 100 -Initialize -Description "Maximum job history row per job. When the property is disabled the value is 0."
Set-PSFConfig -Module dbachecks -Name agent.failedjob.excludecancelled -Value $false -Initialize -Description "Exclude agent jobs with a status of cancelled"
Set-PSFConfig -Module dbachecks -Name agent.failedjob.since -Value 30 -Initialize -Description "The maximum number of days to check for failed jobs"
Set-PSFConfig -Module dbachecks -Name agent.longrunningjob.percentage -Value 50 -Initialize -Description "The maximum percentage variance that a currently running job is allowed over the average for that job"
Set-PSFConfig -Module dbachecks -Name agent.lastjobruntime.percentage -Value 50 -Initialize -Description "The maximum percentage variance that the last run of a job is allowed over the average for that job"

# domain
Set-PSFConfig -Module dbachecks -Name domain.name -Value $null -Initialize -Description "The Active Directory domain that your server is a part of"
Set-PSFConfig -Module dbachecks -Name domain.organizationalunit -Value $null -Initialize -Description "The OU that your server should be a part of"
Set-PSFConfig -Module dbachecks -Name domain.domaincontroller -Value $null -Initialize -Description "The domain controller to process your requests"

# email
Set-PSFConfig -Module dbachecks -Name mail.failurethreshhold -Value 0 -Initialize -Description "Number of errors that must be present to generate an email report"
Set-PSFConfig -Module dbachecks -Name mail.smtpserver -Value $null -Initialize -Description "Store the name of the smtp server to send email reports"
Set-PSFConfig -Module dbachecks -Name mail.to -Value $null -Validation validation.EmailValidation -Initialize -Description "Email address to send the report to"
Set-PSFConfig -Module dbachecks -Name mail.from -Value $null -Validation validation.EmailValidation -Initialize -Description "Email address the email reports should come from"
Set-PSFConfig -Module dbachecks -Name mail.subject -Value 'dbachecks results' -Validation String -Initialize -Description "Subject line of the email report"

# Command parameter default values
Set-PSFConfig -Module dbachecks -Name command.invokedbccheck.excludecheck -Value @() -Initialize -Description "Invoke-DbcCheck: The checks that should be skipped by default."
Set-PSFConfig -Module dbachecks -Name command.invokedbccheck.excludedatabases -Value @() -Initialize -Description "Invoke-DbcCheck: The databases that should be skipped by default."

# config for integration testing
Set-PSFConfig -Module dbachecks -Name testing.integration.instance -Value @("localhost") -Initialize -Description "Default SQL Server instances to be used by integration tests"

# Suspect pages
Set-PSFConfig -Module dbachecks -Name policy.suspectpage.excludedb -Value 90 -Initialize -Description "Default threshold (%) to check whether suspect_pages is nearing row limit of 1000"
Set-PSFConfig -Module dbachecks -Name policy.suspectpage.threshold -Value 90 -Initialize -Description "Default threshold (%) to check whether suspect_pages is nearing row limit of 1000"

# Server
Set-PSFConfig -Module dbachecks -Name policy.server.cpuprioritisation -Value $true -Initialize -Description "Shall we skip the CPU Prioritisation check"
Set-PSFConfig -Module dbachecks -Name policy.server.excludeDiskAllocationUnit -Value @() -Initialize -Description "The disks to skip from the Disk Allocation Unit check - Must be 'DISKLETTER:\'"

# Devops
Set-PSFConfig -Module dbachecks -Name database.exists -Value @("master", "msdb", "tempdb", "model") -Initialize -Description "The databases we expect to be on the instances"

# Not Contactable
Set-PSFConfig -Module dbachecks -Name global.notcontactable -Value @() -Initialize -Description "This is used within the checks to avoid trying to contact none-responsive instances many times - do not set manually"
Set-PSFConfig -Module dbachecks -Name policy.traceflags.expected -Value @() -Initialize -Description "The trace flags we expect to be running"
Set-PSFConfig -Module dbachecks -Name policy.traceflags.notexpected -Value @() -Initialize -Description "The trace flags we expect not to be running"
