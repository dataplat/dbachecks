## To Test pull the dbatools docker repo and cd to the samples/stackoverflow Directory

## I changed the ports because I have some of them already running SQL

##     line 17   - "7401:1433"
##     line 34   - "7402:1433"
##     line 52   - "7403:1433"

#then docker compose up -d

# cd to the root of dbachecks and checkout the pesterv5 branch


<#
What Is here
So I have removed the check for Pester v5 from the psm1 load

and created 2 internal functions Invoke-DbcCheckv4 and Invoke-DbcCheckv5

and added a legacy param to Invoke-DbcCheck
by default it passes everything on to Invoke-DbcCheckv4 which is still the same as the original Invoke-DbcCheck so it shouldnt break anything

So If you can test original work with Pester v4 that would be great.

#>

 ipmo ./dbachecks.psd1  -Verbose

 # We run Pester V4 here because the -legacy parameter of Invoke-DbcCheck is set to true by default
$password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password

$PSDefaultParameterValues = @{

    "Invoke-DbcCheck:SqlInstance" = 'localhost,7401','localhost,7409'
    "Invoke-DbcCheck:SqlCredential" = $cred
}

$Sqlinstances = 'localhost,7401','localhost,7402','localhost,7403'

$broken = 'localhost,7401','localhost,7409'

# check not contactable instances
Invoke-DbcCheck -SqlInstance $broken  -Check ValidJobOwner -SqlCredential $cred  -Verbose
Invoke-DbcCheck -Check DatabaseCollation -SqlCredential $cred
# especially check both default params and specified - also need to check config too
Invoke-DbcCheck -SqlInstance $broken -Check DatabaseCollation -SqlCredential $cred  
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check DatabaseCollation -SqlCredential $cred  
Invoke-DbcCheck -SqlInstance $Sqlinstances -Check DatabaseCollation -SqlCredential $cred  
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check DatabaseStatus -SqlCredential $cred  
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check AdHocDistributedQueriesEnabled -SqlCredential $cred
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check AgentAlert -SqlCredential $cred
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check AgentServiceAccount -SqlCredential $cred
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check Backup -SqlCredential $cred
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check CIS -SqlCredential $cred
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check ExtendedEvent -SqlCredential $cred
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check VirtualLogFile -SqlCredential $cred
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check TempDbConfiguration -SqlCredential $cred
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check InstanceConnection -SqlCredential $cred

###############################

 # We run Pester V5 here because the -legacy parameter of Invoke-DbcCheck is set to false as a default param


 ## NOt working

 # AutoClose, AutoSHrink
 # You dont have to reimport 

ipmo ./dbachecks.psd1 # -Verbose
Reset-DbcConfig

$password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password

$Sqlinstances = 'localhost,7401','localhost,7402','localhost,7403'

$PSDefaultParameterValues.Clear()
# set default params for single instance and v5

$PSDefaultParameterValues = @{
    "Invoke-DbcCheck:legacy" = $false
    "Invoke-DbcCheck:SqlInstance" = $Sqlinstances[0]
    "Invoke-DbcCheck:SqlCredential" = $cred
}

# set default params for multiple instances

$PSDefaultParameterValues = @{
    "Invoke-DbcCheck:legacy" = $false
    "Invoke-DbcCheck:SqlInstance" = $Sqlinstances[0..1]
    "Invoke-DbcCheck:SqlCredential" = $cred
}

# set default params for multiple instances with a broken one

$PSDefaultParameterValues = @{
    "Invoke-DbcCheck:legacy" = $false
    "Invoke-DbcCheck:SqlInstance" = 'localhost,7401','localhost,7409'
    "Invoke-DbcCheck:SqlCredential" = $cred
}


# a single tag from each of the groups

<#
$Code = Get-DbcCheck -Group Instance | ForEach-Object {
     "Invoke-DbcCheck -Check {0} -Show Detailed" -f $_.UniqueTag 
}
$code | scb
$Code = Get-DbcCheck -Group Database | ForEach-Object {
     "Invoke-DbcCheck -Check {0} -Show Detailed" -f $_.UniqueTag 
}
$code | scb
$Code = Get-DbcCheck -Group Agent | ForEach-Object {
     "Invoke-DbcCheck -Check {0} -Show Detailed" -f $_.UniqueTag 
}
$code | scb
#>
#region Instance

Invoke-DbcCheck -Check InstanceConnection -Show Detailed
Invoke-DbcCheck -Check SqlEngineServiceAccount -Show Detailed
Invoke-DbcCheck -Check TempDbConfiguration -Show Detailed
Invoke-DbcCheck -Check AdHocWorkload -Show Detailed
Invoke-DbcCheck -Check BackupPathAccess -Show Detailed
Invoke-DbcCheck -Check DefaultFilePath -Show Detailed
Invoke-DbcCheck -Check DAC -Show Detailed
Invoke-DbcCheck -Check NetworkLatency -Show Detailed
Invoke-DbcCheck -Check LinkedServerConnection -Show Detailed
Invoke-DbcCheck -Check MaxMemory -Show Detailed
Invoke-DbcCheck -Check OrphanedFile -Show Detailed
Invoke-DbcCheck -Check ServerNameMatch -Show Detailed
Invoke-DbcCheck -Check MemoryDump -Show Detailed
Invoke-DbcCheck -Check SupportedBuild -Show Detailed
Invoke-DbcCheck -Check SaRenamed -Show Detailed
Invoke-DbcCheck -Check SaDisabled -Show Detailed
Invoke-DbcCheck -Check SaExist -Show Detailed
Invoke-DbcCheck -Check DefaultBackupCompression -Show Detailed
Invoke-DbcCheck -Check XESessionStopped -Show Detailed
Invoke-DbcCheck -Check XESessionRunning -Show Detailed
Invoke-DbcCheck -Check XESessionRunningAllowed -Show Detailed
Invoke-DbcCheck -Check OLEAutomation -Show Detailed
Invoke-DbcCheck -Check WhoIsActiveInstalled -Show Detailed
Invoke-DbcCheck -Check ModelDbGrowth -Show Detailed
Invoke-DbcCheck -Check ADUser -Show Detailed
Invoke-DbcCheck -Check ErrorLog -Show Detailed
Invoke-DbcCheck -Check ErrorLogCount -Show Detailed
Invoke-DbcCheck -Check MaxDopInstance -Show Detailed
Invoke-DbcCheck -Check TwoDigitYearCutoff -Show Detailed
Invoke-DbcCheck -Check TraceFlagsExpected -Show Detailed
Invoke-DbcCheck -Check TraceFlagsNotExpected -Show Detailed
Invoke-DbcCheck -Check CLREnabled -Show Detailed
Invoke-DbcCheck -Check CrossDBOwnershipChaining -Show Detailed
Invoke-DbcCheck -Check AdHocDistributedQueriesEnabled -Show Detailed
Invoke-DbcCheck -Check XpCmdShellDisabled -Show Detailed
Invoke-DbcCheck -Check ScanForStartupProceduresDisabled -Show Detailed
Invoke-DbcCheck -Check DefaultTrace -Show Detailed
Invoke-DbcCheck -Check OLEAutomationProceduresDisabled -Show Detailed
Invoke-DbcCheck -Check RemoteAccessDisabled -Show Detailed
Invoke-DbcCheck -Check LatestBuild -Show Detailed
Invoke-DbcCheck -Check BuiltInAdmin -Show Detailed
Invoke-DbcCheck -Check LocalWindowsGroup -Show Detailed
Invoke-DbcCheck -Check LoginAuditFailed -Show Detailed
Invoke-DbcCheck -Check LoginAuditSuccessful -Show Detailed
Invoke-DbcCheck -Check SqlAgentProxiesNoPublicRole -Show Detailed
Invoke-DbcCheck -Check HideInstance -Show Detailed
Invoke-DbcCheck -Check EngineServiceAdmin -Show Detailed
Invoke-DbcCheck -Check AgentServiceAdmin -Show Detailed
Invoke-DbcCheck -Check FullTextServiceAdmin -Show Detailed
Invoke-DbcCheck -Check LoginCheckPolicy -Show Detailed
Invoke-DbcCheck -Check LoginPasswordExpiration -Show Detailed
Invoke-DbcCheck -Check LoginMustChange -Show Detailed
Invoke-DbcCheck -Check SuspectPageLimit -Show Detailed
Invoke-DbcCheck -Check SQLMailXPsDisabled -Show Detailed
Invoke-DbcCheck -Check PublicPermission -Show Detailed
Invoke-DbcCheck -Check SqlBrowserServiceAccount -Show Detailed
#endregion
#region Database

Invoke-DbcCheck -Check Database -Show Detailed -Verbose
Invoke-DbcCheck -Check DatabaseCollation,SuspectPage
Invoke-DbcCheck -Check SuspectPage -Show Detailed
Invoke-DbcCheck -Check TestLastBackup -Show Detailed
Invoke-DbcCheck -Check TestLastBackupVerifyOnly -Show Detailed
Invoke-DbcCheck -Check ValidDatabaseOwner -Show Detailed
Invoke-DbcCheck -Check InvalidDatabaseOwner -Show Detailed
Invoke-DbcCheck -Check LastGoodCheckDb -Show Detailed
Invoke-DbcCheck -Check IdentityUsage -Show Detailed
Invoke-DbcCheck -Check RecoveryModel -Show Detailed
Invoke-DbcCheck -Check DuplicateIndex -Show Detailed
Invoke-DbcCheck -Check UnusedIndex -Show Detailed
Invoke-DbcCheck -Check DisabledIndex -Show Detailed
Invoke-DbcCheck -Check DatabaseGrowthEvent -Show Detailed
Invoke-DbcCheck -Check PageVerify -Show Detailed
Invoke-DbcCheck -Check AutoClose -Show Detailed
Invoke-DbcCheck -Check AutoShrink -Show Detailed
Invoke-DbcCheck -Check LastFullBackup -Show Detailed
Invoke-DbcCheck -Check LastDiffBackup -Show Detailed
Invoke-DbcCheck -Check LastLogBackup -Show Detailed
Invoke-DbcCheck -Check LogfilePercentUsed -Show Detailed
Invoke-DbcCheck -Check VirtualLogFile -Show Detailed
Invoke-DbcCheck -Check LogfileCount -Show Detailed
Invoke-DbcCheck -Check LogfileSize -Show Detailed
Invoke-DbcCheck -Check FutureFileGrowth -Show Detailed
Invoke-DbcCheck -Check FileGroupBalanced -Show Detailed
Invoke-DbcCheck -Check CertificateExpiration -Show Detailed
Invoke-DbcCheck -Check AutoCreateStatistics -Show Detailed
Invoke-DbcCheck -Check AutoUpdateStatistics -Show Detailed
Invoke-DbcCheck -Check AutoUpdateStatisticsAsynchronously -Show Detailed
Invoke-DbcCheck -Check DatafileAutoGrowthType -Show Detailed
Invoke-DbcCheck -Check Trustworthy -Show Detailed
Invoke-DbcCheck -Check OrphanedUser -Show Detailed
Invoke-DbcCheck -Check PseudoSimple -Show Detailed
Invoke-DbcCheck -Check CompatibilityLevel -Show Detailed
Invoke-DbcCheck -Check FKCKTrusted -Show Detailed
Invoke-DbcCheck -Check MaxDopDatabase -Show Detailed
Invoke-DbcCheck -Check DatabaseStatus -Show Detailed
Invoke-DbcCheck -Check DatabaseExists -Show Detailed
Invoke-DbcCheck -Check ContainedDBAutoClose -Show Detailed
Invoke-DbcCheck -Check CLRAssembliesSafe -Show Detailed
Invoke-DbcCheck -Check GuestUserConnect -Show Detailed
Invoke-DbcCheck -Check AsymmetricKeySize -Show Detailed
Invoke-DbcCheck -Check SymmetricKeyEncryptionLevel -Show Detailed
Invoke-DbcCheck -Check ContainedDBSQLAuth -Show Detailed
Invoke-DbcCheck -Check QueryStoreEnabled -Show Detailed
Invoke-DbcCheck -Check QueryStoreDisabled -Show Detailed
#endregion
#region Agent
Invoke-DbcCheck -Check DatabaseMailEnabled -Show Detailed
Invoke-DbcCheck -Check AgentServiceAccount -Show Detailed
Invoke-DbcCheck -Check DbaOperator -Show Detailed
Invoke-DbcCheck -Check FailsafeOperator -Show Detailed
Invoke-DbcCheck -Check DatabaseMailProfile -Show Detailed
Invoke-DbcCheck -Check AgentMailProfile -Show Detailed
Invoke-DbcCheck -Check FailedJob -Show Detailed
Invoke-DbcCheck -Check ValidJobOwner -Show Detailed
Invoke-DbcCheck -Check AgentAlert -Show Detailed
Invoke-DbcCheck -Check JobHistory -Show Detailed
Invoke-DbcCheck -Check LongRunningJob -Show Detailed
Invoke-DbcCheck -Check LastJobRunTime -Show Detailed
#endregion

# multiple tags same group

Invoke-DbcCheck -Check AutoClose -Show All






























































































$password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password


$Sqlinstances = 'localhost,7401','localhost,7402','localhost,7403'

$sql1 = Connect-DbaInstance -SqlInstance $Sqlinstances[0] -SqlCredential $cred
$sql2 = Connect-DbaInstance -SqlInstance $Sqlinstances[1] -SqlCredential $cred
$sql3 = Connect-DbaInstance -SqlInstance $Sqlinstances[2] -SqlCredential $cred


Get-DbcConfig -Name agent.validjobowner.name 
Set-DbcConfig -Name agent.validjobowner.name -Value 'NotRob','NotGrilliam','ProperJobOwnerAccount','OldNamingConventionJobAccount'
Invoke-DbcCheck -SqlInstance $sql1 -Check ValidJobOwner -SqlCredential $cred

New-DbaLogin $sql1,$sql2,$sql3 -Login Monica 
New-DbaLogin $sql1,$sql2,$sql3 -Login 'ProperJobOwnerAccount'
Set-DbaAgentJobOwner -SqlInstance $sql1,$sql2,$sql3 -Job 'IndexOptimize - USER_DATABASES' -Login Monica
Set-DbaAgentJobOwner -SqlInstance $sql1,$sql2,$sql3  -Login 'NotGrilliam'

# Dirks Bye, I am leaving script
Set-DbaAgentJobOwner -SqlInstance $sql1 -Login 'ProperJobOwnerAccount'
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check ValidJobOwner -SqlCredential $cred
