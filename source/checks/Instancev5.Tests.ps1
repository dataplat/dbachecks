# So the v5 files need to be handled differently.
# Ww will start with a BeforeDiscovery which will gather the Instance Information up front
# Gather the instances we know are not contactable

BeforeDiscovery {
    # Gather the instances we know are not contactable
    [string[]]$NotContactable = (Get-PSFConfig -Module dbachecks -Name global.notcontactable).Value
    # Get all the tags in use in this run
    $Tags = Get-CheckInformation -Check $Check -Group Instance -AllChecks $AllChecks -ExcludeCheck $ChecksToExclude

    $InstancesToTest = @(Get-Instance).ForEach{
        # just add it to the Not Contactable list
        if ($NotContactable -notcontains $psitem) {
            $Instance = $psitem
            try {
                $InstanceSMO = Connect-DbaInstance -SqlInstance $Instance -ErrorAction SilentlyContinue -ErrorVariable errorvar
            } catch {
                $NotContactable += $Instance
            }
            if ($NotContactable -notcontains $psitem) {
                if ($null -eq $InstanceSMO.version) {
                    $NotContactable += $Instance
                } else {
                    # Get the relevant information for the checks in one go to save repeated trips to the instance and set values for Not Contactable tests if required
                    NewGet-AllInstanceInfo -Instance $InstanceSMO -Tags $Tags
                }
            }
        }
    }
    Write-PSFMessage -Message "Instances = $($InstancesToTest.Name)" -Level Verbose
    #if you ever need to see what is being tested uncomment and run in verbose but this crashed with a weird  Microsoft.SqlServer.Management.Sdk.Sfc.InvalidQueryExpressionEnumeratorException: urn could not be resolved at level OleDbProviderSetting.
    # $InstancesToTestJson = $InstancesToTest | ConvertTo-Json -Depth 10
    #Write-PSFMessage -Message "InstancesToTest = $InstancesToTestJson" -Level Verbose
    Set-PSFConfig -Module dbachecks -Name global.notcontactable -Value $NotContactable
    # Get-DbcConfig is expensive so we call it once
    $__dbcconfig = Get-DbcConfig
}

Describe "Instance Connection" -Tag InstanceConnection, Connectivity, High, Instance -ForEach $InstancesToTest {
    BeforeAll {
        $skipall = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.connection' }).Value
        $skipremote = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.connection.remoting' }).Value
        $skipping = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.connection.ping' }).Value
        $skipauth = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.connection.auth' }).Value
        $authscheme = ($__dbcconfig | Where-Object { $_.Name -eq 'policy.connection.authscheme' }).Value
    }
    BeforeDiscovery {
        $skipall = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.connection' }).Value
        $skipremote = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.connection.remoting' }).Value
        $skipping = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.connection.ping' }).Value
        $skipauth = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.connection.auth' }).Value
        $authscheme = ($__dbcconfig | Where-Object { $_.Name -eq 'policy.connection.authscheme' }).Value
    }

    Context "Checking Instance Connection on on <_.Name>" -Skip:$skipall {
        It "connects successfully to <_.Name>" -Skip:$skipall {
            $PsItem.InstanceConnection.Connect | Should -BeTrue -Because "We expect the instance to be connectable"
        }
        It "auth scheme should be $authscheme on <_.Name>" -Skip:$skipauth {
            $PsItem.InstanceConnection.AuthScheme | Should -Be $authscheme -Because "We expect the auth scheme to be $authscheme"
        }
        It "We should be able to ping host <_.Name>" -Skip:$skipping {
            $PsItem.InstanceConnection.Ping | Should -Be 'Success' -Because "We expect the instance to be pingable"
        }
        It "We should be able to remote onto <_.Name>" -Skip:$skipremote {
            $PsItem.InstanceConnection.Remote | Should -BeTrue -Because "We expect the instance to be remotely connectable"
        }
    }
}

Describe "Default Trace" -Tag DefaultTrace, CIS, Low, Instance -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.defaulttrace' }).Value
    Context "Checking Default Trace on <_.Name>" {
        It "The Default Trace should be enabled on <_.Name>" -Skip:$skip {
            $PSItem.Configuration.DefaultTraceEnabled.ConfigValue | Should -Be 1 -Because "We expected the Default Trace to be enabled"
        }
    }
}
Describe "OLE Automation Procedures Disabled" -Tag OleAutomationProceduresDisabled, CIS, Low, Instance -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.oleautomationproceduresdisabled' }).Value
    Context "Checking OLE Automation Procedures on <_.Name>" {
        It "The OLE Automation Procedures should be disabled on <_.Name>" -Skip:$skip {
            $PSItem.Configuration.OleAutomationProceduresEnabled.ConfigValue | Should -Be 0 -Because "We expect the OLE Automation Procedures to be disabled"
        }
    }
}

Describe "Remote Access Disabled" -Tag RemoteAccessDisabled, Security, CIS, Low, Instance -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.remoteaccessdisabled' }).Value
    Context "Checking Remote Access on <_.Name>" {
        It "Remote Access should be disabled on <_.Name>" -Skip:$skip {
            $PSItem.Configuration.RemoteAccess.ConfigValue | Should -Be 0 -Because "We expected Remote Access to be disabled"
        }
    }
}

Describe "Cross Database Ownership Chaining" -Tag CrossDBOwnershipChaining, Security, CIS, Low, Instance -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.CrossDBOwnershipChaining' }).Value
    Context "Checking Cross Database Ownership Chaining on <_.Name>" {
        It "Cross Database Ownership Chaining should be disabled on <_.Name>" -Skip:$skip {
            $PSItem.Configuration.CrossDBOwnershipChaining.ConfigValue | Should -Be 0 -Because "We expected the Cross DB Ownership Chaining to be disabled"
        }
    }
}

Describe "Scan For Startup Procedures" -Tag ScanForStartupProceduresDisabled, Security, CIS, Low, Instance -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.scanforstartupproceduresdisabled' }).Value
    Context "Checking Scan For Startup Procedures on <_.Name>" {
        It "Scan For Startup Procedures is set to <_.ConfigValues.scanforstartupproceduresdisabled> on <_.Name>" -Skip:$skip {
            $PSItem.Configuration.ScanForStartupProcedures.ConfigValue -eq 0 | Should -Be $PSItem.ConfigValues.scanforstartupproceduresdisabled -Because "We expected the Cross DB Ownership Chaining to be disabled"
        }
    }
}

Describe "SQL Mail XPs Disabled" -Tag SQLMailXPsDisabled, Security, CIS, Low, Instance -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.SQLMailXPsDisabled' }).Value
    Context "Checking SQL Mail XPs on <_.Name>" {
        It "SQL Mail XPs should be disabled on <_.Name>" -Skip:($skip -or $psitem.VersionMajor -gt 10) {
            $PSItem.Configuration.SqlMailXPsEnabled.ConfigValue | Should -Be 0 -Because "We expected Sql Mail XPs to be disabled"
        }
    }
}

Describe "Dedicated Administrator Connection" -Tag DAC, Security, CIS, Low, Instance -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.dac' }).Value
    Context "Checking Dedicated Administrator Connection on <_.Name>" {
        It "DAC is set to <_.ConfigValues.dacallowed> on <_.Name>" -Skip:$skip {
            $PSItem.Configuration.RemoteDACConnectionsEnabled.ConfigValue -eq 1 | Should -Be $psitem.ConfigValues.dacallowed -Because 'This is the setting that you have chosen for DAC connections'
        }
    }
}

Describe "OLE Automation" -Tag OLEAutomation, Security, CIS, Low, Instance -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.oleautomation' }).Value
    Context "Checking OLE Automation on <_.Name>" {
        It "OLE Automation is set to <_.ConfigValues.OLEAutomation> on <_.Name>" -Skip:$skip {
            $PSItem.Configuration.OleAutomationProceduresEnabled.ConfigValue -eq 1 | Should -Be $psitem.ConfigValues.OLEAutomation -Because 'OLE Automation can introduce additional security risks'
        }
    }
}
Describe "Ad Hoc Workload Optimization" -Tag AdHocWorkload, Medium, Instance -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.AdHocWorkload' }).Value
    Context "Checking Ad Hoc Workload Optimization on <_.Name>" {
        It "Ad Hoc Workload Optimization is enabled on <_.Name>" -Skip:($skip -or $psitem.VersionMajor -lt 10) {
            $PSItem.Configuration.OptimizeAdhocWorkloads.ConfigValue -eq 1 | Should -Be 1 -Because "Optimize for ad hoc workloads is a recommended setting"
        }
    }
}

Describe "Ad Hoc Distributed Queries" -Tag AdHocDistributedQueriesEnabled, security, CIS, Medium, Instance -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.AdHocDistributedQueriesEnabled' }).Value
    Context "Checking Ad Hoc Distributed Queries on <_.Name>" {
        It "Ad Hoc Distributed Queries is set to <_.ConfigValues.AdHocDistributedQueriesEnabled> on <_.Name>" -Skip:$skip {
            $PSItem.Configuration.AdHocDistributedQueriesEnabled.ConfigValue -eq 1 | Should -Be $psitem.ConfigValues.AdHocDistributedQueriesEnabled -Because 'This is the setting you have chosen for AdHoc Distributed Queries Enabled'
        }
    }
}
Describe "Default File Path" -Tag DefaultFilePath, Instance -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.DefaultFilePath' }).Value
    Context "Checking Default Data File Path on <_.Name>" {
        It "Default Data File Path should not be on the C Drive on <_.Name>" -Skip:$skip {
            $PSItem.Settings.DefaultFile.substring(0, 1) | Should -Not -Be "C" -Because 'Default Data file path should not be your C:\ drive'
        }
        It "Default Log File Path should not be on the C Drive on <_.Name>" -Skip:$skip {
            $PSItem.Settings.DefaultLog.substring(0, 1) | Should -Not -Be "C" -Because 'Default Log file path should not be your C:\ drive'
        }
    }
}

Describe "SA Login Renamed" -Tag SaRenamed, DISA, CIS, Medium, Instance -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.SaRenamed' }).Value
    Context "Checking that sa login has been renamed on <_.Name>" {
        It "sa login has been renamed on <_.Name>" -Skip:$Skip {
            ($PsItem.Logins.Name) | Should -Not -BeIn 'sa' -Because "Renaming the sa account is a requirement"
        }
    }
}

Describe "SA Login Disabled" -Tag SaDisabled, DISA, CIS, Medium, Instance -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.security.sadisabled' }).Value
    Context "Checking that sa login has been disabled on <_.Name>" {
        It "sa login is disabled on <_.Name>" -Skip:$Skip {
            ($PsItem.Logins | Where-Object ID -EQ 1).IsDisabled | Should -Be $true -Because "We expected the original sa login to be disabled"
        }
    }
}

Describe "Login SA cannot exist" -Tag SaExist, CIS, Medium, Instance -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.security.saexist' }).Value
    Context "Checking that a login named sa does not exist on <_.Name>" {
        It "sa login does not exist on <_.Name>" -Skip:$Skip {
            $PsItem.Logins['sa'].Count | Should -Be 0 -Because "We expected no login to exist with the name sa"
        }
    }
}

Describe "Default Backup Compression" -Tag DefaultBackupCompression, Low, Instance -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.DefaultBackupCompression' }).Value
    Context "Checking Default Backup Compression on <_.Name>" {
        It "Default Backup Compression is set to <_.ConfigValues.DefaultBackupCompression> on <_.Name>" -Skip:$skip {
            $PSItem.Configuration.DefaultBackupCompression.ConfigValue -eq 1 | Should -Be $psitem.ConfigValues.DefaultBackupCompression -Because 'This is the setting you have chosen the default backup compression'
        }
    }
}

Describe "Model Database Growth" -Tag ModelDbGrowth, Low, Instance -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.modeldbgrowth' }).Value
    Context "Testing model database growth setting is not default on <_.Name>" {
        It "Growth settings should not be percent for file <_.Name> on <_.Parent.Parent.Parent.Name>" -Skip:$skip -ForEach $PsItem.Databases['model'].FileGroups.Files {
            $psitem.GrowthType | Should -Not -Be 'Percent' -Because 'New databases use the model database as a template and percent growth can cause performance problems'
        }
        It "Growth settings should not be 1Mb for file <_.Name> on <_.Parent.Parent.Parent.Name>" -Skip:$skip -ForEach $PsItem.Databases['model'].FileGroups.Files {
            $psitem.Growth | Should -Not -Be 1024 -Because 'New databases use the model database as a template and growing for each Mb will have a performance impact'
        }
        It "Growth settings should not be percent for file <_.Name> on <_.Parent.Parent.Name>" -Skip:$skip -ForEach @($PsItem.Databases['model'].LogFiles) {
            $psitem.GrowthType | Should -Not -Be 'Percent' -Because 'New databases use the model database as a template and percent growth can cause performance problems'
        }
        It "Growth settings should not be 1Mb for file <_.Name> on <_.Parent.Parent.Name>" -Skip:$skip -ForEach @($PsItem.Databases['model'].LogFiles) {
            $psitem.Growth | Should -Not -Be 1024 -Because 'New databases use the model database as a template and growing for each Mb will have a performance impact'
        }
    }
}

Describe "Error Log Count" -Tag ErrorLogCount, CIS, Low, Instance -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.ErrorLogCount' }).Value
    Context "Checking error log count on <_.Name>" {
        It "Error log count should be greater or equal to <_.ConfigValues.errorLogCount> on <_.Name>" -Skip:$skip {
            $psitem.NumberOfLogFiles | Should -BeGreaterOrEqual $psitem.ConfigValues.errorLogCount -Because "We expect to have at least $($psitem.ConfigValues.errorLogCount) number of error log files"
        }
    }
}

Describe "Instance MaxDop" -Tag MaxDopInstance, MaxDop, Medium, Instance -ForEach ($InstancesToTest | Where-Object { $psitem.Name -notin $psitem.ConfigValues.ExcludeInstanceMaxDop }) {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.MaxDopInstance' }).Value
    Context "Testing Instance MaxDop Value on <_.Name>" {
        #if UseRecommended - check that the CurrentInstanceMaxDop property returned from Test-DbaMaxDop matches the the RecommendedMaxDop property
        It "Instance Level MaxDop setting should be correct on <_.Name>" -Skip:$Skip -ForEach ($Psitem | Where-Object { $psitem.ConfigValues.UseRecommendedMaxDop -eq $true }) {
            $psitem.MaxDopSettings.CurrentInstanceMaxDop | Should -Be $psitem.MaxDopSettings.RecommendedMaxDop -Because "We expect the MaxDop Setting to be the default recommended value $($psitem.MaxDopSettings.RecommendedMaxDop)"
        }
        #if not UseRecommended - check that the CurrentInstanceMaxDop property returned from Test-DbaMaxDop matches the MaxDopValue parameter
        It "Instance Level MaxDop setting should be correct on <_.Name>" -Skip:$Skip -ForEach($Psitem | Where-Object { $psitem.ConfigValues.UseRecommendedMaxDop -ne $true }) {
            $psitem.MaxDopSettings.CurrentInstanceMaxDop | Should -Be $psitem.ConfigValues.InstanceMaxDop -Because "We expect the MaxDop Setting to be the value you specified $($psitem.ConfigValues.InstanceMaxDop)"
        }
    }
}

Describe "Two Digit Year Cutoff" -Tag TwoDigitYearCutoff, Low, Instance -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.TwoDigitYearCutoff' }).Value
    Context "Testing Two Digit Year Cutoff on <_.Name>" {
        It "Two Digit Year Cutoff is set to <_.ConfigValues.TwoDigitYearCutoff> on <_.Name>" -Skip:$skip {
            $PSItem.Configuration.TwoDigitYearCutoff.ConfigValue | Should -Be $psitem.ConfigValues.TwoDigitYearCutoff -Because 'This is the value that you have chosen for Two Digit Year Cutoff configuration'
        }
    }
}

Describe "Trace Flags Expected" -Tag TraceFlagsExpected, TraceFlag, High, Instance -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.TraceFlagsExpected' }).Value
    Context "Testing Expected Trace Flags on <_.Name>" {
        It "Expected No Trace Flags to exist on <_.Name>" -Skip:$skip -ForEach ($Psitem | Where-Object { $null -eq $psitem.ConfigValues.TraceFlagsExpected }) {
            $PsItem.ExpectedTraceFlags.ActualTraceFlags.TraceFlag | Should -BeNullOrEmpty -Because "We expect that there will be no Trace Flags set on $($Psitem.Name) "
        }
        It "Expected Trace Flags <_.ExpectedTraceFlag> to exist on <_.InstanceName>" -Skip:$skip -ForEach ($PsItem.ExpectedTraceFlags | Where-Object { $psitem.ExpectedTraceFlag -ne 'null' }) {
            $PsItem.ActualTraceFlags.TraceFlag | Should -Contain $PsItem.ExpectedTraceFlag -Because "We expect that Trace Flag $($PsItem.ExpectedTraceFlag) will be set on $($Psitem.InstanceName) "
        }
    }
}

Describe "Trace Flags Not Expected" -Tag TraceFlagsNotExpected, TraceFlag, Medium, Instance -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.TraceFlagsNotExpected' }).Value
    Context "Testing Not Expected Trace Flags on <_.Name>" {
        It "Expected No Trace Flags except for <_.ConfigValues.TraceFlagsExpected> to exist on <_.Name>" -Skip:$skip -ForEach ($Psitem | Where-Object { $null -eq $psitem.ConfigValues.TraceFlagsNotExpected }) {
            $PsItem.NotExpectedTraceFlags.ActualTraceFlags.TraceFlag | Should -BeNullOrEmpty -Because "We expect that there will be no Trace Flags set on $($Psitem.Name) except for $($psitem.ConfigValues.ExpectedTraceFlag)"
        }
        It "Expected <_.NotExpectedTraceFlag> Trace Flag to not exist on <_.InstanceName>" -Skip:$skip -ForEach ($PsItem.NotExpectedTraceFlags | Where-Object { $psitem.NotExpectedTraceFlag -ne 'null' }) {
            $PsItem.ActualTraceFlags.TraceFlag | Should -Not -Contain $PsItem.NotExpectedTraceFlag -Because "We expect that Trace Flag $($PsItem.NotExpectedTraceFlag) will not be set on $($Psitem.InstanceName) except for $($psitem.ConfigValues.ExpectedTraceFlag)"
        }
    }
}

Describe "CLR Enabled" -Tag CLREnabled, security, CIS, High, Instance -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.CLREnabled' }).Value
    Context "Testing CLR Enabled on <_.Name>" {
        It "CLR Enabled is set to <_.ConfigValues.CLREnabled> on <_.Name>" -Skip:$skip {
            $PSItem.Configuration.IsSqlClrEnabled.ConfigValue -eq 1 | Should -Be $psitem.ConfigValues.CLREnabled -Because 'This is the setting you have chosen for CLR Enabled'
        }
    }
}

Describe "sp_whoisactive is Installed" -Tag WhoIsActiveInstalled, Low, Instance -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.WhoIsActiveInstalled' }).Value
    Context "Testing WhoIsActive exists on <_.Name>" {
        It "WhoIsActive should exist on <_.ConfigValues.whoisactivedatabase> on <_.Name>" -Skip:$skip {
            $Psitem.ConfigValues.WhoIsActiveInstalled | Should -Be 1 -Because "The sp_WhoIsActive stored procedure should be installed in $($psitem.ConfigValues.whoisactivedatabase)"
        }
    }
}

Describe "XP CmdShell" -Tag XpCmdShellDisabled, security, CIS, Medium, Instance -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.XpCmdShellDisabled' }).Value
    Context "Testing XP CmdShell on <_.Name>" {
        It "XpCmdShellDisabled is set to <_.ConfigValues.XpCmdShellDisabled> on <_.Name>" -Skip:$skip {
            $PSItem.Configuration.XpCmdShellEnabled.ConfigValue -eq 0 | Should -Be $psitem.ConfigValues.XpCmdShellDisabled -Because 'This is the value that you have chosen for XPXmdShellDisabled configuration'
        }
    }
}

Describe "XE Sessions that should be Stopped" -Tag XESessionStopped, ExtendedEvent, Medium, Instance -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.XESessionStopped' }).Value
    Context "Checking sessions on <_.Name>" {
        It "Session <_.SessionName> should not be running on <_.Name>" -Skip:$skip -ForEach $PsItem.XeSessions.RequiredStopped {
            $psitem.SessionName | Should -Not -BeIn $PsItem.Running -Because "$($psitem.SessionName) session should be stopped on $($PsItem.Name)"
        }
    }
}
Describe "XE Sessions that should Exist" -Tag XESessionExists, ExtendedEvent, Medium, Instance -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.XESessionExists' }).Value
    Context "Checking sessions on <_.Name>" {
        It "Session <_.SessionName> should exist on <_.Name>" -Skip:$skip -ForEach $PsItem.XeSessions.RequiredExists {
            $psitem.SessionName | Should -BeIn $PsItem.Sessions -Because "$($psitem.SessionName) session should exist on $($PsItem.Name)"
        }
    }
}
Describe "XE Sessions that should be running" -Tag XESessionRunning, ExtendedEvent, Medium, Instance -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.XESessionRunning' }).Value
    Context "Checking sessions on <_.Name>" {
        It "Session <_.SessionName> should be running on <_.Name>" -Skip:$skip -ForEach $PsItem.XeSessions.RequiredRunning {
            $psitem.SessionName | Should -BeIn $PsItem.Running -Because "$($psitem.SessionName) session should be running on $($PsItem.Name)"
        }
    }
}
Describe "XE Sessions That Are Allowed to Be Running" -Tag XESessionRunningAllowed, ExtendedEvent, Medium, Instance -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.XESessionRunningAllowed' }).Value
    Context "Checking running sessions allowed on <_.Name>" {
        It "Session <_.SessionName> is allowed to be running on <_.Name>" -Skip:$skip -ForEach $PsItem.XeSessions.RunningAllowed {
            $psitem.SessionName | Should -BeIn $PsItem.Allowed -Because "Only $($PsItem.Allowed) sessions are allowed to be running $($PsItem.Name)"
        }
    }
}

Describe "Error Log Entries" -Tag ErrorLog, Medium, Instance -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.errorlogentries' }).Value
    Context "Checking error log on <_.Name>" {
        It "Error log should be free of error severities 17-24 within the window of <_.ErrorLogEntries.logWindow> days on <_.Name>" -Skip:$Skip {
            $PSItem.ErrorLogEntries.Count | Should -Be 0 -Because "these severities indicate serious problems"
        }
    }
}

Describe "Backup Path Access" -Tag BackupPathAccess, Storage, DISA, Medium, Instance -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.BackupPathAccess' }).Value
    Context "Testing Backup Path Access on <_.Name>" {
        It "can access backup path <_.BackupPathAccess.BackupPath> on <_.Name>" {
            $PsItem.BackupPathAccess.Result | Should -BeTrue -Because 'The SQL Service account needs to have access to the backup path $($PsItem.BackupPathAccess.BackupPath)to backup your databases'
        }
    }
}

<#
Describe "TempDB Configuration" -Tags TempDbConfiguration, Medium, Instance -ForEach $InstancesToTest {
    Context "Testing TempDB Configuration on $psitem" -Skip:(($__dbcconfig | Where-Object { $_.Name
        It "should have TF1118 enabled on <_.Name>" -Skip:((($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.XESessionRunningAllowed' }).Value)  -or ($InstanceSMO.VersionMajor -gt 12)) {
            $psitem.TempDBConfig.TF118EnabledCurrent | Should -Be  $psitem.TempDBConfig.TF118EnabledRecommended -Because 'TF 1118 should be enabled'
        }
        It "should have <_.TempDBConfig.TempDBFilesRecommended> TempDB Files on <_.Name>" -Skip:(($__dbcconfig | Where-Object { $_.Name -eq 'skip.tempdbfileCount' }).Value)  {
            $psitem.TempDBConfig.TempDBFilesCurrent | Should -Be $psitem.TempDBConfig.TempDBFilesRecommended -Because 'This is the recommended number of tempdb files for your server'
        }
        It "should not have TempDB Files autogrowth set to percent on $($TempDBTest[2].SqlInstance)" -Skip:(($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.XESessionRunningAllowed' }).Value)  {
            $TempDBTest[2].CurrentSetting | Should -Be $TempDBTest[2].Recommended -Because 'Auto growth type should not be percent'
        }
        It "should not have TempDB Files on the C Drive on $($TempDBTest[3].SqlInstance)" -Skip:(($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.XESessionRunningAllowed' }).Value) {
            $TempDBTest[3].CurrentSetting | Should -Be $TempDBTest[3].Recommended -Because 'You do not want the tempdb files on the same drive as the operating system'
        }
        It "should not have TempDB Files with MaxSize Set on $($TempDBTest[4].SqlInstance)" -Skip:(($__dbcconfig | Where-Object { $_.Name -eq 'skip.instance.XESessionRunningAllowed' }).Value) {
            $TempDBTest[4].CurrentSetting | Should -Be $TempDBTest[4].Recommended -Because 'Tempdb files should be able to grow'
        }
        It "The data files should all be the same size on $($TempDBTest[0].SqlInstance)" {
            Assert-TempDBSize -Instance $Psitem
        }
    }
}
#>