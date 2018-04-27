# Fred magic
#Set-PSFConfig -Handler { if (Get-PSFTaskEngineCache -Module dbachecks -Name module-imported) { Write-PSFMessage -Level Warning -Message "This setting will only take effect on the next console start" } }

#Add some validation for values with limited options
$LogFileComparisonValidationssb = { param ([string]$input) if ($input -in ('average', 'maximum')) { [PsCustomObject]@{Success = $true; value = $input} } else { [PsCustomObject]@{Success = $false; message = "must be average or maximum - $input"}
    } }
Register-PSFConfigValidation -Name validation.LogFileComparisonValidations -ScriptBlock $LogFileComparisonValidationssb
$EmailValidationSb = {
    param ([string]$input)
    $EmailRegEx = "^\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$"
    if ($input -match $EmailRegEx) {
        [PsCustomObject]@{Success = $true; value = $input}
    } else {
        [PsCustomObject]@{Success = $false; message = "does not appear to be an email address - $input"}
    }
}
Register-PSFConfigValidation -Name validation.EmailValidation -ScriptBlock $EmailValidationSb


# some configs to help with autocompletes and other module level stuff
#apps
Set-PSFConfig -Module dbachecks -Name app.checkrepos -Value "$script:ModuleRoot\checks" -Initialize -Description "Where Pester tests/checks are stored"
Set-PSFConfig -Module dbachecks -Name app.sqlinstance -Value $null -Initialize -Description "List of SQL Server instances that SQL-based tests will run against"
Set-PSFConfig -Module dbachecks -Name app.computername -Value $null -Initialize -Description "List of Windows Servers that Windows-based tests will run against"
Set-PSFConfig -Module dbachecks -Name app.sqlcredential -Value $null -Initialize -Description "The universal SQL credential if Trusted/Windows Authentication is not used"
Set-PSFConfig -Module dbachecks -Name app.wincredential -Value $null -Initialize -Description "The universal Windows if default Windows Authentication is not used"
Set-PSFConfig -Module dbachecks -Name app.localapp -Value "$env:localappdata\dbachecks" -Initialize -Description "Persisted files live here"
Set-PSFConfig -Module dbachecks -Name app.maildirectory -Value "$env:localappdata\dbachecks\dbachecks.mail" -Initialize -Description "Files for mail are stored here"
Set-PSFConfig -Module dbachecks -Name app.cluster -Value $null -Initialize -Description "One host name for each cluster for the HADR checks"

# Policy Configs
#Storage
Set-PSFConfig -Module dbachecks -Name policy.storage.backuppath -Value $null -Initialize -Description "Enables tests to check if servers have access to centralized backup location"

#Backup
Set-PSFConfig -Module dbachecks -Name policy.backup.testserver -Value $null -Initialize -Description "Destination server for backuptests"
Set-PSFConfig -Module dbachecks -Name policy.backup.datadir -Value $null -Initialize -Description "Destination server data directory"
Set-PSFConfig -Module dbachecks -Name policy.backup.logdir -Value $null -Initialize -Description "Destination server log directory"
Set-PSFConfig -Module dbachecks -Name policy.backup.fullmaxdays -Value 1 -Initialize -Description "Maximum number of days before Full Backups are considered outdated"
Set-PSFConfig -Module dbachecks -Name policy.backup.diffmaxhours -Value 25 -Initialize -Description "Maximum number of hours before Diff Backups are considered outdated"
Set-PSFConfig -Module dbachecks -Name policy.backup.logmaxminutes -Value 15 -Initialize -Description "Maximum number of minutes before Log Backups are considered outdated"
Set-PsFConfig -Module dbachecks -Name policy.backup.newdbgraceperiod -Value 0 -Initialize -Description "The number of hours a newly created database is allowed to not have backups"
Set-PSFConfig -Module dbachecks -Name policy.backup.defaultbackupcompression -Validation bool -Value $true -Initialize -Description "Default Backup Compression check should be enabled `$true or disabled `$false"

#diskspce
Set-PSFConfig -Module dbachecks -Name policy.diskspace.percentfree -Value 20 -Initialize -Description "Percent disk free"

#DBCC
Set-PSFConfig -Module dbachecks -Name policy.dbcc.maxdays -Value 7 -Initialize -Description "Maximum number of days before DBCC CHECKDB is considered outdated"

#Encryption
Set-PSFConfig -Module dbachecks -Name policy.certificateexpiration.excludedb -Value '{master, msdb, model, tempdb}'  -Initialize -Description "Databases to exclude from expired certificate checks"
Set-PSFConfig -Module dbachecks -Name policy.certificateexpiration.warningwindow -Value 1  -Initialize -Description "The number of months prior to a certificate being expired that you want warning about"

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
Set-PSFConfig -Module dbachecks -Name policy.validdbowner.excludedb -Value @('master', 'msdb', 'model', 'tempdb')  -Initialize -Description "Databases to exclude from valid dbowner checks"
Set-PSFConfig -Module dbachecks -Name policy.invaliddbowner.name -Value "sa" -Initialize -Description "The database owner account should not be this user"
Set-PSFConfig -Module dbachecks -Name policy.invaliddbowner.excludedb -Value @('master', 'msdb', 'model', 'tempdb')  -Initialize -Description "Databases to exclude from invalid dbowner checks"

#Error Log
Set-PSFConfig -Module dbachecks -Name policy.errorlog.warningwindow -Value 2 -Initialize -Description "The number of days prior to check for error log issues"

#DAC
Set-PSFConfig -Module dbachecks -Name policy.dacallowed -Validation bool -Value $true -Initialize -Description "DAC should be allowed `$true or disallowed `$false"

#OLE Automation
Set-PSFConfig -Module dbachecks -Name policy.oleautomation -Validation bool -Value $false -Initialize -Description "OLE Automation should be enabled `$true or disabled `$false"

#Connectivity
Set-PSFConfig -Module dbachecks -Name policy.connection.authscheme  -Value "Kerberos" -Initialize -Description "Auth requirement (Kerberos, NTLM, etc)"
Set-PSFConfig -Module dbachecks -Name policy.connection.pingmaxms -Value 10 -Initialize -Description "Maximum response time in ms"
Set-PSFConfig -Module dbachecks -Name policy.connection.pingcount -Value 3 -Initialize -Description "Number of times to ping a server to establish average response time"

#HADR
Set-PSFConfig -Module dbachecks -Name policy.hadr.tcpport -Value "1433" -Initialize -Description "The TCPPort for the HADR check"

#Dump Files
Set-PSFConfig -Module dbachecks -Name policy.dump.maxcount -Value 1 -Initialize -Description "Maximum number of expected dumps"

#pageverify
Set-PSFConfig -Module dbachecks -Name policy.pageverify -Value "Checksum" -Initialize -Description "Page verify option should be set to this value"

# Database
Set-PSFConfig -Module dbachecks -Name policy.database.autoclose -Validation bool -Value $false -Initialize -Description "Auto Close should be allowed `$true or disallowed `$false"
Set-PSFConfig -Module dbachecks -Name policy.database.autoshrink -Validation bool -Value $false -Initialize -Description "Auto Shrink should be allowed `$true or disallowed `$false"
Set-PSFConfig -Module dbachecks -Name policy.database.maxvlf -Value 512 -Initialize -Description "Max virtual log files"
Set-PSFConfig -Module dbachecks -Name policy.database.autocreatestatistics -Validation bool -Value $true -Initialize -Description "Auto Create Statistics should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.database.autoupdatestatistics -Validation bool -Value $true -Initialize -Description "Auto Update Statistics should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.database.autoupdatestatisticsasynchronously -Validation bool -Value $false -Initialize -Description "Auto Update Statistics Asynchronously should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.database.filegrowthexcludedb -Value @() -Initialize -Description "Databases to exclude from the file growth check"
Set-PSFConfig -Module dbachecks -Name policy.database.filegrowthtype  -Value "kb" -Initialize -Description "Growth Type should be 'kb' or 'percent'"
Set-PSFConfig -Module dbachecks -Name policy.database.filegrowthvalue  -Value 65535 -Initialize -Description "The auto growth value (in kb) should be equal or higher than this value. Example: A value of 65535 means at least 64MB. "
Set-PSFConfig -Module dbachecks -Name policy.database.logfilecount -Value 1 -Initialize -Description "The number of Log files expected on a database"
Set-PSFConfig -Module dbachecks -Name policy.database.logfilesizepercentage -Value 100 -Initialize -Description "Maximum percentage of Data file Size that logfile is allowed to be."
Set-PSFConfig -Module dbachecks -Name policy.database.logfilesizecomparison -Validation validation.logfilecomparisonvalidations -Value 'average' -Initialize -Description "How to compare data and log file size, options are maximum or average"
Set-PSFConfig -Module dbachecks -Name policy.database.filebalancetolerance -Value 5 -Initialize -Description "Percentage for Tolerance for checking for balanced files in a filegroups"
Set-PSFConfig -Module dbachecks -Name policy.database.filegrowthfreespacethreshold -Value 20 -Initialize -Description "Integer representing percentage of free space within a database file before warning"
Set-PSFConfig -Module dbachecks -Name policy.database.wrongcollation -Value @() -Initialize -Description "Databases that doesnt match server collation check"

# Policy for Ola Hallengren Maintenance Solution
Set-PSFConfig -Module dbachecks -name policy.ola.installed -Validation bool -Value $true -Initialize -Description "Checks to see if Ola Hallengren solution is installed"
Set-PSFConfig -Module dbachecks -Name policy.ola.database -Validation string -Value 'master' -Initialize -Description "The database where Ola's maintenance solution is installed"
Set-PSFConfig -Module dbachecks -name policy.ola.systemfullenabled -Validation bool -Value $true -Initialize -Description "Ola's Full System Database Backup should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -name policy.ola.userfullenabled -Validation bool -Value $true -Initialize -Description "Ola's Full User Database Backup should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -name policy.ola.userdiffenabled -Validation bool -Value $true -Initialize -Description "Ola's Diff User Database Backup should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -name policy.ola.userlogenabled -Validation bool -Value $true -Initialize -Description "Ola's Log User Database Backup should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -name policy.ola.systemfullscheduled -Validation bool -Value $true -Initialize -Description "Ola's Full System Database Backup should be scheduled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -name policy.ola.userfullscheduled -Validation bool -Value $true -Initialize -Description "Ola's Full User Database Backup should be scheduled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -name policy.ola.userdiffscheduled -Validation bool -Value $true -Initialize -Description "Ola's Diff User Database Backup should be scheduled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -name policy.ola.userlogscheduled -Validation bool -Value $true -Initialize -Description "Ola's Log User Database Backup should be scheduled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -name policy.ola.systemfullretention -Value 192 -Initialize -Description "Ola's Full System Database Backup retention number of hours"
Set-PSFConfig -Module dbachecks -name policy.ola.userfullretention -Value 192 -Initialize -Description "Ola's Full User Database Backup retention number of hours"
Set-PSFConfig -Module dbachecks -name policy.ola.userdiffretention -Value 192 -Initialize -Description "Ola's Diff User Database Backup retention number of hours"
Set-PSFConfig -Module dbachecks -name policy.ola.userlogretention -Value 192 -Initialize -Description "Ola's Log User Database Backup retention number of hours"
Set-PSFConfig -Module dbachecks -name policy.ola.CommandLogenabled -Validation bool -Value $true -Initialize -Description "Ola's CommandLog Cleanup should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -name policy.ola.CommandLogscheduled -Validation bool -Value $true -Initialize -Description "Ola's CommandLog Cleanup should be scheduled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -name policy.ola.SystemIntegrityCheckenabled -Validation bool -Value $true -Initialize -Description "Ola's System Database Integrity should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -name policy.ola.SystemIntegrityCheckscheduled -Validation bool -Value $true -Initialize -Description "Ola's System Database Integrity should be scheduled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -name policy.ola.UserIntegrityCheckenabled -Validation bool -Value $true -Initialize -Description "Ola's User Database Integrity should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -name policy.ola.UserIntegrityCheckscheduled -Validation bool -Value $true -Initialize -Description "Ola's User Database Integrity should be scheduled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -name policy.ola.UserIndexOptimizeenabled -Validation bool -Value $true -Initialize -Description "Ola's User Index Optimization should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -name policy.ola.UserIndexOptimizescheduled -Validation bool -Value $true -Initialize -Description "Ola's User Index Optimization should be scheduled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -name policy.ola.OutputFileCleanupenabled -Validation bool -Value $true -Initialize -Description "Ola's Output File Cleanup should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -name policy.ola.OutputFileCleanupscheduled -Validation bool -Value $true -Initialize -Description "Ola's Output File Cleanup should be scheduled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -name policy.ola.DeleteBackupHistoryenabled -Validation bool -Value $true -Initialize -Description "Ola's Delete Backup History should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -name policy.ola.DeleteBackupHistoryscheduled -Validation bool -Value $true -Initialize -Description "Ola's Delete Backup History should be scheduled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -name policy.ola.PurgeJobHistoryenabled -Validation bool -Value $true -Initialize -Description "Ola's Purge Job History should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -name policy.ola.PurgeJobHistoryscheduled -Validation bool -Value $true -Initialize -Description "Ola's Purge Job History should be scheduled `$true or disabled `$false"

# xevents
Set-PSFConfig -Module dbachecks -Name policy.xevent.validrunningsession -Value $null -Initialize -Description "List of XE Sessions that can be be running."
Set-PSFConfig -Module dbachecks -Name policy.xevent.requiredrunningsession -Value $null -Initialize -Description "List of XE Sessions that should be running."
Set-PSFConfig -Module dbachecks -Name policy.xevent.requiredstoppedsession -Value $null -Initialize -Description "List of XE Sessions that should not be running."

# sp_WhoIsActive
Set-PSFConfig -Module dbachecks -Name policy.whoisactive.database -Value "master" -Initialize -Description "Which database should contain the sp_WhoIsActive stored procedure"

#Build
Set-PSFConfig -Module dbachecks -Name policy.build.warningwindow -Value 6 -Initialize -Description "The number of months prior to a build being unsupported that you want warning about"

# The frequency of the Ola Hallengrens User Full backups
# See https://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.smo.agent.jobschedule.frequencyinterval.aspx
# for full options
# 1 for Sunday 127 for every day

# skips - these are for whole checks that should not run by default or internal commands that can't be skipped using ExcludeTag
Set-PSFConfig -Module dbachecks -Name skip.dbcc.datapuritycheck -Validation bool -Value $false -Initialize -Description "Skip data purity check in last good dbcc command"
Set-PSFConfig -Module dbachecks -Name skip.backup.testing -Validation bool -Value $true -Initialize -Description "Don't run Test-DbaLastBackup by default (it's not read-only)"
Set-PSFConfig -Module dbachecks -Name skip.tempdb1118 -Validation bool -Value $false -Initialize -Description "Don't run test for Trace Flag 1118"
Set-PSFConfig -Module dbachecks -Name skip.tempdbfilecount -Validation bool -Value $false -Initialize -Description "Don't run test for Temp Database File Count"
Set-PSFConfig -Module dbachecks -Name skip.tempdbfilegrowthpercent -Validation bool -Value $false -Initialize -Description "Don't run test for Temp Database File Growth in Percent"
Set-PSFConfig -Module dbachecks -Name skip.tempdbfilesonc -Validation bool -Value $false -Initialize -Description "Don't run test for Temp Database Files on C"
Set-PSFConfig -Module dbachecks -Name skip.tempdbfilesizemax -Validation bool -Value $false -Initialize -Description "Don't run test for Temp Database Files Max Size"
Set-PSFConfig -Module dbachecks -Name skip.connection.remoting -Validation bool -Value $false -Initialize -Description "Skip PowerShell remoting check for connectivity"
Set-PSFConfig -Module dbachecks -Name skip.connection.ping -Validation bool -Value $false -Initialize -Description "Skip the ping check for connectivity"
Set-PSFConfig -Module dbachecks -Name skip.datafilegrowthdisabled -Validation bool -Value $true -Initialize -Description "Skip validation of datafiles which have growth value equal to zero."
Set-PSFConfig -Module dbachecks -Name skip.logfilecounttest -Validation bool -Value $false -Initialize -Description "Skip the logfilecount test"
Set-PSFConfig -Module dbachecks -Name skip.diffbackuptest -Validation bool -Value $false -Initialize -Description "Skip the Differential backup test"
Set-PSFConfig -Module dbachecks -Name skip.database.filegrowthdisabled -Validation bool -Value $true -Initialize -Description "Skip validation of datafiles which have growth value equal to zero."
Set-PSFConfig -Module dbachecks -Name skip.database.logfilecounttest -Validation bool -Value $false -Initialize -Description "Skip the logfilecount test"
Set-PSFConfig -Module dbachecks -Name skip.logshiptesting -Validation bool -Value $false -Initialize -Description "Skip the logshipping test"
Set-PSFConfig -Module dbachecks -Name skip.instance.modeldbgrowth -Validation bool -Value $false -Initialize -Description "Skip the model database growth settings test"
Set-PSFConfig -Module dbachecks -Name skip.hadr.listener.pingcheck -Validation bool -Value $false -Initialize -Description "Skip the HADR listener ping test (expecially useful for Azure and AWS)"

#agent
Set-PSFConfig -Module dbachecks -Name agent.dbaoperatorname -Value $null -Initialize -Description "Name of the DBA Operator in SQL Agent"
Set-PSFConfig -Module dbachecks -Name agent.dbaoperatoremail -Value $null -Initialize -Description "Email address of the DBA Operator in SQL Agent"
Set-PSFConfig -Module dbachecks -Name agent.failsafeoperator -Value $null -Initialize -Description "Email address of the DBA Operator in SQL Agent"
Set-PSFConfig -Module dbachecks -Name agent.databasemailprofile -Value $null -Initialize -Description "Name of the Database Mail Profile in SQL Agent"
Set-PSFConfig -Module dbachecks -Name agent.validjobowner.name -Value "sa" -Initialize -Description "Agent job owner account should be this user"
Set-PSFConfig -Module dbachecks -Name agent.alert.messageid -Value @('823', '824', '825') -Initialize -Description "Agent alert messageid to validate; https://www.brentozar.com/blitz/configure-sql-server-alerts/"
Set-PSFConfig -Module dbachecks -Name agent.alert.Severity -Value @('16', '17', '18', '19', '20', '21', '22', '23', '24', '25') -Initialize -Description "Agent alert severity to validate; https://www.brentozar.com/blitz/configure-sql-server-alerts/"
Set-PSFConfig -Module dbachecks -Name agent.alert.Job -Value $false -Initialize -Description "Agent alert job notification. Ex job to write to eventlog for SCOM monitoring"
Set-PSFConfig -Module dbachecks -Name agent.alert.Notification -Value $true -Initialize -Description "Agent alert notification"

# domain
Set-PSFConfig -Module dbachecks -Name domain.name -Value $null -Initialize -Description "The Active Directory domain that your server is a part of"
Set-PSFConfig -Module dbachecks -Name domain.organizationalunit -Value $null -Initialize -Description "The OU that your server should be a part of"
Set-PSFConfig -Module dbachecks -Name domain.domaincontroller -Value $null -Initialize -Description "The domain controller to process your requests"

# email
Set-PSFConfig -Module dbachecks -Name mail.failurethreshhold -Value 0 -Initialize -Description "Number of errors that must be present to generate an email report"
Set-PSFConfig -Module dbachecks -Name mail.smtpserver -Value $null -Validation string -Initialize -Description "Store the name of the smtp server to send email reports"
Set-PSFConfig -Module dbachecks -Name mail.to -Value $null -Validation validation.EmailValidation -Initialize -Description "Email address to send the report to"
Set-PSFConfig -Module dbachecks -Name mail.from  -Value $null -Validation validation.EmailValidation -Initialize -Description "Email address the email reports should come from"
Set-PSFConfig -Module dbachecks -Name mail.subject  -Value 'dbachecks results' -Validation String -Initialize -Description "Subject line of the email report"

# Command parameter default values
Set-PSFConfig -Module dbachecks -Name command.invokedbccheck.excludecheck -Value @() -Initialize -Description "Invoke-DbcCheck: The checks that should be skipped by default."
Set-PSFConfig -Module dbachecks -Name command.invokedbccheck.excludedatabases -Value @() -Initialize -Description "Invoke-DbcCheck: The databases that should be skipped by default."


# config for integration testing 
Set-PSFConfig -Module dbachecks -Name testing.integration.instance -Value @("localhost") -Initialize -Description "Default SQL Server instances to be used by integration tests"