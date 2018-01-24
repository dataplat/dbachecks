# Fred magic
#Set-PSFConfig -Handler { if (Get-PSFTaskEngineCache -Module dbachecks -Name module-imported) { Write-PSFMessage -Level Warning -Message "This setting will only take effect on the next console start" } }

#Add some validation for values with limited options
$LogFileComparisonValidationssb = { param ([string]$input) if ($input -in ('average','maximum')){ [PsCustomObject]@{Success = $true; value = $input} } else { [PsCustomObject]@{Success = $false; message = "must be average or maximum - $input"} } }
Register-PSFConfigValidation -Name validation.LogFileComparisonValidations -ScriptBlock $LogFileComparisonValidationssb
$EmailValidationSb = { 
    param ([string]$input) 
    $EmailRegEx = "^\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$"
    if ($input -match $EmailRegEx){ 
        [PsCustomObject]@{Success = $true; value = $input} 
    } 
    else { 
        [PsCustomObject]@{Success = $false; message = "does not appear to be an email address - $input"} 
    } 
}
Register-PSFConfigValidation -Name validation.EmailValidation -ScriptBlock $EmailValidationSb


# some configs to help with autocompletes and other module level stuff
Set-PSFConfig -Module dbachecks -Name app.checkrepos -Value "$script:ModuleRoot\checks" -Initialize -Description "Where Pester tests/checks are stored"
Set-PSFConfig -Module dbachecks -Name app.sqlinstance -Value $null -Initialize -Description "List of SQL Server instances that SQL-based tests will run against"
Set-PSFConfig -Module dbachecks -Name app.computername -Value $null -Initialize -Description "List of Windows Servers that Windows-based tests will run against"
Set-PSFConfig -Module dbachecks -Name app.sqlcredential -Value $null -Initialize -Description "The universal SQL credential if Trusted/Windows Authentication is not used"
Set-PSFConfig -Module dbachecks -Name app.wincredential -Value $null -Initialize -Description "The universal Windows if default Windows Authentication is not used"
Set-PSFConfig -Module dbachecks -Name app.localapp -Value "$env:localappdata\dbachecks" -Initialize -Description "Persisted files live here"
Set-PSFConfig -Module dbachecks -Name app.maildirectory -Value "$env:localappdata\dbachecks\dbachecks.mail" -Initialize -Description "Files for mail are stored here"

# Policy
Set-PSFConfig -Module dbachecks -Name policy.backuppath -Value $null -Initialize -Description "Enables tests to check if servers have access to centralized backup location"
Set-PSFConfig -Module dbachecks -Name policy.backuptestserver -Value $null -Initialize -Description "Destination server for backuptests"
Set-PSFConfig -Module dbachecks -Name policy.backupdatadir -Value $null -Initialize -Description "Destination server data directory"
Set-PSFConfig -Module dbachecks -Name policy.backuplogdir -Value $null -Initialize -Description "Destination server log directory"
Set-PSFConfig -Module dbachecks -Name policy.diskspacepercentfree -Validation integer -Value 20 -Initialize -Description "Percent disk free"
Set-PSFConfig -Module dbachecks -Name policy.backupfullmaxdays -Validation integer -Value 1 -Initialize -Description "Maxmimum number of days before Full Backups are considered outdated"
Set-PSFConfig -Module dbachecks -Name policy.backupdiffmaxhours -Validation integer -Value 25 -Initialize -Description "Maxmimum number of hours before Diff Backups are considered outdated"
Set-PSFConfig -Module dbachecks -Name policy.backuplogmaxminutes -Validation integer -Value 15 -Initialize -Description "Maxmimum number of minutes before Log Backups are considered outdated"
Set-PSFConfig -Module dbachecks -Name policy.integritycheckmaxdays -Validation integer -Value 7 -Initialize -Description "Maxmimum number of days before DBCC CHECKDB is considered outdated"
Set-PSFConfig -Module dbachecks -Name policy.identityusagepercent -Validation integer -Value 90 -Initialize -Description "Maxmimum percentage of max of identity column"
Set-PSFConfig -Module dbachecks -Name policy.networklatencymsmax -Validation integer -Value 40 -Initialize -Description "Max network latency average"
Set-PSFConfig -Module dbachecks -Name policy.recoverymodel -Value "Full" -Initialize -Description "Standard recovery model"
Set-PSFConfig -Module dbachecks -Name policy.validdbowner -Value "sa" -Initialize -Description "The database owner account should be this user"
Set-PSFConfig -Module dbachecks -Name policy.invaliddbowner -Value "sa" -Initialize -Description "The database owner account should not be this user"
Set-PSFConfig -Module dbachecks -Name policy.dacallowed -Validation bool -Value $true -Initialize -Description "Alters the DAC check to say if it should be allowed `$true or disallowed `$false"
Set-PSFConfig -Module dbachecks -Name policy.authscheme -Value "Kerberos" -Initialize -Description "Auth requirement (Kerberos, NTLM, etc)"
Set-PSFConfig -Module dbachecks -Name policy.hadrtcpport -Value "1433" -Initialize -Description "The TCPPort for the HADR check"
Set-PSFConfig -Module dbachecks -Name policy.maxdumpcount -Validation integer -Value 1 -Initialize -Description "Maximum number of expected dumps"
Set-PSFConfig -Module dbachecks -Name policy.pageverify -Value "Checksum" -Initialize -Description "Page verify option should be set to this value"
Set-PSFConfig -Module dbachecks -Name policy.autoclose -Validation bool -Value $false -Initialize -Description "Alters the Auto Close check to say if it should be allowed `$true or dissalower `$false"
Set-PSFConfig -Module dbachecks -Name policy.autoshrink -Validation bool -Value $false -Initialize -Description "Alters the Auto Shrink check to say if it should be allowed `$true or dissalower `$false"
Set-PSFConfig -Module dbachecks -Name policy.virtuallogfilemax -Validation integer -Value 512 -Initialize -Description "Max virtual log files"
Set-PSFConfig -Module dbachecks -Name policy.pingmsmax -Validation integer -Value 10 -Initialize -Description "Maximum response time in ms"
Set-PSFConfig -Module dbachecks -Name policy.pingcount -Validation integer -Value 3 -Initialize -Description "Number of times to ping a server to establish average response time"
Set-PSFConfig -Module dbachecks -Name policy.autocreatestatistics -Validation bool -Value $true -Initialize -Description "Alters the Auto Create Statistics check to say if it should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.autoupdatestatistics -Validation bool -Value $true -Initialize -Description "Alters the Auto Update Statistics check to say if it should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.autoupdatestatisticsasynchronously -Validation bool -Value $false -Initialize -Description "Alters the Auto Update Statistics Asynchronously check to say if it should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.defaultbackupcompreesion -Validation bool -Value $true -Initialize -Description "Alters the Default Backup Compression check to say if it should be enabled `$true or disabled `$false"
Set-PSFConfig -Module dbachecks -Name policy.datafilegrowthtype -Value "kb" -Initialize -Description "Alters the Growth Type to say if it should be 'kb' or 'percent'"
Set-PSFConfig -Module dbachecks -Name policy.datafilegrowthvalue -Validation integer -Value 65535 -Initialize -Description "The auto growth value (in kb) should be equal or higher than this value. Example: A value of 65535 means at least 64MB. "
Set-PSFConfig -Module dbachecks -Name policy.logfilecount -Validation integer -Value 1 -Initialize -Description "The number of Log files expected on a database"
Set-PSFConfig -Module dbachecks -Name policy.LogFileSizePercentage -Validation integer -Value 100 -Initialize -Description "Maximum percentage of Data file Size that logfile is allowed to be."
Set-PSFConfig -Module dbachecks -Name policy.LogFileSizeComparison -Validation validation.logfilecomparisonvalidations -Value 'average' -Initialize -Description "How to compare data and log file size, options are maximum or average"
Set-PSFConfig -Module dbachecks -Name policy.filebalancetolerance -Validation integer -Value 5 -Initialize -Description "Percentage for Tolerance for checking for balanced files in a filegroups"

# skips - these are for whole checks that should not run by default or internal commands that can't be skipped using ExcludeTag
Set-PSFConfig -Module dbachecks -Name skip.datapuritycheck -Validation bool -Value $false -Initialize -Description "Skip data purity check in last good dbcc command"
Set-PSFConfig -Module dbachecks -Name skip.backuptesting -Validation bool -Value $true -Initialize -Description "Don't run Test-DbaLastBackup by default (it's not read-only)"
Set-PSFConfig -Module dbachecks -Name skip.tempdb1118 -Validation bool -Value $false -Initialize -Description "Don't run test for Trace Flag 1118"
Set-PSFConfig -Module dbachecks -Name skip.tempdbfilecount -Validation bool -Value $false -Initialize -Description "Don't run test for Temp Database File Count"
Set-PSFConfig -Module dbachecks -Name skip.tempdbfilegrowthpercent -Validation bool -Value $false -Initialize -Description "Don't run test for Temp Database File Growth in Percent"
Set-PSFConfig -Module dbachecks -Name skip.tempdbfilesonc -Validation bool -Value $false -Initialize -Description "Don't run test for Temp Database Files on C"
Set-PSFConfig -Module dbachecks -Name skip.tempdbfilesizemax -Validation bool -Value $false -Initialize -Description "Don't run test for Temp Database Files Max Size"
Set-PSFConfig -Module dbachecks -Name skip.remotingcheck -Validation bool -Value $false -Initialize -Description "Skip PowerShell remoting"
Set-PSFConfig -Module dbachecks -Name skip.datafilegrowthdisabled -Validation bool -Value $true -Initialize -Description "Skip validation of datafiles which have growth value equal to zero."
Set-PSFConfig -Module dbachecks -Name skip.logfilecounttest -Validation bool -Value $false -Initialize -Description "Skip the logfilecount test"

# xevents
Set-PSFConfig -Module dbachecks -Name xevent.validrunningsession -Value $null -Initialize -Description "List of XE Sessions that can be be running."
Set-PSFConfig -Module dbachecks -Name xevent.requiredrunningsession -Value $null -Initialize -Description "List of XE Sessions that should be running."
Set-PSFConfig -Module dbachecks -Name xevent.requiredstoppedsession -Value $null -Initialize -Description "List of XE Sessions that should not be running."

#agent
Set-PSFConfig -Module dbachecks -Name agent.dbaoperatorname -Value $null -Initialize -Description "Name of the DBA Operator in SQL Agent"
Set-PSFConfig -Module dbachecks -Name agent.dbaoperatoremail -Value $null -Initialize -Description "Email address of the DBA Operator in SQL Agent"
Set-PSFConfig -Module dbachecks -Name agent.failsafeoperator -Value $null -Initialize -Description "Email address of the DBA Operator in SQL Agent"

# domain
Set-PSFConfig -Module dbachecks -Name domain.name -Value $null -Initialize -Description "The Active Directory domain that your server is a part of"
Set-PSFConfig -Module dbachecks -Name domain.organizationalunit -Value $null -Initialize -Description "The OU that your server should be a part of"
Set-PSFConfig -Module dbachecks -Name domain.domaincontroller -Value $null -Initialize -Description "The domain controller to process your requests"

# sp_WhoIsActive
Set-PSFConfig -Module dbachecks -Name whoisactive.database -Value "master" -Initialize -Description "Which database should contains the sp_WhoIsActive stored procedure"

# email
Set-PSFConfig -Module dbachecks -Name mail.failurethreshhold -Value 0 -Validation integer -Initialize -Description "Number of errors that must be present to generate an email report"
Set-PSFConfig -Module dbachecks -Name mail.smtpserver -Value $null -Validation string -Initialize -Description "Store the name of the smtp server to send email reports"
Set-PSFConfig -Module dbachecks -Name mail.to -Value $null -Validation validation.EmailValidation -Initialize -Description "Email address to send the report to"
Set-PSFConfig -Module dbachecks -Name mail.from  -Value $null -Validation validation.EmailValidation -Initialize -Description "Email address the email reports should come from"
Set-PSFConfig -Module dbachecks -Name mail.subject  -Value 'dbachecks results' -Validation String -Initialize -Description "Subject line of the email report"
