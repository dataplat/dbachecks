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
 [-Strict] [-OutputFormat <String>] [-AllChecks] [-Quiet] [-PesterOption <Object>] [-Show <String>]
 [-ConfigAgentAlertJob <Object>] [-ConfigAgentAlertMessageid <Object>] [-ConfigAgentAlertNotification <Object>]
 [-ConfigAgentAlertSeverity <Object>] [-ConfigAgentDatabasemailprofile <Object>]
 [-ConfigAgentDbaoperatoremail <Object>] [-ConfigAgentDbaoperatorname <Object>]
 [-ConfigAgentFailedjobExcludecancelled <Object>] [-ConfigAgentFailedjobSince <Object>]
 [-ConfigAgentFailsafeoperator <Object>] [-ConfigAgentHistoryMaximumhistoryrows <Object>]
 [-ConfigAgentHistoryMaximumjobhistoryrows <Object>] [-ConfigAgentLastjobruntimePercentage <Object>]
 [-ConfigAgentLongrunningjobPercentage <Object>] [-ConfigAgentValidjobownerName <Object>]
 [-ConfigAppCheckrepos <Object>] [-ConfigAppCluster <Object>] [-ConfigAppComputername <Object>]
 [-ConfigAppLocalapp <Object>] [-ConfigAppMaildirectory <Object>] [-ConfigAppSqlcredential <Object>]
 [-ConfigAppSqlinstance <Object>] [-ConfigAppWincredential <Object>]
 [-ConfigCommandInvokedbccheckExcludecheck <Object>] [-ConfigCommandInvokedbccheckExcludedatabases <Object>]
 [-ConfigDatabaseExists <Object>] [-ConfigDatabaseQuerystoredisabledExcludedb <Object>]
 [-ConfigDatabaseQuerystoreenabledExcludedb <Object>] [-ConfigDomainDomaincontroller <Object>]
 [-ConfigDomainName <Object>] [-ConfigDomainOrganizationalunit <Object>] [-ConfigGlobalNotcontactable <Object>]
 [-ConfigMailFailurethreshhold <Object>] [-ConfigMailFrom <Object>] [-ConfigMailSmtpserver <Object>]
 [-ConfigMailSubject <Object>] [-ConfigMailTo <Object>] [-ConfigOlaJobNameCommandLogCleanup <Object>]
 [-ConfigOlaJobNameDeleteBackupHistory <Object>] [-ConfigOlaJobNameOutputFileCleanup <Object>]
 [-ConfigOlaJobNamePurgeBackupHistory <Object>] [-ConfigOlaJobNameSystemFull <Object>]
 [-ConfigOlaJobNameSystemIntegrity <Object>] [-ConfigOlaJobNameUserDiff <Object>]
 [-ConfigOlaJobNameUserFull <Object>] [-ConfigOlaJobNameUserIndex <Object>]
 [-ConfigOlaJobNameUserIntegrity <Object>] [-ConfigOlaJobNameUserLog <Object>]
 [-ConfigPolicyAdlogingroupExcludecheck <Object>] [-ConfigPolicyAdloginuserExcludecheck <Object>]
 [-ConfigPolicyBackupDatadir <Object>] [-ConfigPolicyBackupDefaultbackupcompression <Object>]
 [-ConfigPolicyBackupDiffmaxhours <Object>] [-ConfigPolicyBackupFullmaxdays <Object>]
 [-ConfigPolicyBackupLogdir <Object>] [-ConfigPolicyBackupLogmaxminutes <Object>]
 [-ConfigPolicyBackupNewdbgraceperiod <Object>] [-ConfigPolicyBackupTestserver <Object>]
 [-ConfigPolicyBuildBehind <Object>] [-ConfigPolicyBuildWarningwindow <Object>]
 [-ConfigPolicyCertificateexpirationExcludedb <Object>]
 [-ConfigPolicyCertificateexpirationWarningwindow <Object>] [-ConfigPolicyClusterHostrecordttl <Object>]
 [-ConfigPolicyClusterNetworkProtocolsIPV4 <Object>] [-ConfigPolicyClusterRegisterallprovidersIP <Object>]
 [-ConfigPolicyConnectionAuthscheme <Object>] [-ConfigPolicyConnectionPingcount <Object>]
 [-ConfigPolicyConnectionPingmaxms <Object>] [-ConfigPolicyDacallowed <Object>]
 [-ConfigPolicyDatabaseAutoclose <Object>] [-ConfigPolicyDatabaseAutocreatestatistics <Object>]
 [-ConfigPolicyDatabaseAutoshrink <Object>] [-ConfigPolicyDatabaseAutoupdatestatistics <Object>]
 [-ConfigPolicyDatabaseAutoupdatestatisticsasynchronously <Object>]
 [-ConfigPolicyDatabaseClrassembliessafeexcludedb <Object>]
 [-ConfigPolicyDatabaseDuplicateindexexcludedb <Object>] [-ConfigPolicyDatabaseFilebalancetolerance <Object>]
 [-ConfigPolicyDatabaseFilegrowthdaystocheck <Object>] [-ConfigPolicyDatabaseFilegrowthexcludedb <Object>]
 [-ConfigPolicyDatabaseFilegrowthfreespacethreshold <Object>] [-ConfigPolicyDatabaseFilegrowthtype <Object>]
 [-ConfigPolicyDatabaseFilegrowthvalue <Object>] [-ConfigPolicyDatabaseLogfilecount <Object>]
 [-ConfigPolicyDatabaseLogfilepercentused <Object>] [-ConfigPolicyDatabaseLogfilesizecomparison <Object>]
 [-ConfigPolicyDatabaseLogfilesizepercentage <Object>] [-ConfigPolicyDatabaseMaxdop <Object>]
 [-ConfigPolicyDatabaseMaxdopexcludedb <Object>] [-ConfigPolicyDatabaseMaxvlf <Object>]
 [-ConfigPolicyDatabaseStatusExcludeoffline <Object>] [-ConfigPolicyDatabaseStatusExcludereadonly <Object>]
 [-ConfigPolicyDatabaseStatusExcluderestoring <Object>] [-ConfigPolicyDatabaseTrustworthyexcludedb <Object>]
 [-ConfigPolicyDatabaseWrongcollation <Object>] [-ConfigPolicyDbccMaxdays <Object>]
 [-ConfigPolicyDiskspacePercentfree <Object>] [-ConfigPolicyDumpMaxcount <Object>]
 [-ConfigPolicyErrorlogLogcount <Object>] [-ConfigPolicyErrorlogWarningwindow <Object>]
 [-ConfigPolicyHadrAgtcpport <Object>] [-ConfigPolicyHadrEndpointname <Object>]
 [-ConfigPolicyHadrEndpointport <Object>] [-ConfigPolicyHadrFailureconditionlevel <Object>]
 [-ConfigPolicyHadrHealthchecktimeout <Object>] [-ConfigPolicyHadrLeasetimeout <Object>]
 [-ConfigPolicyHadrSessiontimeout <Object>] [-ConfigPolicyHadrTcpport <Object>]
 [-ConfigPolicyIdentityUsagepercent <Object>] [-ConfigPolicyInstanceMemorydumpsdaystocheck <Object>]
 [-ConfigPolicyInstanceSqlenginestart <Object>] [-ConfigPolicyInstanceSqlenginestate <Object>]
 [-ConfigPolicyInstancemaxdopExcludeinstance <Object>] [-ConfigPolicyInstancemaxdopMaxdop <Object>]
 [-ConfigPolicyInstancemaxdopUserecommended <Object>] [-ConfigPolicyInvaliddbownerExcludedb <Object>]
 [-ConfigPolicyInvaliddbownerName <Object>] [-ConfigPolicyNetworkLatencymaxms <Object>]
 [-ConfigPolicyOlaCommandLogCleanUp <Object>] [-ConfigPolicyOlaCommandLogenabled <Object>]
 [-ConfigPolicyOlaCommandLogscheduled <Object>] [-ConfigPolicyOlaDatabase <Object>]
 [-ConfigPolicyOlaDeleteBackupHistoryCleanUp <Object>] [-ConfigPolicyOlaDeleteBackupHistoryenabled <Object>]
 [-ConfigPolicyOlaDeleteBackupHistoryscheduled <Object>] [-ConfigPolicyOlaInstalled <Object>]
 [-ConfigPolicyOlaOutputFileCleanUp <Object>] [-ConfigPolicyOlaOutputFileCleanupenabled <Object>]
 [-ConfigPolicyOlaOutputFileCleanupscheduled <Object>] [-ConfigPolicyOlaPurgeJobHistoryCleanUp <Object>]
 [-ConfigPolicyOlaPurgeJobHistoryenabled <Object>] [-ConfigPolicyOlaPurgeJobHistoryscheduled <Object>]
 [-ConfigPolicyOlaSystemfullenabled <Object>] [-ConfigPolicyOlaSystemfullretention <Object>]
 [-ConfigPolicyOlaSystemfullscheduled <Object>] [-ConfigPolicyOlaSystemIntegrityCheckenabled <Object>]
 [-ConfigPolicyOlaSystemIntegrityCheckscheduled <Object>] [-ConfigPolicyOlaUserdiffenabled <Object>]
 [-ConfigPolicyOlaUserdiffretention <Object>] [-ConfigPolicyOlaUserdiffscheduled <Object>]
 [-ConfigPolicyOlaUserfullenabled <Object>] [-ConfigPolicyOlaUserfullretention <Object>]
 [-ConfigPolicyOlaUserfullscheduled <Object>] [-ConfigPolicyOlaUserIndexOptimizeenabled <Object>]
 [-ConfigPolicyOlaUserIndexOptimizescheduled <Object>] [-ConfigPolicyOlaUserIntegrityCheckenabled <Object>]
 [-ConfigPolicyOlaUserIntegrityCheckscheduled <Object>] [-ConfigPolicyOlaUserlogenabled <Object>]
 [-ConfigPolicyOlaUserlogretention <Object>] [-ConfigPolicyOlaUserlogscheduled <Object>]
 [-ConfigPolicyOleautomation <Object>] [-ConfigPolicyPageverify <Object>]
 [-ConfigPolicyRecoverymodelExcludedb <Object>] [-ConfigPolicyRecoverymodelType <Object>]
 [-ConfigPolicySecurityAdhocdistributedqueriesenabled <Object>] [-ConfigPolicySecurityClrenabled <Object>]
 [-ConfigPolicySecurityContainedbautoclose <Object>] [-ConfigPolicySecurityCrossdbownershipchaining <Object>]
 [-ConfigPolicySecurityDatabasemailenabled <Object>] [-ConfigPolicySecurityLatestbuild <Object>]
 [-ConfigPolicySecurityOleautomationproceduresdisabled <Object>]
 [-ConfigPolicySecurityRemoteaccessdisabled <Object>]
 [-ConfigPolicySecurityScanforstartupproceduresdisabled <Object>]
 [-ConfigPolicySecurityXpcmdshelldisabled <Object>] [-ConfigPolicyServerCpuprioritisation <Object>]
 [-ConfigPolicyServerExcludeDiskAllocationUnit <Object>] [-ConfigPolicyStorageBackuppath <Object>]
 [-ConfigPolicySuspectpagesThreshold <Object>] [-ConfigPolicyTraceflagsExpected <Object>]
 [-ConfigPolicyTraceflagsNotexpected <Object>] [-ConfigPolicyTwodigityearcutoff <Object>]
 [-ConfigPolicyValiddbownerExcludedb <Object>] [-ConfigPolicyValiddbownerName <Object>]
 [-ConfigPolicyWhoisactiveDatabase <Object>] [-ConfigPolicyXeventRequiredrunningsession <Object>]
 [-ConfigPolicyXeventRequiredstoppedsession <Object>] [-ConfigPolicyXeventValidrunningsession <Object>]
 [-ConfigSkipAgentAlert <Object>] [-ConfigSkipAgentLastjobruntime <Object>]
 [-ConfigSkipAgentLongrunningjobs <Object>] [-ConfigSkipBackupReadonly <Object>]
 [-ConfigSkipBackupSecondaries <Object>] [-ConfigSkipBackupTesting <Object>]
 [-ConfigSkipClusterNetclusterinterface <Object>] [-ConfigSkipConnectionAuth <Object>]
 [-ConfigSkipConnectionPing <Object>] [-ConfigSkipConnectionRemoting <Object>]
 [-ConfigSkipDatabaseFilegrowthdisabled <Object>] [-ConfigSkipDatabaseLogfilecounttest <Object>]
 [-ConfigSkipDatafilegrowthdisabled <Object>] [-ConfigSkipDbccDatapuritycheck <Object>]
 [-ConfigSkipDiffbackuptest <Object>] [-ConfigSkipHadrListenerPingcheck <Object>]
 [-ConfigSkipHadrListenerTcpport <Object>] [-ConfigSkipHadrReplicaTcpport <Object>]
 [-ConfigSkipInstanceDefaulttrace <Object>] [-ConfigSkipInstanceLatestbuild <Object>]
 [-ConfigSkipInstanceModeldbgrowth <Object>] [-ConfigSkipInstanceOleautomationproceduresdisabled <Object>]
 [-ConfigSkipInstanceRemoteaccessdisabled <Object>]
 [-ConfigSkipInstanceScanforstartupproceduresdisabled <Object>] [-ConfigSkipInstanceSuspectpagelimit <Object>]
 [-ConfigSkipLogfilecounttest <Object>] [-ConfigSkipLogshiptesting <Object>]
 [-ConfigSkipSecurityAgentserviceadmin <Object>] [-ConfigSkipSecurityAsymmetrickeysize <Object>]
 [-ConfigSkipSecurityBuiltinadmin <Object>] [-ConfigSkipSecurityClrassembliessafe <Object>]
 [-ConfigSkipSecurityContainedbautoclose <Object>] [-ConfigSkipSecurityContainedDBSQLAuth <Object>]
 [-ConfigSkipSecurityEngineserviceadmin <Object>] [-ConfigSkipSecurityFulltextserviceadmin <Object>]
 [-ConfigSkipSecurityGuestuserconnect <Object>] [-ConfigSkipSecurityHideinstance <Object>]
 [-ConfigSkipSecurityLocalwindowsgroup <Object>] [-ConfigSkipSecurityLoginauditlevelfailed <Object>]
 [-ConfigSkipSecurityLoginauditlevelsuccessful <Object>] [-ConfigSkipSecurityLoginCheckPolicy <Object>]
 [-ConfigSkipSecurityLoginMustChange <Object>] [-ConfigSkipSecurityLoginPasswordExpiration <Object>]
 [-ConfigSkipSecurityNonstandardport <Object>] [-ConfigSkipSecurityPublicPermission <Object>]
 [-ConfigSkipSecurityPublicrolepermission <Object>] [-ConfigSkipSecurityQuerystoredisabled <Object>]
 [-ConfigSkipSecurityQuerystoreenabled <Object>] [-ConfigSkipSecuritySadisabled <Object>]
 [-ConfigSkipSecuritySaexist <Object>] [-ConfigSkipSecurityServerprotocol <Object>]
 [-ConfigSkipSecuritySqlagentproxiesnopublicrole <Object>] [-ConfigSkipSecuritySQLMailXPsDisabled <Object>]
 [-ConfigSkipSecuritySymmetrickeyencryptionlevel <Object>] [-ConfigSkipTempdb1118 <Object>]
 [-ConfigSkipTempdbfilecount <Object>] [-ConfigSkipTempdbfilegrowthpercent <Object>]
 [-ConfigSkipTempdbfilesizemax <Object>] [-ConfigSkipTempdbfilesonc <Object>]
 [-ConfigTestingIntegrationInstance <Object>] [<CommonParameters>]
```

### NewOutputSet
```
Invoke-DbcCheck [-Script <Object[]>] [-TestName <String[]>] [-EnableExit] [[-Check] <String[]>]
 [-ExcludeCheck <String[]>] [-PassThru] [-SqlInstance <DbaInstanceParameter[]>]
 [-ComputerName <DbaInstanceParameter[]>] [-SqlCredential <PSCredential>] [-Credential <PSCredential>]
 [-Database <Object[]>] [-ExcludeDatabase <Object[]>] [-Value <String[]>] [-ConfigFile <String>]
 [-CodeCoverage <Object[]>] [-CodeCoverageOutputFile <String>] [-CodeCoverageOutputFileFormat <String>]
 [-Strict] -OutputFile <String> [-OutputFormat <String>] [-AllChecks] [-Quiet] [-PesterOption <Object>]
 [-Show <String>] [-ConfigAgentAlertJob <Object>] [-ConfigAgentAlertMessageid <Object>]
 [-ConfigAgentAlertNotification <Object>] [-ConfigAgentAlertSeverity <Object>]
 [-ConfigAgentDatabasemailprofile <Object>] [-ConfigAgentDbaoperatoremail <Object>]
 [-ConfigAgentDbaoperatorname <Object>] [-ConfigAgentFailedjobExcludecancelled <Object>]
 [-ConfigAgentFailedjobSince <Object>] [-ConfigAgentFailsafeoperator <Object>]
 [-ConfigAgentHistoryMaximumhistoryrows <Object>] [-ConfigAgentHistoryMaximumjobhistoryrows <Object>]
 [-ConfigAgentLastjobruntimePercentage <Object>] [-ConfigAgentLongrunningjobPercentage <Object>]
 [-ConfigAgentValidjobownerName <Object>] [-ConfigAppCheckrepos <Object>] [-ConfigAppCluster <Object>]
 [-ConfigAppComputername <Object>] [-ConfigAppLocalapp <Object>] [-ConfigAppMaildirectory <Object>]
 [-ConfigAppSqlcredential <Object>] [-ConfigAppSqlinstance <Object>] [-ConfigAppWincredential <Object>]
 [-ConfigCommandInvokedbccheckExcludecheck <Object>] [-ConfigCommandInvokedbccheckExcludedatabases <Object>]
 [-ConfigDatabaseExists <Object>] [-ConfigDatabaseQuerystoredisabledExcludedb <Object>]
 [-ConfigDatabaseQuerystoreenabledExcludedb <Object>] [-ConfigDomainDomaincontroller <Object>]
 [-ConfigDomainName <Object>] [-ConfigDomainOrganizationalunit <Object>] [-ConfigGlobalNotcontactable <Object>]
 [-ConfigMailFailurethreshhold <Object>] [-ConfigMailFrom <Object>] [-ConfigMailSmtpserver <Object>]
 [-ConfigMailSubject <Object>] [-ConfigMailTo <Object>] [-ConfigOlaJobNameCommandLogCleanup <Object>]
 [-ConfigOlaJobNameDeleteBackupHistory <Object>] [-ConfigOlaJobNameOutputFileCleanup <Object>]
 [-ConfigOlaJobNamePurgeBackupHistory <Object>] [-ConfigOlaJobNameSystemFull <Object>]
 [-ConfigOlaJobNameSystemIntegrity <Object>] [-ConfigOlaJobNameUserDiff <Object>]
 [-ConfigOlaJobNameUserFull <Object>] [-ConfigOlaJobNameUserIndex <Object>]
 [-ConfigOlaJobNameUserIntegrity <Object>] [-ConfigOlaJobNameUserLog <Object>]
 [-ConfigPolicyAdlogingroupExcludecheck <Object>] [-ConfigPolicyAdloginuserExcludecheck <Object>]
 [-ConfigPolicyBackupDatadir <Object>] [-ConfigPolicyBackupDefaultbackupcompression <Object>]
 [-ConfigPolicyBackupDiffmaxhours <Object>] [-ConfigPolicyBackupFullmaxdays <Object>]
 [-ConfigPolicyBackupLogdir <Object>] [-ConfigPolicyBackupLogmaxminutes <Object>]
 [-ConfigPolicyBackupNewdbgraceperiod <Object>] [-ConfigPolicyBackupTestserver <Object>]
 [-ConfigPolicyBuildBehind <Object>] [-ConfigPolicyBuildWarningwindow <Object>]
 [-ConfigPolicyCertificateexpirationExcludedb <Object>]
 [-ConfigPolicyCertificateexpirationWarningwindow <Object>] [-ConfigPolicyClusterHostrecordttl <Object>]
 [-ConfigPolicyClusterNetworkProtocolsIPV4 <Object>] [-ConfigPolicyClusterRegisterallprovidersIP <Object>]
 [-ConfigPolicyConnectionAuthscheme <Object>] [-ConfigPolicyConnectionPingcount <Object>]
 [-ConfigPolicyConnectionPingmaxms <Object>] [-ConfigPolicyDacallowed <Object>]
 [-ConfigPolicyDatabaseAutoclose <Object>] [-ConfigPolicyDatabaseAutocreatestatistics <Object>]
 [-ConfigPolicyDatabaseAutoshrink <Object>] [-ConfigPolicyDatabaseAutoupdatestatistics <Object>]
 [-ConfigPolicyDatabaseAutoupdatestatisticsasynchronously <Object>]
 [-ConfigPolicyDatabaseClrassembliessafeexcludedb <Object>]
 [-ConfigPolicyDatabaseDuplicateindexexcludedb <Object>] [-ConfigPolicyDatabaseFilebalancetolerance <Object>]
 [-ConfigPolicyDatabaseFilegrowthdaystocheck <Object>] [-ConfigPolicyDatabaseFilegrowthexcludedb <Object>]
 [-ConfigPolicyDatabaseFilegrowthfreespacethreshold <Object>] [-ConfigPolicyDatabaseFilegrowthtype <Object>]
 [-ConfigPolicyDatabaseFilegrowthvalue <Object>] [-ConfigPolicyDatabaseLogfilecount <Object>]
 [-ConfigPolicyDatabaseLogfilepercentused <Object>] [-ConfigPolicyDatabaseLogfilesizecomparison <Object>]
 [-ConfigPolicyDatabaseLogfilesizepercentage <Object>] [-ConfigPolicyDatabaseMaxdop <Object>]
 [-ConfigPolicyDatabaseMaxdopexcludedb <Object>] [-ConfigPolicyDatabaseMaxvlf <Object>]
 [-ConfigPolicyDatabaseStatusExcludeoffline <Object>] [-ConfigPolicyDatabaseStatusExcludereadonly <Object>]
 [-ConfigPolicyDatabaseStatusExcluderestoring <Object>] [-ConfigPolicyDatabaseTrustworthyexcludedb <Object>]
 [-ConfigPolicyDatabaseWrongcollation <Object>] [-ConfigPolicyDbccMaxdays <Object>]
 [-ConfigPolicyDiskspacePercentfree <Object>] [-ConfigPolicyDumpMaxcount <Object>]
 [-ConfigPolicyErrorlogLogcount <Object>] [-ConfigPolicyErrorlogWarningwindow <Object>]
 [-ConfigPolicyHadrAgtcpport <Object>] [-ConfigPolicyHadrEndpointname <Object>]
 [-ConfigPolicyHadrEndpointport <Object>] [-ConfigPolicyHadrFailureconditionlevel <Object>]
 [-ConfigPolicyHadrHealthchecktimeout <Object>] [-ConfigPolicyHadrLeasetimeout <Object>]
 [-ConfigPolicyHadrSessiontimeout <Object>] [-ConfigPolicyHadrTcpport <Object>]
 [-ConfigPolicyIdentityUsagepercent <Object>] [-ConfigPolicyInstanceMemorydumpsdaystocheck <Object>]
 [-ConfigPolicyInstanceSqlenginestart <Object>] [-ConfigPolicyInstanceSqlenginestate <Object>]
 [-ConfigPolicyInstancemaxdopExcludeinstance <Object>] [-ConfigPolicyInstancemaxdopMaxdop <Object>]
 [-ConfigPolicyInstancemaxdopUserecommended <Object>] [-ConfigPolicyInvaliddbownerExcludedb <Object>]
 [-ConfigPolicyInvaliddbownerName <Object>] [-ConfigPolicyNetworkLatencymaxms <Object>]
 [-ConfigPolicyOlaCommandLogCleanUp <Object>] [-ConfigPolicyOlaCommandLogenabled <Object>]
 [-ConfigPolicyOlaCommandLogscheduled <Object>] [-ConfigPolicyOlaDatabase <Object>]
 [-ConfigPolicyOlaDeleteBackupHistoryCleanUp <Object>] [-ConfigPolicyOlaDeleteBackupHistoryenabled <Object>]
 [-ConfigPolicyOlaDeleteBackupHistoryscheduled <Object>] [-ConfigPolicyOlaInstalled <Object>]
 [-ConfigPolicyOlaOutputFileCleanUp <Object>] [-ConfigPolicyOlaOutputFileCleanupenabled <Object>]
 [-ConfigPolicyOlaOutputFileCleanupscheduled <Object>] [-ConfigPolicyOlaPurgeJobHistoryCleanUp <Object>]
 [-ConfigPolicyOlaPurgeJobHistoryenabled <Object>] [-ConfigPolicyOlaPurgeJobHistoryscheduled <Object>]
 [-ConfigPolicyOlaSystemfullenabled <Object>] [-ConfigPolicyOlaSystemfullretention <Object>]
 [-ConfigPolicyOlaSystemfullscheduled <Object>] [-ConfigPolicyOlaSystemIntegrityCheckenabled <Object>]
 [-ConfigPolicyOlaSystemIntegrityCheckscheduled <Object>] [-ConfigPolicyOlaUserdiffenabled <Object>]
 [-ConfigPolicyOlaUserdiffretention <Object>] [-ConfigPolicyOlaUserdiffscheduled <Object>]
 [-ConfigPolicyOlaUserfullenabled <Object>] [-ConfigPolicyOlaUserfullretention <Object>]
 [-ConfigPolicyOlaUserfullscheduled <Object>] [-ConfigPolicyOlaUserIndexOptimizeenabled <Object>]
 [-ConfigPolicyOlaUserIndexOptimizescheduled <Object>] [-ConfigPolicyOlaUserIntegrityCheckenabled <Object>]
 [-ConfigPolicyOlaUserIntegrityCheckscheduled <Object>] [-ConfigPolicyOlaUserlogenabled <Object>]
 [-ConfigPolicyOlaUserlogretention <Object>] [-ConfigPolicyOlaUserlogscheduled <Object>]
 [-ConfigPolicyOleautomation <Object>] [-ConfigPolicyPageverify <Object>]
 [-ConfigPolicyRecoverymodelExcludedb <Object>] [-ConfigPolicyRecoverymodelType <Object>]
 [-ConfigPolicySecurityAdhocdistributedqueriesenabled <Object>] [-ConfigPolicySecurityClrenabled <Object>]
 [-ConfigPolicySecurityContainedbautoclose <Object>] [-ConfigPolicySecurityCrossdbownershipchaining <Object>]
 [-ConfigPolicySecurityDatabasemailenabled <Object>] [-ConfigPolicySecurityLatestbuild <Object>]
 [-ConfigPolicySecurityOleautomationproceduresdisabled <Object>]
 [-ConfigPolicySecurityRemoteaccessdisabled <Object>]
 [-ConfigPolicySecurityScanforstartupproceduresdisabled <Object>]
 [-ConfigPolicySecurityXpcmdshelldisabled <Object>] [-ConfigPolicyServerCpuprioritisation <Object>]
 [-ConfigPolicyServerExcludeDiskAllocationUnit <Object>] [-ConfigPolicyStorageBackuppath <Object>]
 [-ConfigPolicySuspectpagesThreshold <Object>] [-ConfigPolicyTraceflagsExpected <Object>]
 [-ConfigPolicyTraceflagsNotexpected <Object>] [-ConfigPolicyTwodigityearcutoff <Object>]
 [-ConfigPolicyValiddbownerExcludedb <Object>] [-ConfigPolicyValiddbownerName <Object>]
 [-ConfigPolicyWhoisactiveDatabase <Object>] [-ConfigPolicyXeventRequiredrunningsession <Object>]
 [-ConfigPolicyXeventRequiredstoppedsession <Object>] [-ConfigPolicyXeventValidrunningsession <Object>]
 [-ConfigSkipAgentAlert <Object>] [-ConfigSkipAgentLastjobruntime <Object>]
 [-ConfigSkipAgentLongrunningjobs <Object>] [-ConfigSkipBackupReadonly <Object>]
 [-ConfigSkipBackupSecondaries <Object>] [-ConfigSkipBackupTesting <Object>]
 [-ConfigSkipClusterNetclusterinterface <Object>] [-ConfigSkipConnectionAuth <Object>]
 [-ConfigSkipConnectionPing <Object>] [-ConfigSkipConnectionRemoting <Object>]
 [-ConfigSkipDatabaseFilegrowthdisabled <Object>] [-ConfigSkipDatabaseLogfilecounttest <Object>]
 [-ConfigSkipDatafilegrowthdisabled <Object>] [-ConfigSkipDbccDatapuritycheck <Object>]
 [-ConfigSkipDiffbackuptest <Object>] [-ConfigSkipHadrListenerPingcheck <Object>]
 [-ConfigSkipHadrListenerTcpport <Object>] [-ConfigSkipHadrReplicaTcpport <Object>]
 [-ConfigSkipInstanceDefaulttrace <Object>] [-ConfigSkipInstanceLatestbuild <Object>]
 [-ConfigSkipInstanceModeldbgrowth <Object>] [-ConfigSkipInstanceOleautomationproceduresdisabled <Object>]
 [-ConfigSkipInstanceRemoteaccessdisabled <Object>]
 [-ConfigSkipInstanceScanforstartupproceduresdisabled <Object>] [-ConfigSkipInstanceSuspectpagelimit <Object>]
 [-ConfigSkipLogfilecounttest <Object>] [-ConfigSkipLogshiptesting <Object>]
 [-ConfigSkipSecurityAgentserviceadmin <Object>] [-ConfigSkipSecurityAsymmetrickeysize <Object>]
 [-ConfigSkipSecurityBuiltinadmin <Object>] [-ConfigSkipSecurityClrassembliessafe <Object>]
 [-ConfigSkipSecurityContainedbautoclose <Object>] [-ConfigSkipSecurityContainedDBSQLAuth <Object>]
 [-ConfigSkipSecurityEngineserviceadmin <Object>] [-ConfigSkipSecurityFulltextserviceadmin <Object>]
 [-ConfigSkipSecurityGuestuserconnect <Object>] [-ConfigSkipSecurityHideinstance <Object>]
 [-ConfigSkipSecurityLocalwindowsgroup <Object>] [-ConfigSkipSecurityLoginauditlevelfailed <Object>]
 [-ConfigSkipSecurityLoginauditlevelsuccessful <Object>] [-ConfigSkipSecurityLoginCheckPolicy <Object>]
 [-ConfigSkipSecurityLoginMustChange <Object>] [-ConfigSkipSecurityLoginPasswordExpiration <Object>]
 [-ConfigSkipSecurityNonstandardport <Object>] [-ConfigSkipSecurityPublicPermission <Object>]
 [-ConfigSkipSecurityPublicrolepermission <Object>] [-ConfigSkipSecurityQuerystoredisabled <Object>]
 [-ConfigSkipSecurityQuerystoreenabled <Object>] [-ConfigSkipSecuritySadisabled <Object>]
 [-ConfigSkipSecuritySaexist <Object>] [-ConfigSkipSecurityServerprotocol <Object>]
 [-ConfigSkipSecuritySqlagentproxiesnopublicrole <Object>] [-ConfigSkipSecuritySQLMailXPsDisabled <Object>]
 [-ConfigSkipSecuritySymmetrickeyencryptionlevel <Object>] [-ConfigSkipTempdb1118 <Object>]
 [-ConfigSkipTempdbfilecount <Object>] [-ConfigSkipTempdbfilegrowthpercent <Object>]
 [-ConfigSkipTempdbfilesizemax <Object>] [-ConfigSkipTempdbfilesonc <Object>]
 [-ConfigTestingIntegrationInstance <Object>] [<CommonParameters>]
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
Set-DbcConfig -Name app.sqlinstance -Value sql2016, sql2017, sql2008, sql2008\express
Set-DbcConfig -Name app.computername -Value sql2016, sql2017, sql2008
```

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
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigAgentAlertJob
{{ Fill ConfigAgentAlertJob Description }}

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
{{ Fill ConfigAgentAlertMessageid Description }}

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
{{ Fill ConfigAgentAlertNotification Description }}

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
{{ Fill ConfigAgentAlertSeverity Description }}

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
{{ Fill ConfigAgentDatabasemailprofile Description }}

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
{{ Fill ConfigAgentDbaoperatoremail Description }}

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
{{ Fill ConfigAgentDbaoperatorname Description }}

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

### -ConfigAgentFailedjobExcludecancelled
{{ Fill ConfigAgentFailedjobExcludecancelled Description }}

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

### -ConfigAgentFailedjobSince
{{ Fill ConfigAgentFailedjobSince Description }}

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
{{ Fill ConfigAgentFailsafeoperator Description }}

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
{{ Fill ConfigAgentHistoryMaximumhistoryrows Description }}

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
{{ Fill ConfigAgentHistoryMaximumjobhistoryrows Description }}

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

### -ConfigAgentLastjobruntimePercentage
{{ Fill ConfigAgentLastjobruntimePercentage Description }}

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

### -ConfigAgentLongrunningjobPercentage
{{ Fill ConfigAgentLongrunningjobPercentage Description }}

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
{{ Fill ConfigAgentValidjobownerName Description }}

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
{{ Fill ConfigAppCheckrepos Description }}

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
{{ Fill ConfigAppCluster Description }}

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
{{ Fill ConfigAppComputername Description }}

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
{{ Fill ConfigAppLocalapp Description }}

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
{{ Fill ConfigAppMaildirectory Description }}

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
{{ Fill ConfigAppSqlcredential Description }}

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
{{ Fill ConfigAppSqlinstance Description }}

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
{{ Fill ConfigAppWincredential Description }}

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
{{ Fill ConfigCommandInvokedbccheckExcludecheck Description }}

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
{{ Fill ConfigCommandInvokedbccheckExcludedatabases Description }}

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
{{ Fill ConfigDatabaseExists Description }}

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

### -ConfigDatabaseQuerystoredisabledExcludedb
{{ Fill ConfigDatabaseQuerystoredisabledExcludedb Description }}

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

### -ConfigDatabaseQuerystoreenabledExcludedb
{{ Fill ConfigDatabaseQuerystoreenabledExcludedb Description }}

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
{{ Fill ConfigDomainDomaincontroller Description }}

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
{{ Fill ConfigDomainName Description }}

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
{{ Fill ConfigDomainOrganizationalunit Description }}

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
{{ Fill ConfigGlobalNotcontactable Description }}

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
{{ Fill ConfigMailFailurethreshhold Description }}

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
{{ Fill ConfigMailFrom Description }}

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
{{ Fill ConfigMailSmtpserver Description }}

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
{{ Fill ConfigMailSubject Description }}

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
{{ Fill ConfigMailTo Description }}

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

### -ConfigOlaJobNameCommandLogCleanup
{{ Fill ConfigOlaJobNameCommandLogCleanup Description }}

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

### -ConfigOlaJobNameDeleteBackupHistory
{{ Fill ConfigOlaJobNameDeleteBackupHistory Description }}

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

### -ConfigOlaJobNameOutputFileCleanup
{{ Fill ConfigOlaJobNameOutputFileCleanup Description }}

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

### -ConfigOlaJobNamePurgeBackupHistory
{{ Fill ConfigOlaJobNamePurgeBackupHistory Description }}

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

### -ConfigOlaJobNameSystemFull
{{ Fill ConfigOlaJobNameSystemFull Description }}

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

### -ConfigOlaJobNameSystemIntegrity
{{ Fill ConfigOlaJobNameSystemIntegrity Description }}

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

### -ConfigOlaJobNameUserDiff
{{ Fill ConfigOlaJobNameUserDiff Description }}

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

### -ConfigOlaJobNameUserFull
{{ Fill ConfigOlaJobNameUserFull Description }}

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

### -ConfigOlaJobNameUserIndex
{{ Fill ConfigOlaJobNameUserIndex Description }}

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

### -ConfigOlaJobNameUserIntegrity
{{ Fill ConfigOlaJobNameUserIntegrity Description }}

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

### -ConfigOlaJobNameUserLog
{{ Fill ConfigOlaJobNameUserLog Description }}

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
{{ Fill ConfigPolicyAdlogingroupExcludecheck Description }}

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
{{ Fill ConfigPolicyAdloginuserExcludecheck Description }}

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
{{ Fill ConfigPolicyBackupDatadir Description }}

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
{{ Fill ConfigPolicyBackupDefaultbackupcompression Description }}

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
{{ Fill ConfigPolicyBackupDiffmaxhours Description }}

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
{{ Fill ConfigPolicyBackupFullmaxdays Description }}

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
{{ Fill ConfigPolicyBackupLogdir Description }}

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
{{ Fill ConfigPolicyBackupLogmaxminutes Description }}

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
{{ Fill ConfigPolicyBackupNewdbgraceperiod Description }}

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
{{ Fill ConfigPolicyBackupTestserver Description }}

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
{{ Fill ConfigPolicyBuildBehind Description }}

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
{{ Fill ConfigPolicyBuildWarningwindow Description }}

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
{{ Fill ConfigPolicyCertificateexpirationExcludedb Description }}

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
{{ Fill ConfigPolicyCertificateexpirationWarningwindow Description }}

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

### -ConfigPolicyClusterHostrecordttl
{{ Fill ConfigPolicyClusterHostrecordttl Description }}

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

### -ConfigPolicyClusterNetworkProtocolsIPV4
{{ Fill ConfigPolicyClusterNetworkProtocolsIPV4 Description }}

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

### -ConfigPolicyClusterRegisterallprovidersIP
{{ Fill ConfigPolicyClusterRegisterallprovidersIP Description }}

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
{{ Fill ConfigPolicyConnectionAuthscheme Description }}

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
{{ Fill ConfigPolicyConnectionPingcount Description }}

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
{{ Fill ConfigPolicyConnectionPingmaxms Description }}

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
{{ Fill ConfigPolicyDacallowed Description }}

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
{{ Fill ConfigPolicyDatabaseAutoclose Description }}

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
{{ Fill ConfigPolicyDatabaseAutocreatestatistics Description }}

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
{{ Fill ConfigPolicyDatabaseAutoshrink Description }}

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
{{ Fill ConfigPolicyDatabaseAutoupdatestatistics Description }}

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
{{ Fill ConfigPolicyDatabaseAutoupdatestatisticsasynchronously Description }}

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

### -ConfigPolicyDatabaseClrassembliessafeexcludedb
{{ Fill ConfigPolicyDatabaseClrassembliessafeexcludedb Description }}

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

### -ConfigPolicyDatabaseDuplicateindexexcludedb
{{ Fill ConfigPolicyDatabaseDuplicateindexexcludedb Description }}

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
{{ Fill ConfigPolicyDatabaseFilebalancetolerance Description }}

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

### -ConfigPolicyDatabaseFilegrowthdaystocheck
{{ Fill ConfigPolicyDatabaseFilegrowthdaystocheck Description }}

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
{{ Fill ConfigPolicyDatabaseFilegrowthexcludedb Description }}

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
{{ Fill ConfigPolicyDatabaseFilegrowthfreespacethreshold Description }}

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
{{ Fill ConfigPolicyDatabaseFilegrowthtype Description }}

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
{{ Fill ConfigPolicyDatabaseFilegrowthvalue Description }}

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
{{ Fill ConfigPolicyDatabaseLogfilecount Description }}

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

### -ConfigPolicyDatabaseLogfilepercentused
{{ Fill ConfigPolicyDatabaseLogfilepercentused Description }}

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
{{ Fill ConfigPolicyDatabaseLogfilesizecomparison Description }}

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
{{ Fill ConfigPolicyDatabaseLogfilesizepercentage Description }}

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
{{ Fill ConfigPolicyDatabaseMaxdop Description }}

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
{{ Fill ConfigPolicyDatabaseMaxdopexcludedb Description }}

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
{{ Fill ConfigPolicyDatabaseMaxvlf Description }}

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
{{ Fill ConfigPolicyDatabaseStatusExcludeoffline Description }}

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
{{ Fill ConfigPolicyDatabaseStatusExcludereadonly Description }}

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
{{ Fill ConfigPolicyDatabaseStatusExcluderestoring Description }}

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

### -ConfigPolicyDatabaseTrustworthyexcludedb
{{ Fill ConfigPolicyDatabaseTrustworthyexcludedb Description }}

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
{{ Fill ConfigPolicyDatabaseWrongcollation Description }}

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
{{ Fill ConfigPolicyDbccMaxdays Description }}

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
{{ Fill ConfigPolicyDiskspacePercentfree Description }}

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
{{ Fill ConfigPolicyDumpMaxcount Description }}

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
{{ Fill ConfigPolicyErrorlogLogcount Description }}

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
{{ Fill ConfigPolicyErrorlogWarningwindow Description }}

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

### -ConfigPolicyHadrAgtcpport
{{ Fill ConfigPolicyHadrAgtcpport Description }}

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

### -ConfigPolicyHadrEndpointname
{{ Fill ConfigPolicyHadrEndpointname Description }}

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

### -ConfigPolicyHadrEndpointport
{{ Fill ConfigPolicyHadrEndpointport Description }}

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

### -ConfigPolicyHadrFailureconditionlevel
{{ Fill ConfigPolicyHadrFailureconditionlevel Description }}

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

### -ConfigPolicyHadrHealthchecktimeout
{{ Fill ConfigPolicyHadrHealthchecktimeout Description }}

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

### -ConfigPolicyHadrLeasetimeout
{{ Fill ConfigPolicyHadrLeasetimeout Description }}

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

### -ConfigPolicyHadrSessiontimeout
{{ Fill ConfigPolicyHadrSessiontimeout Description }}

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
{{ Fill ConfigPolicyHadrTcpport Description }}

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
{{ Fill ConfigPolicyIdentityUsagepercent Description }}

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
{{ Fill ConfigPolicyInstancemaxdopExcludeinstance Description }}

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
{{ Fill ConfigPolicyInstancemaxdopMaxdop Description }}

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
{{ Fill ConfigPolicyInstancemaxdopUserecommended Description }}

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

### -ConfigPolicyInstanceMemorydumpsdaystocheck
{{ Fill ConfigPolicyInstanceMemorydumpsdaystocheck Description }}

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

### -ConfigPolicyInstanceSqlenginestart
{{ Fill ConfigPolicyInstanceSqlenginestart Description }}

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

### -ConfigPolicyInstanceSqlenginestate
{{ Fill ConfigPolicyInstanceSqlenginestate Description }}

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
{{ Fill ConfigPolicyInvaliddbownerExcludedb Description }}

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
{{ Fill ConfigPolicyInvaliddbownerName Description }}

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
{{ Fill ConfigPolicyNetworkLatencymaxms Description }}

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

### -ConfigPolicyOlaCommandLogCleanUp
{{ Fill ConfigPolicyOlaCommandLogCleanUp Description }}

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

### -ConfigPolicyOlaCommandLogenabled
{{ Fill ConfigPolicyOlaCommandLogenabled Description }}

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

### -ConfigPolicyOlaCommandLogscheduled
{{ Fill ConfigPolicyOlaCommandLogscheduled Description }}

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
{{ Fill ConfigPolicyOlaDatabase Description }}

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

### -ConfigPolicyOlaDeleteBackupHistoryCleanUp
{{ Fill ConfigPolicyOlaDeleteBackupHistoryCleanUp Description }}

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

### -ConfigPolicyOlaDeleteBackupHistoryenabled
{{ Fill ConfigPolicyOlaDeleteBackupHistoryenabled Description }}

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

### -ConfigPolicyOlaDeleteBackupHistoryscheduled
{{ Fill ConfigPolicyOlaDeleteBackupHistoryscheduled Description }}

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
{{ Fill ConfigPolicyOlaInstalled Description }}

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

### -ConfigPolicyOlaOutputFileCleanUp
{{ Fill ConfigPolicyOlaOutputFileCleanUp Description }}

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

### -ConfigPolicyOlaOutputFileCleanupenabled
{{ Fill ConfigPolicyOlaOutputFileCleanupenabled Description }}

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

### -ConfigPolicyOlaOutputFileCleanupscheduled
{{ Fill ConfigPolicyOlaOutputFileCleanupscheduled Description }}

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

### -ConfigPolicyOlaPurgeJobHistoryCleanUp
{{ Fill ConfigPolicyOlaPurgeJobHistoryCleanUp Description }}

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

### -ConfigPolicyOlaPurgeJobHistoryenabled
{{ Fill ConfigPolicyOlaPurgeJobHistoryenabled Description }}

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

### -ConfigPolicyOlaPurgeJobHistoryscheduled
{{ Fill ConfigPolicyOlaPurgeJobHistoryscheduled Description }}

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
{{ Fill ConfigPolicyOlaSystemfullenabled Description }}

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
{{ Fill ConfigPolicyOlaSystemfullretention Description }}

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
{{ Fill ConfigPolicyOlaSystemfullscheduled Description }}

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

### -ConfigPolicyOlaSystemIntegrityCheckenabled
{{ Fill ConfigPolicyOlaSystemIntegrityCheckenabled Description }}

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

### -ConfigPolicyOlaSystemIntegrityCheckscheduled
{{ Fill ConfigPolicyOlaSystemIntegrityCheckscheduled Description }}

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
{{ Fill ConfigPolicyOlaUserdiffenabled Description }}

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
{{ Fill ConfigPolicyOlaUserdiffretention Description }}

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
{{ Fill ConfigPolicyOlaUserdiffscheduled Description }}

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
{{ Fill ConfigPolicyOlaUserfullenabled Description }}

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
{{ Fill ConfigPolicyOlaUserfullretention Description }}

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
{{ Fill ConfigPolicyOlaUserfullscheduled Description }}

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

### -ConfigPolicyOlaUserIndexOptimizeenabled
{{ Fill ConfigPolicyOlaUserIndexOptimizeenabled Description }}

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

### -ConfigPolicyOlaUserIndexOptimizescheduled
{{ Fill ConfigPolicyOlaUserIndexOptimizescheduled Description }}

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

### -ConfigPolicyOlaUserIntegrityCheckenabled
{{ Fill ConfigPolicyOlaUserIntegrityCheckenabled Description }}

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

### -ConfigPolicyOlaUserIntegrityCheckscheduled
{{ Fill ConfigPolicyOlaUserIntegrityCheckscheduled Description }}

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
{{ Fill ConfigPolicyOlaUserlogenabled Description }}

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
{{ Fill ConfigPolicyOlaUserlogretention Description }}

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
{{ Fill ConfigPolicyOlaUserlogscheduled Description }}

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
{{ Fill ConfigPolicyOleautomation Description }}

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
{{ Fill ConfigPolicyPageverify Description }}

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
{{ Fill ConfigPolicyRecoverymodelExcludedb Description }}

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
{{ Fill ConfigPolicyRecoverymodelType Description }}

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
{{ Fill ConfigPolicySecurityAdhocdistributedqueriesenabled Description }}

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
{{ Fill ConfigPolicySecurityClrenabled Description }}

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

### -ConfigPolicySecurityContainedbautoclose
{{ Fill ConfigPolicySecurityContainedbautoclose Description }}

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
{{ Fill ConfigPolicySecurityCrossdbownershipchaining Description }}

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
{{ Fill ConfigPolicySecurityDatabasemailenabled Description }}

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

### -ConfigPolicySecurityLatestbuild
{{ Fill ConfigPolicySecurityLatestbuild Description }}

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

### -ConfigPolicySecurityOleautomationproceduresdisabled
{{ Fill ConfigPolicySecurityOleautomationproceduresdisabled Description }}

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

### -ConfigPolicySecurityRemoteaccessdisabled
{{ Fill ConfigPolicySecurityRemoteaccessdisabled Description }}

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

### -ConfigPolicySecurityScanforstartupproceduresdisabled
{{ Fill ConfigPolicySecurityScanforstartupproceduresdisabled Description }}

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
{{ Fill ConfigPolicySecurityXpcmdshelldisabled Description }}

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
{{ Fill ConfigPolicyServerCpuprioritisation Description }}

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

### -ConfigPolicyServerExcludeDiskAllocationUnit
{{ Fill ConfigPolicyServerExcludeDiskAllocationUnit Description }}

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
{{ Fill ConfigPolicyStorageBackuppath Description }}

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

### -ConfigPolicySuspectpagesThreshold
{{ Fill ConfigPolicySuspectpagesThreshold Description }}

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
{{ Fill ConfigPolicyTraceflagsExpected Description }}

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
{{ Fill ConfigPolicyTraceflagsNotexpected Description }}

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
{{ Fill ConfigPolicyTwodigityearcutoff Description }}

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
{{ Fill ConfigPolicyValiddbownerExcludedb Description }}

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
{{ Fill ConfigPolicyValiddbownerName Description }}

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
{{ Fill ConfigPolicyWhoisactiveDatabase Description }}

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
{{ Fill ConfigPolicyXeventRequiredrunningsession Description }}

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
{{ Fill ConfigPolicyXeventRequiredstoppedsession Description }}

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
{{ Fill ConfigPolicyXeventValidrunningsession Description }}

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

### -ConfigSkipAgentAlert
{{ Fill ConfigSkipAgentAlert Description }}

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

### -ConfigSkipAgentLastjobruntime
{{ Fill ConfigSkipAgentLastjobruntime Description }}

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

### -ConfigSkipAgentLongrunningjobs
{{ Fill ConfigSkipAgentLongrunningjobs Description }}

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
{{ Fill ConfigSkipBackupReadonly Description }}

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

### -ConfigSkipBackupSecondaries
{{ Fill ConfigSkipBackupSecondaries Description }}

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
{{ Fill ConfigSkipBackupTesting Description }}

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

### -ConfigSkipClusterNetclusterinterface
{{ Fill ConfigSkipClusterNetclusterinterface Description }}

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
{{ Fill ConfigSkipConnectionAuth Description }}

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
{{ Fill ConfigSkipConnectionPing Description }}

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
{{ Fill ConfigSkipConnectionRemoting Description }}

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
{{ Fill ConfigSkipDatabaseFilegrowthdisabled Description }}

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
{{ Fill ConfigSkipDatabaseLogfilecounttest Description }}

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
{{ Fill ConfigSkipDatafilegrowthdisabled Description }}

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
{{ Fill ConfigSkipDbccDatapuritycheck Description }}

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
{{ Fill ConfigSkipDiffbackuptest Description }}

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
{{ Fill ConfigSkipHadrListenerPingcheck Description }}

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

### -ConfigSkipHadrListenerTcpport
{{ Fill ConfigSkipHadrListenerTcpport Description }}

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

### -ConfigSkipHadrReplicaTcpport
{{ Fill ConfigSkipHadrReplicaTcpport Description }}

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

### -ConfigSkipInstanceDefaulttrace
{{ Fill ConfigSkipInstanceDefaulttrace Description }}

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

### -ConfigSkipInstanceLatestbuild
{{ Fill ConfigSkipInstanceLatestbuild Description }}

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
{{ Fill ConfigSkipInstanceModeldbgrowth Description }}

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

### -ConfigSkipInstanceOleautomationproceduresdisabled
{{ Fill ConfigSkipInstanceOleautomationproceduresdisabled Description }}

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

### -ConfigSkipInstanceRemoteaccessdisabled
{{ Fill ConfigSkipInstanceRemoteaccessdisabled Description }}

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

### -ConfigSkipInstanceScanforstartupproceduresdisabled
{{ Fill ConfigSkipInstanceScanforstartupproceduresdisabled Description }}

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

### -ConfigSkipInstanceSuspectpagelimit
{{ Fill ConfigSkipInstanceSuspectpagelimit Description }}

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
{{ Fill ConfigSkipLogfilecounttest Description }}

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
{{ Fill ConfigSkipLogshiptesting Description }}

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

### -ConfigSkipSecurityAgentserviceadmin
{{ Fill ConfigSkipSecurityAgentserviceadmin Description }}

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

### -ConfigSkipSecurityAsymmetrickeysize
{{ Fill ConfigSkipSecurityAsymmetrickeysize Description }}

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

### -ConfigSkipSecurityBuiltinadmin
{{ Fill ConfigSkipSecurityBuiltinadmin Description }}

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

### -ConfigSkipSecurityClrassembliessafe
{{ Fill ConfigSkipSecurityClrassembliessafe Description }}

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

### -ConfigSkipSecurityContainedbautoclose
{{ Fill ConfigSkipSecurityContainedbautoclose Description }}

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

### -ConfigSkipSecurityContainedDBSQLAuth
{{ Fill ConfigSkipSecurityContainedDBSQLAuth Description }}

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

### -ConfigSkipSecurityEngineserviceadmin
{{ Fill ConfigSkipSecurityEngineserviceadmin Description }}

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

### -ConfigSkipSecurityFulltextserviceadmin
{{ Fill ConfigSkipSecurityFulltextserviceadmin Description }}

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

### -ConfigSkipSecurityGuestuserconnect
{{ Fill ConfigSkipSecurityGuestuserconnect Description }}

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

### -ConfigSkipSecurityHideinstance
{{ Fill ConfigSkipSecurityHideinstance Description }}

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

### -ConfigSkipSecurityLocalwindowsgroup
{{ Fill ConfigSkipSecurityLocalwindowsgroup Description }}

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

### -ConfigSkipSecurityLoginauditlevelfailed
{{ Fill ConfigSkipSecurityLoginauditlevelfailed Description }}

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

### -ConfigSkipSecurityLoginauditlevelsuccessful
{{ Fill ConfigSkipSecurityLoginauditlevelsuccessful Description }}

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

### -ConfigSkipSecurityLoginCheckPolicy
{{ Fill ConfigSkipSecurityLoginCheckPolicy Description }}

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

### -ConfigSkipSecurityLoginMustChange
{{ Fill ConfigSkipSecurityLoginMustChange Description }}

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

### -ConfigSkipSecurityLoginPasswordExpiration
{{ Fill ConfigSkipSecurityLoginPasswordExpiration Description }}

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

### -ConfigSkipSecurityNonstandardport
{{ Fill ConfigSkipSecurityNonstandardport Description }}

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

### -ConfigSkipSecurityPublicPermission
{{ Fill ConfigSkipSecurityPublicPermission Description }}

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

### -ConfigSkipSecurityPublicrolepermission
{{ Fill ConfigSkipSecurityPublicrolepermission Description }}

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

### -ConfigSkipSecurityQuerystoredisabled
{{ Fill ConfigSkipSecurityQuerystoredisabled Description }}

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

### -ConfigSkipSecurityQuerystoreenabled
{{ Fill ConfigSkipSecurityQuerystoreenabled Description }}

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

### -ConfigSkipSecuritySadisabled
{{ Fill ConfigSkipSecuritySadisabled Description }}

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

### -ConfigSkipSecuritySaexist
{{ Fill ConfigSkipSecuritySaexist Description }}

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

### -ConfigSkipSecurityServerprotocol
{{ Fill ConfigSkipSecurityServerprotocol Description }}

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

### -ConfigSkipSecuritySqlagentproxiesnopublicrole
{{ Fill ConfigSkipSecuritySqlagentproxiesnopublicrole Description }}

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

### -ConfigSkipSecuritySQLMailXPsDisabled
{{ Fill ConfigSkipSecuritySQLMailXPsDisabled Description }}

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

### -ConfigSkipSecuritySymmetrickeyencryptionlevel
{{ Fill ConfigSkipSecuritySymmetrickeyencryptionlevel Description }}

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
{{ Fill ConfigSkipTempdb1118 Description }}

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
{{ Fill ConfigSkipTempdbfilecount Description }}

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
{{ Fill ConfigSkipTempdbfilegrowthpercent Description }}

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
{{ Fill ConfigSkipTempdbfilesizemax Description }}

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
{{ Fill ConfigSkipTempdbfilesonc Description }}

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
{{ Fill ConfigTestingIntegrationInstance Description }}

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://dbachecks.readthedocs.io/en/latest/functions/Invoke-DbcCheck/](https://dbachecks.readthedocs.io/en/latest/functions/Invoke-DbcCheck/)

