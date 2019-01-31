# Invoke-DbcCheck

## SYNOPSIS
Invoke-DbcCheck is a SQL-centric Invoke-Pester wrapper

## SYNTAX

### Default (Default)
```
Invoke-DbcCheck [-Script <Object[]>] [-TestName <String[]>] [-EnableExit] [[-Check] <String[]>]
 [-ExcludeCheck <String[]>] [-PassThru] [-SqlInstance <DbaInstanceParameter[]>]
 [-ComputerName <DbaInstanceParameter[]>] [-SqlCredential <PSCredential>] [-Credential <PSCredential>]
 [-Database <Object[]>] [-ExcludeDatabase <Object[]>] [-Value <String[]>] [-ConfigFile <String>]
 [-CodeCoverage <Object[]>] [-CodeCoverageOutputFile <String>] [-CodeCoverageOutputFileFormat <String>]
 [-Strict] [-OutputFormat <String>] [-AllChecks] [-Quiet] [-PesterOption <Object>] [-Show <OutputTypes>]
 [-ConfigAgentAlertJob <Object>] [-ConfigAgentAlertMessageid <Object>] [-ConfigAgentAlertNotification <Object>]
 [-ConfigAgentAlertSeverity <Object>] [-ConfigAgentDatabasemailprofile <Object>]
 [-ConfigAgentDbaoperatoremail <Object>] [-ConfigAgentDbaoperatorname <Object>]
 [-ConfigAgentFailsafeoperator <Object>] [-ConfigAgentHistoryMaximumhistoryrows <Object>]
 [-ConfigAgentHistoryMaximumjobhistoryrows <Object>] [-ConfigAgentValidjobownerName <Object>]
 [-ConfigAppCheckrepos <Object>] [-ConfigAppCluster <Object>] [-ConfigAppComputername <Object>]
 [-ConfigAppLocalapp <Object>] [-ConfigAppMaildirectory <Object>] [-ConfigAppSqlcredential <Object>]
 [-ConfigAppSqlinstance <Object>] [-ConfigAppWincredential <Object>]
 [-ConfigCommandInvokedbccheckExcludecheck <Object>] [-ConfigCommandInvokedbccheckExcludedatabases <Object>]
 [-ConfigDatabaseExists <Object>] [-ConfigDomainDomaincontroller <Object>] [-ConfigDomainName <Object>]
 [-ConfigDomainOrganizationalunit <Object>] [-ConfigGlobalNotcontactable <Object>]
 [-ConfigMailFailurethreshhold <Object>] [-ConfigMailFrom <Object>] [-ConfigMailSmtpserver <Object>]
 [-ConfigMailSubject <Object>] [-ConfigMailTo <Object>] [-ConfigOlaJobnameCommandlogcleanup <Object>]
 [-ConfigOlaJobnameDeletebackuphistory <Object>] [-ConfigOlaJobnameOutputfilecleanup <Object>]
 [-ConfigOlaJobnamePurgebackuphistory <Object>] [-ConfigOlaJobnameSystemfull <Object>]
 [-ConfigOlaJobnameSystemintegrity <Object>] [-ConfigOlaJobnameUserdiff <Object>]
 [-ConfigOlaJobnameUserfull <Object>] [-ConfigOlaJobnameUserindex <Object>]
 [-ConfigOlaJobnameUserintegrity <Object>] [-ConfigOlaJobnameUserlog <Object>]
 [-ConfigPolicyAdlogingroupExcludecheck <Object>] [-ConfigPolicyAdloginuserExcludecheck <Object>]
 [-ConfigPolicyBackupDatadir <Object>] [-ConfigPolicyBackupDefaultbackupcompression <Object>]
 [-ConfigPolicyBackupDiffmaxhours <Object>] [-ConfigPolicyBackupFullmaxdays <Object>]
 [-ConfigPolicyBackupLogdir <Object>] [-ConfigPolicyBackupLogmaxminutes <Object>]
 [-ConfigPolicyBackupNewdbgraceperiod <Object>] [-ConfigPolicyBackupTestserver <Object>]
 [-ConfigPolicyBuildBehind <Object>] [-ConfigPolicyBuildWarningwindow <Object>]
 [-ConfigPolicyCertificateexpirationExcludedb <Object>]
 [-ConfigPolicyCertificateexpirationWarningwindow <Object>] [-ConfigPolicyConnectionAuthscheme <Object>]
 [-ConfigPolicyConnectionPingcount <Object>] [-ConfigPolicyConnectionPingmaxms <Object>]
 [-ConfigPolicyDacallowed <Object>] [-ConfigPolicyDatabaseAutoclose <Object>]
 [-ConfigPolicyDatabaseAutocreatestatistics <Object>] [-ConfigPolicyDatabaseAutoshrink <Object>]
 [-ConfigPolicyDatabaseAutoupdatestatistics <Object>]
 [-ConfigPolicyDatabaseAutoupdatestatisticsasynchronously <Object>]
 [-ConfigPolicyDatabaseFilebalancetolerance <Object>] [-ConfigPolicyDatabaseFilegrowthexcludedb <Object>]
 [-ConfigPolicyDatabaseFilegrowthfreespacethreshold <Object>] [-ConfigPolicyDatabaseFilegrowthtype <Object>]
 [-ConfigPolicyDatabaseFilegrowthvalue <Object>] [-ConfigPolicyDatabaseLogfilecount <Object>]
 [-ConfigPolicyDatabaseLogfilesizecomparison <Object>] [-ConfigPolicyDatabaseLogfilesizepercentage <Object>]
 [-ConfigPolicyDatabaseMaxdop <Object>] [-ConfigPolicyDatabaseMaxdopexcludedb <Object>]
 [-ConfigPolicyDatabaseMaxvlf <Object>] [-ConfigPolicyDatabaseStatusExcludeoffline <Object>]
 [-ConfigPolicyDatabaseStatusExcludereadonly <Object>] [-ConfigPolicyDatabaseStatusExcluderestoring <Object>]
 [-ConfigPolicyDatabaseWrongcollation <Object>] [-ConfigPolicyDbccMaxdays <Object>]
 [-ConfigPolicyDiskspacePercentfree <Object>] [-ConfigPolicyDumpMaxcount <Object>]
 [-ConfigPolicyErrorlogLogcount <Object>] [-ConfigPolicyErrorlogWarningwindow <Object>]
 [-ConfigPolicyHadrTcpport <Object>] [-ConfigPolicyIdentityUsagepercent <Object>]
 [-ConfigPolicyInstancemaxdopExcludeinstance <Object>] [-ConfigPolicyInstancemaxdopMaxdop <Object>]
 [-ConfigPolicyInstancemaxdopUserecommended <Object>] [-ConfigPolicyInvaliddbownerExcludedb <Object>]
 [-ConfigPolicyInvaliddbownerName <Object>] [-ConfigPolicyNetworkLatencymaxms <Object>]
 [-ConfigPolicyOlaCommandlogcleanup <Object>] [-ConfigPolicyOlaCommandlogenabled <Object>]
 [-ConfigPolicyOlaCommandlogscheduled <Object>] [-ConfigPolicyOlaDatabase <Object>]
 [-ConfigPolicyOlaDeletebackuphistorycleanup <Object>] [-ConfigPolicyOlaDeletebackuphistoryenabled <Object>]
 [-ConfigPolicyOlaDeletebackuphistoryscheduled <Object>] [-ConfigPolicyOlaInstalled <Object>]
 [-ConfigPolicyOlaOutputfilecleanup <Object>] [-ConfigPolicyOlaOutputfilecleanupenabled <Object>]
 [-ConfigPolicyOlaOutputfilecleanupscheduled <Object>] [-ConfigPolicyOlaPurgejobhistorycleanup <Object>]
 [-ConfigPolicyOlaPurgejobhistoryenabled <Object>] [-ConfigPolicyOlaPurgejobhistoryscheduled <Object>]
 [-ConfigPolicyOlaSystemfullenabled <Object>] [-ConfigPolicyOlaSystemfullretention <Object>]
 [-ConfigPolicyOlaSystemfullscheduled <Object>] [-ConfigPolicyOlaSystemintegritycheckenabled <Object>]
 [-ConfigPolicyOlaSystemintegritycheckscheduled <Object>] [-ConfigPolicyOlaUserdiffenabled <Object>]
 [-ConfigPolicyOlaUserdiffretention <Object>] [-ConfigPolicyOlaUserdiffscheduled <Object>]
 [-ConfigPolicyOlaUserfullenabled <Object>] [-ConfigPolicyOlaUserfullretention <Object>]
 [-ConfigPolicyOlaUserfullscheduled <Object>] [-ConfigPolicyOlaUserindexoptimizeenabled <Object>]
 [-ConfigPolicyOlaUserindexoptimizescheduled <Object>] [-ConfigPolicyOlaUserintegritycheckenabled <Object>]
 [-ConfigPolicyOlaUserintegritycheckscheduled <Object>] [-ConfigPolicyOlaUserlogenabled <Object>]
 [-ConfigPolicyOlaUserlogretention <Object>] [-ConfigPolicyOlaUserlogscheduled <Object>]
 [-ConfigPolicyOleautomation <Object>] [-ConfigPolicyPageverify <Object>]
 [-ConfigPolicyRecoverymodelExcludedb <Object>] [-ConfigPolicyRecoverymodelType <Object>]
 [-ConfigPolicySecurityAdhocdistributedqueriesenabled <Object>] [-ConfigPolicySecurityClrenabled <Object>]
 [-ConfigPolicySecurityCrossdbownershipchaining <Object>] [-ConfigPolicySecurityDatabasemailenabled <Object>]
 [-ConfigPolicySecurityXpcmdshelldisabled <Object>] [-ConfigPolicyServerCpuprioritisation <Object>]
 [-ConfigPolicyStorageBackuppath <Object>] [-ConfigPolicyTraceflagsExpected <Object>]
 [-ConfigPolicyTraceflagsNotexpected <Object>] [-ConfigPolicyTwodigityearcutoff <Object>]
 [-ConfigPolicyValiddbownerExcludedb <Object>] [-ConfigPolicyValiddbownerName <Object>]
 [-ConfigPolicyWhoisactiveDatabase <Object>] [-ConfigPolicyXeventRequiredrunningsession <Object>]
 [-ConfigPolicyXeventRequiredstoppedsession <Object>] [-ConfigPolicyXeventValidrunningsession <Object>]
 [-ConfigSkipBackupReadonly <Object>] [-ConfigSkipBackupTesting <Object>] [-ConfigSkipConnectionAuth <Object>]
 [-ConfigSkipConnectionPing <Object>] [-ConfigSkipConnectionRemoting <Object>]
 [-ConfigSkipDatabaseFilegrowthdisabled <Object>] [-ConfigSkipDatabaseLogfilecounttest <Object>]
 [-ConfigSkipDatafilegrowthdisabled <Object>] [-ConfigSkipDbccDatapuritycheck <Object>]
 [-ConfigSkipDiffbackuptest <Object>] [-ConfigSkipHadrListenerPingcheck <Object>]
 [-ConfigSkipInstanceModeldbgrowth <Object>] [-ConfigSkipLogfilecounttest <Object>]
 [-ConfigSkipLogshiptesting <Object>] [-ConfigSkipTempdb1118 <Object>] [-ConfigSkipTempdbfilecount <Object>]
 [-ConfigSkipTempdbfilegrowthpercent <Object>] [-ConfigSkipTempdbfilesizemax <Object>]
 [-ConfigSkipTempdbfilesonc <Object>] [-ConfigTestingIntegrationInstance <Object>] [<CommonParameters>]
```

### NewOutputSet
```
Invoke-DbcCheck [-Script <Object[]>] [-TestName <String[]>] [-EnableExit] [[-Check] <String[]>]
 [-ExcludeCheck <String[]>] [-PassThru] [-SqlInstance <DbaInstanceParameter[]>]
 [-ComputerName <DbaInstanceParameter[]>] [-SqlCredential <PSCredential>] [-Credential <PSCredential>]
 [-Database <Object[]>] [-ExcludeDatabase <Object[]>] [-Value <String[]>] [-ConfigFile <String>]
 [-CodeCoverage <Object[]>] [-CodeCoverageOutputFile <String>] [-CodeCoverageOutputFileFormat <String>]
 [-Strict] -OutputFile <String> [-OutputFormat <String>] [-AllChecks] [-Quiet] [-PesterOption <Object>]
 [-Show <OutputTypes>] [-ConfigAgentAlertJob <Object>] [-ConfigAgentAlertMessageid <Object>]
 [-ConfigAgentAlertNotification <Object>] [-ConfigAgentAlertSeverity <Object>]
 [-ConfigAgentDatabasemailprofile <Object>] [-ConfigAgentDbaoperatoremail <Object>]
 [-ConfigAgentDbaoperatorname <Object>] [-ConfigAgentFailsafeoperator <Object>]
 [-ConfigAgentHistoryMaximumhistoryrows <Object>] [-ConfigAgentHistoryMaximumjobhistoryrows <Object>]
 [-ConfigAgentValidjobownerName <Object>] [-ConfigAppCheckrepos <Object>] [-ConfigAppCluster <Object>]
 [-ConfigAppComputername <Object>] [-ConfigAppLocalapp <Object>] [-ConfigAppMaildirectory <Object>]
 [-ConfigAppSqlcredential <Object>] [-ConfigAppSqlinstance <Object>] [-ConfigAppWincredential <Object>]
 [-ConfigCommandInvokedbccheckExcludecheck <Object>] [-ConfigCommandInvokedbccheckExcludedatabases <Object>]
 [-ConfigDatabaseExists <Object>] [-ConfigDomainDomaincontroller <Object>] [-ConfigDomainName <Object>]
 [-ConfigDomainOrganizationalunit <Object>] [-ConfigGlobalNotcontactable <Object>]
 [-ConfigMailFailurethreshhold <Object>] [-ConfigMailFrom <Object>] [-ConfigMailSmtpserver <Object>]
 [-ConfigMailSubject <Object>] [-ConfigMailTo <Object>] [-ConfigOlaJobnameCommandlogcleanup <Object>]
 [-ConfigOlaJobnameDeletebackuphistory <Object>] [-ConfigOlaJobnameOutputfilecleanup <Object>]
 [-ConfigOlaJobnamePurgebackuphistory <Object>] [-ConfigOlaJobnameSystemfull <Object>]
 [-ConfigOlaJobnameSystemintegrity <Object>] [-ConfigOlaJobnameUserdiff <Object>]
 [-ConfigOlaJobnameUserfull <Object>] [-ConfigOlaJobnameUserindex <Object>]
 [-ConfigOlaJobnameUserintegrity <Object>] [-ConfigOlaJobnameUserlog <Object>]
 [-ConfigPolicyAdlogingroupExcludecheck <Object>] [-ConfigPolicyAdloginuserExcludecheck <Object>]
 [-ConfigPolicyBackupDatadir <Object>] [-ConfigPolicyBackupDefaultbackupcompression <Object>]
 [-ConfigPolicyBackupDiffmaxhours <Object>] [-ConfigPolicyBackupFullmaxdays <Object>]
 [-ConfigPolicyBackupLogdir <Object>] [-ConfigPolicyBackupLogmaxminutes <Object>]
 [-ConfigPolicyBackupNewdbgraceperiod <Object>] [-ConfigPolicyBackupTestserver <Object>]
 [-ConfigPolicyBuildBehind <Object>] [-ConfigPolicyBuildWarningwindow <Object>]
 [-ConfigPolicyCertificateexpirationExcludedb <Object>]
 [-ConfigPolicyCertificateexpirationWarningwindow <Object>] [-ConfigPolicyConnectionAuthscheme <Object>]
 [-ConfigPolicyConnectionPingcount <Object>] [-ConfigPolicyConnectionPingmaxms <Object>]
 [-ConfigPolicyDacallowed <Object>] [-ConfigPolicyDatabaseAutoclose <Object>]
 [-ConfigPolicyDatabaseAutocreatestatistics <Object>] [-ConfigPolicyDatabaseAutoshrink <Object>]
 [-ConfigPolicyDatabaseAutoupdatestatistics <Object>]
 [-ConfigPolicyDatabaseAutoupdatestatisticsasynchronously <Object>]
 [-ConfigPolicyDatabaseFilebalancetolerance <Object>] [-ConfigPolicyDatabaseFilegrowthexcludedb <Object>]
 [-ConfigPolicyDatabaseFilegrowthfreespacethreshold <Object>] [-ConfigPolicyDatabaseFilegrowthtype <Object>]
 [-ConfigPolicyDatabaseFilegrowthvalue <Object>] [-ConfigPolicyDatabaseLogfilecount <Object>]
 [-ConfigPolicyDatabaseLogfilesizecomparison <Object>] [-ConfigPolicyDatabaseLogfilesizepercentage <Object>]
 [-ConfigPolicyDatabaseMaxdop <Object>] [-ConfigPolicyDatabaseMaxdopexcludedb <Object>]
 [-ConfigPolicyDatabaseMaxvlf <Object>] [-ConfigPolicyDatabaseStatusExcludeoffline <Object>]
 [-ConfigPolicyDatabaseStatusExcludereadonly <Object>] [-ConfigPolicyDatabaseStatusExcluderestoring <Object>]
 [-ConfigPolicyDatabaseWrongcollation <Object>] [-ConfigPolicyDbccMaxdays <Object>]
 [-ConfigPolicyDiskspacePercentfree <Object>] [-ConfigPolicyDumpMaxcount <Object>]
 [-ConfigPolicyErrorlogLogcount <Object>] [-ConfigPolicyErrorlogWarningwindow <Object>]
 [-ConfigPolicyHadrTcpport <Object>] [-ConfigPolicyIdentityUsagepercent <Object>]
 [-ConfigPolicyInstancemaxdopExcludeinstance <Object>] [-ConfigPolicyInstancemaxdopMaxdop <Object>]
 [-ConfigPolicyInstancemaxdopUserecommended <Object>] [-ConfigPolicyInvaliddbownerExcludedb <Object>]
 [-ConfigPolicyInvaliddbownerName <Object>] [-ConfigPolicyNetworkLatencymaxms <Object>]
 [-ConfigPolicyOlaCommandlogcleanup <Object>] [-ConfigPolicyOlaCommandlogenabled <Object>]
 [-ConfigPolicyOlaCommandlogscheduled <Object>] [-ConfigPolicyOlaDatabase <Object>]
 [-ConfigPolicyOlaDeletebackuphistorycleanup <Object>] [-ConfigPolicyOlaDeletebackuphistoryenabled <Object>]
 [-ConfigPolicyOlaDeletebackuphistoryscheduled <Object>] [-ConfigPolicyOlaInstalled <Object>]
 [-ConfigPolicyOlaOutputfilecleanup <Object>] [-ConfigPolicyOlaOutputfilecleanupenabled <Object>]
 [-ConfigPolicyOlaOutputfilecleanupscheduled <Object>] [-ConfigPolicyOlaPurgejobhistorycleanup <Object>]
 [-ConfigPolicyOlaPurgejobhistoryenabled <Object>] [-ConfigPolicyOlaPurgejobhistoryscheduled <Object>]
 [-ConfigPolicyOlaSystemfullenabled <Object>] [-ConfigPolicyOlaSystemfullretention <Object>]
 [-ConfigPolicyOlaSystemfullscheduled <Object>] [-ConfigPolicyOlaSystemintegritycheckenabled <Object>]
 [-ConfigPolicyOlaSystemintegritycheckscheduled <Object>] [-ConfigPolicyOlaUserdiffenabled <Object>]
 [-ConfigPolicyOlaUserdiffretention <Object>] [-ConfigPolicyOlaUserdiffscheduled <Object>]
 [-ConfigPolicyOlaUserfullenabled <Object>] [-ConfigPolicyOlaUserfullretention <Object>]
 [-ConfigPolicyOlaUserfullscheduled <Object>] [-ConfigPolicyOlaUserindexoptimizeenabled <Object>]
 [-ConfigPolicyOlaUserindexoptimizescheduled <Object>] [-ConfigPolicyOlaUserintegritycheckenabled <Object>]
 [-ConfigPolicyOlaUserintegritycheckscheduled <Object>] [-ConfigPolicyOlaUserlogenabled <Object>]
 [-ConfigPolicyOlaUserlogretention <Object>] [-ConfigPolicyOlaUserlogscheduled <Object>]
 [-ConfigPolicyOleautomation <Object>] [-ConfigPolicyPageverify <Object>]
 [-ConfigPolicyRecoverymodelExcludedb <Object>] [-ConfigPolicyRecoverymodelType <Object>]
 [-ConfigPolicySecurityAdhocdistributedqueriesenabled <Object>] [-ConfigPolicySecurityClrenabled <Object>]
 [-ConfigPolicySecurityCrossdbownershipchaining <Object>] [-ConfigPolicySecurityDatabasemailenabled <Object>]
 [-ConfigPolicySecurityXpcmdshelldisabled <Object>] [-ConfigPolicyServerCpuprioritisation <Object>]
 [-ConfigPolicyStorageBackuppath <Object>] [-ConfigPolicyTraceflagsExpected <Object>]
 [-ConfigPolicyTraceflagsNotexpected <Object>] [-ConfigPolicyTwodigityearcutoff <Object>]
 [-ConfigPolicyValiddbownerExcludedb <Object>] [-ConfigPolicyValiddbownerName <Object>]
 [-ConfigPolicyWhoisactiveDatabase <Object>] [-ConfigPolicyXeventRequiredrunningsession <Object>]
 [-ConfigPolicyXeventRequiredstoppedsession <Object>] [-ConfigPolicyXeventValidrunningsession <Object>]
 [-ConfigSkipBackupReadonly <Object>] [-ConfigSkipBackupTesting <Object>] [-ConfigSkipConnectionAuth <Object>]
 [-ConfigSkipConnectionPing <Object>] [-ConfigSkipConnectionRemoting <Object>]
 [-ConfigSkipDatabaseFilegrowthdisabled <Object>] [-ConfigSkipDatabaseLogfilecounttest <Object>]
 [-ConfigSkipDatafilegrowthdisabled <Object>] [-ConfigSkipDbccDatapuritycheck <Object>]
 [-ConfigSkipDiffbackuptest <Object>] [-ConfigSkipHadrListenerPingcheck <Object>]
 [-ConfigSkipInstanceModeldbgrowth <Object>] [-ConfigSkipLogfilecounttest <Object>]
 [-ConfigSkipLogshiptesting <Object>] [-ConfigSkipTempdb1118 <Object>] [-ConfigSkipTempdbfilecount <Object>]
 [-ConfigSkipTempdbfilegrowthpercent <Object>] [-ConfigSkipTempdbfilesizemax <Object>]
 [-ConfigSkipTempdbfilesonc <Object>] [-ConfigTestingIntegrationInstance <Object>] [<CommonParameters>]
```

## DESCRIPTION
The Invoke-DbcCheck function runs Pester tests, including *.Tests.ps1 files and Pester tests in PowerShell scripts.

Extended description about Pester: Get-Help -Name Invoke-Pester

## EXAMPLES

### EXAMPLE 1
```
Invoke-DbcCheck -Tag Backup -SqlInstance sql2016
```

Runs all of the checks tagged Backup against the sql2016 instance

### EXAMPLE 2
```
Invoke-DbcCheck -Tag RecoveryModel -SqlInstance sql2017, sqlcluster -SqlCredential (Get-Credential sqladmin)
```

Runs the Recovery model check against the SQL instances sql2017, sqlcluster 
using the sqladmin SQL login with the password provided interactively

### EXAMPLE 3
```
Invoke-DbcCheck -Check Database -ExcludeCheck AutoShrink -ConfigFile \\share\repo\prod.json
```

Runs all of the checks tagged Database except for the AutoShrink check against 
the SQL Instances set in the config under app.sqlinstance

Imports configuration file, \\\\share\repo\prod.json, prior to executing checks.

### EXAMPLE 4
```
# Set the servers you'll be working with
```

Set-DbcConfig -Name app.sqlinstance -Value sql2016, sql2017, sql2008, sql2008\express
Set-DbcConfig -Name app.computername -Value sql2016, sql2017, sql2008

# Look at the current configs
Get-DbcConfig

# Invoke a few tests
Invoke-DbcCheck -Tags SuspectPage, LastBackup

Runs the Suspect Pages and Last Backup checks against the SQL Instances sql2016,
sql2017, sql2008, sql2008\express after setting them in the configuration

### EXAMPLE 5
```
Invoke-DbcCheck -SqlInstance sql2017 -Tags SuspectPage, LastBackup -Show Summary -PassThru | Update-DbcPowerBiDataSource
```

Start-DbcPowerBi

Runs the Suspect Page and Last Backup checks against the SQL Instances set in 
the config under app.sqlinstance only showing the summary of the results of the
checks.
It then updates the source json for the XML which is stored at
C:\Windows\temp\dbachecks\ and then opens the PowerBi report in PowerBi Desktop

### EXAMPLE 6
```
Get-Help -Name Invoke-Pester -Examples
```

Want to get super deep?
You can look at Invoke-Pester's example's and run them against Invoke-DbcCheck since it's a wrapper.

https://github.com/pester/Pester/wiki/Invoke-Pester

Describe
about_Pester

## PARAMETERS

### -Script
Get-Help -Name Invoke-Pester -Parameter Script

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases: Path, relative_path

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TestName
Get-Help -Name Invoke-Pester -Parameter TestName

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Name

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EnableExit
Get-Help -Name Invoke-Pester -Parameter EnableExit

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Check
Runs only tests in Describe blocks with the specified Tag parameter values.
Wildcard characters and Tag values that include spaces or whitespace characters are not supported.

When you specify multiple Tag values, Invoke-DbcCheck runs tests that have any of the listed tags (it ORs the tags).
However, when you specify TestName and Tag values, Invoke-DbcCheck runs only describe blocks that have one of the specified TestName values and one of the specified Tag values.

If you use both Tag and ExcludeTag, ExcludeTag takes precedence.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Tags, Tag, Checks

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeCheck
Omits tests in Describe blocks with the specified Tag parameter values.
Wildcard characters and Tag values that include spaces or whitespace characters are not supported.

When you specify multiple ExcludeTag values, Invoke-DbcCheck omits tests that have any of the listed tags (it ORs the tags).
However, when you specify TestName and ExcludeTag values, Invoke-DbcCheck omits only describe blocks that have one of the specified TestName values and one of the specified Tag values.

If you use both Tag and ExcludeTag, ExcludeTag takes precedence

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: ExcludeTags, ExcludeTag, ExcludeChecks

Required: False
Position: Named
Default value: (Get-PSFConfigValue -FullName 'dbachecks.command.invokedbccheck.excludecheck' -Fallback @())
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Returns a custom object (PSCustomObject) that contains the test results.

By default, Invoke-DbcCheck writes to the host program, not to the output stream (stdout).
If you try to save the result in a variable, the variable is empty unless you
use the PassThru parameter.

To suppress the host output, use the Quiet parameter.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SqlInstance
A list of SQL Servers to run the tests against.
If this is not provided, it will be gathered from:
Get-DbatoolsConfig -Name app.sqlinstance

```yaml
Type: DbaInstanceParameter[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ComputerName
A list of computers to run the tests against.
If this is not provided, it will be gathered from:
Get-DbatoolsConfig -Name app.computername

```yaml
Type: DbaInstanceParameter[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SqlCredential
Alternate SQL Server-based credential.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
Alternate Windows credential.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Database
A list of databases to include if your check is database centric.

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeDatabase
A list of databases to exclude if your check is database centric.

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: (Get-PSFConfigValue -FullName 'dbachecks.command.invokedbccheck.excludedatabase' -Fallback @())
Accept pipeline input: False
Accept wildcard characters: False
```

### -Value
A value..
it's hard to explain

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigFile
The path to the exported dbachecks config file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CodeCoverage
Get-Help -Name Invoke-Pester -Parameter CodeCoverage

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### -CodeCoverageOutputFile
Get-Help -Name Invoke-Pester -Parameter CodeCoverageOutputFile

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CodeCoverageOutputFileFormat
Get-Help -Name Invoke-Pester -Parameter CodeCoverageOutputFileFormat

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: JaCoCo
Accept pipeline input: False
Accept wildcard characters: False
```

### -Strict
Makes Pending and Skipped tests to Failed tests.
Useful for continuous integration where you need to make sure all tests passed.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputFile
Get-Help -Name Invoke-Pester -Parameter OutputFile

```yaml
Type: String
Parameter Sets: NewOutputSet
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputFormat
The format of output.
Currently, only NUnitXML is supported.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllChecks
In the unlikely event that you'd like to run all checks, specify -AllChecks.
These checks still confirm to the skip settings in Get-DbcConfig.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Quiet
The parameter Quiet is deprecated since Pester v.
4.0 and will be deleted in the next major version of Pester.
Please use the parameter Show with value 'None' instead.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PesterOption
Get-Help -Name Invoke-Pester -Parameter PesterOption

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Show
Customizes the output Pester writes to the screen. 

Available options are 
None
Default
Passed
Failed
Pending
Skipped
Inconclusive
Describe
Context
Summary
Header
All
Fails

The options can be combined to define presets.

Common use cases are:

None - to write no output to the screen.
All - to write all available information (this is default option).
Fails - to write everything except Passed (but including Describes etc.).

A common setting is also Failed, Summary, to write only failed tests and test summary.

This parameter does not affect the PassThru custom object or the XML output that is written when you use the Output parameters.

```yaml
Type: OutputTypes
Parameter Sets: (All)
Aliases:
Accepted values: None, Default, Passed, Failed, Pending, Skipped, Inconclusive, Describe, Context, Summary, Header, Fails, All

Required: False
Position: Named
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigAgentAlertJob
{{Fill ConfigAgentAlertJob Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigAgentAlertMessageid
{{Fill ConfigAgentAlertMessageid Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigAgentAlertNotification
{{Fill ConfigAgentAlertNotification Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigAgentAlertSeverity
{{Fill ConfigAgentAlertSeverity Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigAgentDatabasemailprofile
{{Fill ConfigAgentDatabasemailprofile Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigAgentDbaoperatoremail
{{Fill ConfigAgentDbaoperatoremail Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigAgentDbaoperatorname
{{Fill ConfigAgentDbaoperatorname Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigAgentFailsafeoperator
{{Fill ConfigAgentFailsafeoperator Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigAgentHistoryMaximumhistoryrows
{{Fill ConfigAgentHistoryMaximumhistoryrows Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigAgentHistoryMaximumjobhistoryrows
{{Fill ConfigAgentHistoryMaximumjobhistoryrows Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigAgentValidjobownerName
{{Fill ConfigAgentValidjobownerName Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigAppCheckrepos
{{Fill ConfigAppCheckrepos Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigAppCluster
{{Fill ConfigAppCluster Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigAppComputername
{{Fill ConfigAppComputername Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigAppLocalapp
{{Fill ConfigAppLocalapp Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigAppMaildirectory
{{Fill ConfigAppMaildirectory Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigAppSqlcredential
{{Fill ConfigAppSqlcredential Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigAppSqlinstance
{{Fill ConfigAppSqlinstance Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigAppWincredential
{{Fill ConfigAppWincredential Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigCommandInvokedbccheckExcludecheck
{{Fill ConfigCommandInvokedbccheckExcludecheck Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigCommandInvokedbccheckExcludedatabases
{{Fill ConfigCommandInvokedbccheckExcludedatabases Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigDatabaseExists
{{Fill ConfigDatabaseExists Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigDomainDomaincontroller
{{Fill ConfigDomainDomaincontroller Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigDomainName
{{Fill ConfigDomainName Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigDomainOrganizationalunit
{{Fill ConfigDomainOrganizationalunit Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigGlobalNotcontactable
{{Fill ConfigGlobalNotcontactable Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigMailFailurethreshhold
{{Fill ConfigMailFailurethreshhold Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigMailFrom
{{Fill ConfigMailFrom Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigMailSmtpserver
{{Fill ConfigMailSmtpserver Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigMailSubject
{{Fill ConfigMailSubject Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigMailTo
{{Fill ConfigMailTo Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigOlaJobnameCommandlogcleanup
{{Fill ConfigOlaJobnameCommandlogcleanup Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigOlaJobnameDeletebackuphistory
{{Fill ConfigOlaJobnameDeletebackuphistory Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigOlaJobnameOutputfilecleanup
{{Fill ConfigOlaJobnameOutputfilecleanup Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigOlaJobnamePurgebackuphistory
{{Fill ConfigOlaJobnamePurgebackuphistory Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigOlaJobnameSystemfull
{{Fill ConfigOlaJobnameSystemfull Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigOlaJobnameSystemintegrity
{{Fill ConfigOlaJobnameSystemintegrity Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigOlaJobnameUserdiff
{{Fill ConfigOlaJobnameUserdiff Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigOlaJobnameUserfull
{{Fill ConfigOlaJobnameUserfull Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigOlaJobnameUserindex
{{Fill ConfigOlaJobnameUserindex Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigOlaJobnameUserintegrity
{{Fill ConfigOlaJobnameUserintegrity Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigOlaJobnameUserlog
{{Fill ConfigOlaJobnameUserlog Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyAdlogingroupExcludecheck
{{Fill ConfigPolicyAdlogingroupExcludecheck Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyAdloginuserExcludecheck
{{Fill ConfigPolicyAdloginuserExcludecheck Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyBackupDatadir
{{Fill ConfigPolicyBackupDatadir Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyBackupDefaultbackupcompression
{{Fill ConfigPolicyBackupDefaultbackupcompression Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyBackupDiffmaxhours
{{Fill ConfigPolicyBackupDiffmaxhours Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyBackupFullmaxdays
{{Fill ConfigPolicyBackupFullmaxdays Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyBackupLogdir
{{Fill ConfigPolicyBackupLogdir Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyBackupLogmaxminutes
{{Fill ConfigPolicyBackupLogmaxminutes Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyBackupNewdbgraceperiod
{{Fill ConfigPolicyBackupNewdbgraceperiod Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyBackupTestserver
{{Fill ConfigPolicyBackupTestserver Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyBuildBehind
{{Fill ConfigPolicyBuildBehind Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyBuildWarningwindow
{{Fill ConfigPolicyBuildWarningwindow Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyCertificateexpirationExcludedb
{{Fill ConfigPolicyCertificateexpirationExcludedb Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyCertificateexpirationWarningwindow
{{Fill ConfigPolicyCertificateexpirationWarningwindow Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyConnectionAuthscheme
{{Fill ConfigPolicyConnectionAuthscheme Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyConnectionPingcount
{{Fill ConfigPolicyConnectionPingcount Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyConnectionPingmaxms
{{Fill ConfigPolicyConnectionPingmaxms Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyDacallowed
{{Fill ConfigPolicyDacallowed Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyDatabaseAutoclose
{{Fill ConfigPolicyDatabaseAutoclose Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyDatabaseAutocreatestatistics
{{Fill ConfigPolicyDatabaseAutocreatestatistics Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyDatabaseAutoshrink
{{Fill ConfigPolicyDatabaseAutoshrink Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyDatabaseAutoupdatestatistics
{{Fill ConfigPolicyDatabaseAutoupdatestatistics Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyDatabaseAutoupdatestatisticsasynchronously
{{Fill ConfigPolicyDatabaseAutoupdatestatisticsasynchronously Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyDatabaseFilebalancetolerance
{{Fill ConfigPolicyDatabaseFilebalancetolerance Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyDatabaseFilegrowthexcludedb
{{Fill ConfigPolicyDatabaseFilegrowthexcludedb Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyDatabaseFilegrowthfreespacethreshold
{{Fill ConfigPolicyDatabaseFilegrowthfreespacethreshold Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyDatabaseFilegrowthtype
{{Fill ConfigPolicyDatabaseFilegrowthtype Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyDatabaseFilegrowthvalue
{{Fill ConfigPolicyDatabaseFilegrowthvalue Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyDatabaseLogfilecount
{{Fill ConfigPolicyDatabaseLogfilecount Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyDatabaseLogfilesizecomparison
{{Fill ConfigPolicyDatabaseLogfilesizecomparison Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyDatabaseLogfilesizepercentage
{{Fill ConfigPolicyDatabaseLogfilesizepercentage Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyDatabaseMaxdop
{{Fill ConfigPolicyDatabaseMaxdop Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyDatabaseMaxdopexcludedb
{{Fill ConfigPolicyDatabaseMaxdopexcludedb Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyDatabaseMaxvlf
{{Fill ConfigPolicyDatabaseMaxvlf Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyDatabaseStatusExcludeoffline
{{Fill ConfigPolicyDatabaseStatusExcludeoffline Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyDatabaseStatusExcludereadonly
{{Fill ConfigPolicyDatabaseStatusExcludereadonly Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyDatabaseStatusExcluderestoring
{{Fill ConfigPolicyDatabaseStatusExcluderestoring Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyDatabaseWrongcollation
{{Fill ConfigPolicyDatabaseWrongcollation Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyDbccMaxdays
{{Fill ConfigPolicyDbccMaxdays Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyDiskspacePercentfree
{{Fill ConfigPolicyDiskspacePercentfree Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyDumpMaxcount
{{Fill ConfigPolicyDumpMaxcount Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyErrorlogLogcount
{{Fill ConfigPolicyErrorlogLogcount Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyErrorlogWarningwindow
{{Fill ConfigPolicyErrorlogWarningwindow Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyHadrTcpport
{{Fill ConfigPolicyHadrTcpport Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyIdentityUsagepercent
{{Fill ConfigPolicyIdentityUsagepercent Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyInstancemaxdopExcludeinstance
{{Fill ConfigPolicyInstancemaxdopExcludeinstance Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyInstancemaxdopMaxdop
{{Fill ConfigPolicyInstancemaxdopMaxdop Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyInstancemaxdopUserecommended
{{Fill ConfigPolicyInstancemaxdopUserecommended Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyInvaliddbownerExcludedb
{{Fill ConfigPolicyInvaliddbownerExcludedb Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyInvaliddbownerName
{{Fill ConfigPolicyInvaliddbownerName Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyNetworkLatencymaxms
{{Fill ConfigPolicyNetworkLatencymaxms Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaCommandlogcleanup
{{Fill ConfigPolicyOlaCommandlogcleanup Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaCommandlogenabled
{{Fill ConfigPolicyOlaCommandlogenabled Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaCommandlogscheduled
{{Fill ConfigPolicyOlaCommandlogscheduled Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaDatabase
{{Fill ConfigPolicyOlaDatabase Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaDeletebackuphistorycleanup
{{Fill ConfigPolicyOlaDeletebackuphistorycleanup Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaDeletebackuphistoryenabled
{{Fill ConfigPolicyOlaDeletebackuphistoryenabled Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaDeletebackuphistoryscheduled
{{Fill ConfigPolicyOlaDeletebackuphistoryscheduled Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaInstalled
{{Fill ConfigPolicyOlaInstalled Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaOutputfilecleanup
{{Fill ConfigPolicyOlaOutputfilecleanup Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaOutputfilecleanupenabled
{{Fill ConfigPolicyOlaOutputfilecleanupenabled Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaOutputfilecleanupscheduled
{{Fill ConfigPolicyOlaOutputfilecleanupscheduled Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaPurgejobhistorycleanup
{{Fill ConfigPolicyOlaPurgejobhistorycleanup Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaPurgejobhistoryenabled
{{Fill ConfigPolicyOlaPurgejobhistoryenabled Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaPurgejobhistoryscheduled
{{Fill ConfigPolicyOlaPurgejobhistoryscheduled Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaSystemfullenabled
{{Fill ConfigPolicyOlaSystemfullenabled Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaSystemfullretention
{{Fill ConfigPolicyOlaSystemfullretention Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaSystemfullscheduled
{{Fill ConfigPolicyOlaSystemfullscheduled Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaSystemintegritycheckenabled
{{Fill ConfigPolicyOlaSystemintegritycheckenabled Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaSystemintegritycheckscheduled
{{Fill ConfigPolicyOlaSystemintegritycheckscheduled Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaUserdiffenabled
{{Fill ConfigPolicyOlaUserdiffenabled Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaUserdiffretention
{{Fill ConfigPolicyOlaUserdiffretention Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaUserdiffscheduled
{{Fill ConfigPolicyOlaUserdiffscheduled Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaUserfullenabled
{{Fill ConfigPolicyOlaUserfullenabled Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaUserfullretention
{{Fill ConfigPolicyOlaUserfullretention Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaUserfullscheduled
{{Fill ConfigPolicyOlaUserfullscheduled Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaUserindexoptimizeenabled
{{Fill ConfigPolicyOlaUserindexoptimizeenabled Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaUserindexoptimizescheduled
{{Fill ConfigPolicyOlaUserindexoptimizescheduled Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaUserintegritycheckenabled
{{Fill ConfigPolicyOlaUserintegritycheckenabled Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaUserintegritycheckscheduled
{{Fill ConfigPolicyOlaUserintegritycheckscheduled Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaUserlogenabled
{{Fill ConfigPolicyOlaUserlogenabled Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaUserlogretention
{{Fill ConfigPolicyOlaUserlogretention Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOlaUserlogscheduled
{{Fill ConfigPolicyOlaUserlogscheduled Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyOleautomation
{{Fill ConfigPolicyOleautomation Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyPageverify
{{Fill ConfigPolicyPageverify Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyRecoverymodelExcludedb
{{Fill ConfigPolicyRecoverymodelExcludedb Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyRecoverymodelType
{{Fill ConfigPolicyRecoverymodelType Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicySecurityAdhocdistributedqueriesenabled
{{Fill ConfigPolicySecurityAdhocdistributedqueriesenabled Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicySecurityClrenabled
{{Fill ConfigPolicySecurityClrenabled Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicySecurityCrossdbownershipchaining
{{Fill ConfigPolicySecurityCrossdbownershipchaining Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicySecurityDatabasemailenabled
{{Fill ConfigPolicySecurityDatabasemailenabled Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicySecurityXpcmdshelldisabled
{{Fill ConfigPolicySecurityXpcmdshelldisabled Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyServerCpuprioritisation
{{Fill ConfigPolicyServerCpuprioritisation Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyStorageBackuppath
{{Fill ConfigPolicyStorageBackuppath Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyTraceflagsExpected
{{Fill ConfigPolicyTraceflagsExpected Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyTraceflagsNotexpected
{{Fill ConfigPolicyTraceflagsNotexpected Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyTwodigityearcutoff
{{Fill ConfigPolicyTwodigityearcutoff Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyValiddbownerExcludedb
{{Fill ConfigPolicyValiddbownerExcludedb Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyValiddbownerName
{{Fill ConfigPolicyValiddbownerName Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyWhoisactiveDatabase
{{Fill ConfigPolicyWhoisactiveDatabase Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyXeventRequiredrunningsession
{{Fill ConfigPolicyXeventRequiredrunningsession Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyXeventRequiredstoppedsession
{{Fill ConfigPolicyXeventRequiredstoppedsession Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigPolicyXeventValidrunningsession
{{Fill ConfigPolicyXeventValidrunningsession Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigSkipBackupReadonly
{{Fill ConfigSkipBackupReadonly Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigSkipBackupTesting
{{Fill ConfigSkipBackupTesting Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigSkipConnectionAuth
{{Fill ConfigSkipConnectionAuth Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigSkipConnectionPing
{{Fill ConfigSkipConnectionPing Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigSkipConnectionRemoting
{{Fill ConfigSkipConnectionRemoting Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigSkipDatabaseFilegrowthdisabled
{{Fill ConfigSkipDatabaseFilegrowthdisabled Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigSkipDatabaseLogfilecounttest
{{Fill ConfigSkipDatabaseLogfilecounttest Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigSkipDatafilegrowthdisabled
{{Fill ConfigSkipDatafilegrowthdisabled Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigSkipDbccDatapuritycheck
{{Fill ConfigSkipDbccDatapuritycheck Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigSkipDiffbackuptest
{{Fill ConfigSkipDiffbackuptest Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigSkipHadrListenerPingcheck
{{Fill ConfigSkipHadrListenerPingcheck Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigSkipInstanceModeldbgrowth
{{Fill ConfigSkipInstanceModeldbgrowth Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigSkipLogfilecounttest
{{Fill ConfigSkipLogfilecounttest Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigSkipLogshiptesting
{{Fill ConfigSkipLogshiptesting Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigSkipTempdb1118
{{Fill ConfigSkipTempdb1118 Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigSkipTempdbfilecount
{{Fill ConfigSkipTempdbfilecount Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigSkipTempdbfilegrowthpercent
{{Fill ConfigSkipTempdbfilegrowthpercent Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigSkipTempdbfilesizemax
{{Fill ConfigSkipTempdbfilesizemax Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigSkipTempdbfilesonc
{{Fill ConfigSkipTempdbfilesonc Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigTestingIntegrationInstance
{{Fill ConfigTestingIntegrationInstance Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://dbachecks.readthedocs.io/en/latest/functions/Invoke-DbcCheck/](https://dbachecks.readthedocs.io/en/latest/functions/Invoke-DbcCheck/)

