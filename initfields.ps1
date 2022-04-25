# uses Jakubs Profiler Module - Install-Module Profiler
$withinitFIeldsSMO = {
    $password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password
    
    $Sqlinstances = 'localhost,7401', 'localhost,7402', 'localhost,7403'
    $smos = Connect-DbaInstance -SqlInstance $Sqlinstances -SqlCredential $cred 
    
    foreach ($smo in $smos) {
        $smo.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Server], $false)
        $smo.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database], $false)
        $smo.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Login], $false)
        $smo.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.Job], $false)
        $initfields = $smo.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Server])
        $initfields.Add("Collation")
        $smo.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Server], $initfields)
        $dbinitfields = $smo.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database])
        $dbinitfields.Add("Collation")
        $smo.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database], $initfields)
    
        [PSCustomObject]@{
            ComputerName = $smo.ComputerName
            InstanceName = $smo.DbaInstanceName
            Collation    = $smo.Collation
            Databases    = $Smo.Databases.ForEach{
                [PSCustomObject]@{
                    Name      = $_.Name
                    Collation = $_.Collation
                }
            
            }
        }
    }
}

$WithoutInitFieldsSMO = {
    $password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password
    
    $Sqlinstances = 'localhost,7401', 'localhost,7402', 'localhost,7403'
    $smos = Connect-DbaInstance -SqlInstance $Sqlinstances -SqlCredential $cred
    foreach ($smo in $smos) {
        [PSCustomObject]@{
            ComputerName = $smo.ComputerName
            InstanceName = $smo.DbaInstanceName
            Collation    = $smo.Collation
            Databases    = $Smo.Databases.ForEach{
                [PSCustomObject]@{
                    Name      = $_.Name
                    Collation = $_.Collation
                }
            
            }
        }
    }
}

$justdbatools = {
    $password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password
    
    $Sqlinstances = 'localhost,7401', 'localhost,7402', 'localhost,7403'
    $smos = Connect-DbaInstance -SqlInstance $Sqlinstances -SqlCredential $cred

    foreach($smo in $smos){
        $collation = Test-DbaDbCollation -SqlInstance $smo

        [PSCustomObject]@{
            ComputerName = $smo.ComputerName
            InstanceName = $smo.DbaInstanceName
            Collation    = $collation[0].ServerCollation
            Databases    = $collation.ForEach{
                [PSCustomObject]@{
                    Name      = $_.Database
                    Collation = $_.DatabaseCollation
                }
            }
        }
    }
    
}

# so the initial load doesnt skew the figures
ipmo dbatools
function prompt { Write-Host "pwsh >" -NoNewline; ' '}

$justdbatoolstrace = Trace-Script -ScriptBlock $justdbatools
$WithoutInittrace = Trace-Script -ScriptBlock $WithoutInitFieldsSMO 
$withinittrace = Trace-Script -ScriptBlock $withinitFIeldsSMO 


$dbatoolsMessage = "With dbatools it takes {0} MilliSeconds" -f $justdbatoolstrace.StopwatchDuration.TotalMilliseconds
$withinittMessage = "With initfields and SMO it takes {0} MilliSeconds" -f $withinittrace.StopwatchDuration.TotalMilliseconds
$WithoutInitMessage = "Without initfields and SMO it takes {0} MilliSeconds" -f $WithoutInittrace.StopwatchDuration.TotalMilliseconds

Write-PSFMessage -Message $dbatoolsMessage -Level Significant
Write-PSFMessage -Message $WithoutInitMessage -Level Significant
Write-PSFMessage -Message $withinittMessage -Level Significant

<#
pwsh > Write-PSFMessage -Message $dbatoolsMessage -Level Significant
[10:36:20][<ScriptBlock>] With dbatools it takes 308.9962 MilliSeconds
pwsh > Write-PSFMessage -Message $WithoutInitMessage -Level Significant
[10:36:20][<ScriptBlock>] Without initfields and SMO it takes 270.5188 MilliSeconds
pwsh > Write-PSFMessage -Message $withinittMessage -Level Significant
[10:36:20][<ScriptBlock>] With initfields and SMO it takes 117.5935 MilliSeconds

#>


$10timesWithInit = Invoke-Script -ScriptBlock $withinitFIeldsSMO -Preheat 0 -Repeat 10 




















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

