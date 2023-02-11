function NewGet-AllInstanceInfo {
    # Using the unique tags gather the information required
    Param($Instance, $Tags)

    #clear out the default initialised fields
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Server], $false)
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database], $false)
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Login], $false)
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.Job], $false)
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.StoredProcedure], $false)
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Information], $false)
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Settings], $false)
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.LogFile], $false)
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.DataFile], $false)

    # set the default init fields for all the tags

    # Server Initial fields
    $ServerInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Server])
    $ServerInitFields.Add("VersionMajor") | Out-Null # so we can check versions
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Server], $ServerInitFields)

    # Database Initial Fields
    $DatabaseInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database])

    # Stored Procedure Initial Fields
    $StoredProcedureInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.StoredProcedure])

    # Information Initial Fields

    # Settings Initial Fields
    $SettingsInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Settings])

    # Login Initial Fields
    $LoginInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Login])

    # Log File Initial Fields
    $LogFileInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.LogFile])

    # Data File Initial Fields
    $DataFileInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.DataFile])

    # Configuration cannot have default init fields :-)
    $configurations = $false

    # Set up blank ConfigValues object for any config we need to use in the checks
    $ConfigValues = [PSCustomObject]@{}

    # Using there so that if the instance is not contactable, no point carrying on with gathering more information
    switch ($tags) {

        'DefaultTrace' {
            $configurations = $true
        }
        'OleAutomationProceduresDisabled' {
            $configurations = $true
        }
        'CrossDBOwnershipChaining' {
            $configurations = $true
        }
        'ScanForStartupProceduresDisabled' {
            # we have to check the spconfigure and we have to check that any stored procedurees in master have startup set to true
            $configurations = $true
            $ScanForStartupProceduresDisabled = $true
            $StoredProcedureInitFields.Add("Startup") | Out-Null # So we can check SPs start up for the CIS checks
            $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.StoredProcedure], $StoredProcedureInitFields)
            $StoredProcedureInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.StoredProcedure]) #  I think we need to re-initialise here
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'scanforstartupproceduresdisabled' -Value (($__dbcconfig | Where-Object { $_.Name -eq 'policy.security.scanforstartupproceduresdisabled' }).Value)
        }
        'RemoteAccessDisabled' {
            $configurations = $true
        }
        'SQLMailXPsDisabled' {
            $configurations = $true
        }
        'DAC' {
            $configurations = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'dacallowed' -Value (($__dbcconfig | Where-Object { $_.Name -eq 'policy.dacallowed' }).Value)
        }
        'OLEAutomation' {
            $configurations = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'OLEAutomation' -Value (($__dbcconfig | Where-Object { $_.Name -eq 'policy.oleautomation' }).Value)
        }
        'AdHocWorkload' {
            $configurations = $true
        }
        'AdHocDistributedQueriesEnabled' {
            $configurations = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'AdHocDistributedQueriesEnabled' -Value (($__dbcconfig | Where-Object { $_.Name -eq 'policy.security.AdHocDistributedQueriesEnabled' }).Value)
        }
        'DefaultBackupCompression' {
            $configurations = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'DefaultBackupCompression' -Value (($__dbcconfig | Where-Object { $_.Name -eq 'policy.backup.defaultbackupcompression' }).Value)
        }
        'DefaultFilePath' {
            $SettingsInitFields.Add("DefaultFile") | Out-Null # so we can check file paths
            $SettingsInitFields.Add("DefaultLog") | Out-Null # so we can check file paths
            $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Settings], $SettingsInitFields)
        }
        'SaRenamed' {
        }
        'SaDisabled' {
            $LoginInitFields.Add("IsDisabled") | Out-Null # so we can check if sa is disabled
            $LoginInitFields.Add("ID") | Out-Null # so we can check if sa is disabled even if it has been renamed
            $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Settings], $LoginInitFields)
        }
        'ModelDbGrowth' {
            $LogFileInitFields.Add("Growth") | Out-Null # So we can check the model file growth settings
            $LogFileInitFields.Add("GrowthType") | Out-Null # So we can check the model file growth settings
            $LogFileInitFields.Add("Name") | Out-Null # So we can check the model file growth settings
            $DataFileInitFields.Add("Growth") | Out-Null # So we can check the model file growth settings
            $DataFileInitFields.Add("GrowthType") | Out-Null # So we can check the model file growth settings
            $DataFileInitFields.Add("Name") | Out-Null # So we can check the model file growth settings
            $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.LogFile], $LogFileInitFields)
            $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.DataFile], $DataFileInitFields)
            $LogFileInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.LogFile]) #  I think we need to re-initialise here
            $DataFileInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.DataFile]) #  I think we need to re-initialise here

        }
        'ErrorlogCount' {

            $ServerInitFields.Add("NumberOfLogFiles") | Out-Null # so we can check versions
            $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Server], $ServerInitFields)
            $ServerInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Server]) #  I think we need to re-initialise here

            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'errorLogCount' -Value (($__dbcconfig | Where-Object { $_.Name -eq 'policy.errorlog.logcount' }).Value)

        }
        'MaxDopInstance' {
            #Test-DbaMaxDop needs these because it checks every database as well
            $DatabaseInitFields.Add("IsAccessible") | Out-Null # so we can check if its accessible
            $DatabaseInitFields.Add("IsSystemObject ") | Out-Null # so we can check if its accessible
            $DatabaseInitFields.Add("MaxDop ") | Out-Null # so we can check if its accessible
            $DatabaseInitFields.Add("Name ") | Out-Null # so we can check if its accessible
            $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database], $DatabaseInitFields)
            $DatabaseInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database]) #  I think we need to re-initialise here

            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'UseRecommendedMaxDop' -Value (($__dbcconfig | Where-Object { $_.Name -eq 'policy.instancemaxdop.userecommended' }).Value)
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'InstanceMaxDop' -Value (($__dbcconfig | Where-Object { $_.Name -eq 'policy.instancemaxdop.maxdop' }).Value)
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'ExcludeInstanceMaxDop' -Value (($__dbcconfig | Where-Object { $_.Name -eq 'policy.instancemaxdop.excludeinstance' }).Value)
            if ($Instance.Name -notin $ConfigValues.ExcludeInstanceMaxDop) {
                $MaxDopSettings = (Test-DbaMaxDop -SqlInstance $Instance)[0] # because we dont care about the database maxdops here - potentially we could store it and use it for DatabaseMaxDop ?
            }
        }
        'TwoDigitYearCutoff' {
            $configurations = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'TwoDigitYearCutoff' -Value (($__dbcconfig | Where-Object { $_.Name -eq 'policy.twodigityearcutoff' }).Value)

        }
        'TraceFlagsExpected' {
            $TraceFlagsExpected = ($__dbcconfig | Where-Object { $_.Name -eq 'policy.traceflags.expected' }).Value
            $TraceFlagsActual = $Instance.EnumActiveGlobalTraceFlags()
            if (-not $ConfigValues.TraceFlagsExpected) {
                $ConfigValues | Add-Member -MemberType NoteProperty -Name 'TraceFlagsExpected' -Value $TraceFlagsExpected -Force
            }
            $ExpectedTraceFlags = $TraceFlagsExpected.Foreach{
                [PSCustomObject]@{
                    InstanceName      = $Instance.Name
                    ExpectedTraceFlag = $PSItem
                    ActualTraceFlags  = $TraceFlagsActual
                }
            }
            $ExpectedTraceFlags += [PSCustomObject]@{
                InstanceName      = $Instance.Name
                ExpectedTraceFlag = 'null'
                ActualTraceFlags  = $TraceFlagsActual
            }
        }
        'TraceFlagsNotExpected' {
            $TraceFlagsNotExpected = ($__dbcconfig | Where-Object { $_.Name -eq 'policy.traceflags.notexpected' }).Value
            $TraceFlagsExpected = ($__dbcconfig | Where-Object { $_.Name -eq 'policy.traceflags.expected' }).Value
            if ($null -eq $TraceFlagsExpected) { $TraceFlagsExpected = 'none expected' }
            $TraceFlagsActual = $Instance.EnumActiveGlobalTraceFlags()
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'TraceFlagsNotExpected' -Value $TraceFlagsNotExpected
            if (-not $ConfigValues.TraceFlagsExpected) {
                $ConfigValues | Add-Member -MemberType NoteProperty -Name 'TraceFlagsExpected' -Value $TraceFlagsExpected -Force
            }
            $NotExpectedTraceFlags = $TraceFlagsNotExpected.Where{ $_ -notin $TraceFlagsExpected }.Foreach{
                [PSCustomObject]@{
                    InstanceName         = $Instance.Name
                    NotExpectedTraceFlag = $PSItem
                    TraceFlagsExpected   = $TraceFlagsExpected
                    ActualTraceFlags     = $TraceFlagsActual
                }
            }
            $NotExpectedTraceFlags += [PSCustomObject]@{
                InstanceName         = $Instance.Name
                TraceFlagsExpected   = $TraceFlagsExpected
                NotExpectedTraceFlag = 'null'
                ActualTraceFlags     = $TraceFlagsActual
            }
        }
        'CLREnabled' {
            $configurations = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'CLREnabled' -Value (($__dbcconfig | Where-Object { $_.Name -eq 'policy.security.clrenabled' }).Value)
        }
        'WhoIsActiveInstalled' {
            $configurations = $true
            $WhoIsActiveInstalled = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'whoisactivedatabase' -Value (($__dbcconfig | Where-Object { $_.Name -eq 'policy.whoisactive.database' }).Value)
        }
        'XpCmdShellDisabled' {
            $configurations = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'XpCmdShellDisabled' -Value (($__dbcconfig | Where-Object { $_.Name -eq 'policy.security.XpCmdShellDisabled' }).Value)

        }
        'XESessionStopped' {
            if (-not $xeSessions) {
                $xeSessions = Get-DbaXESession -SqlInstance $Instance
            }
            $RequiredStopped = (($__dbcconfig | Where-Object { $_.Name -eq 'policy.xevent.requiredstoppedsession' }).Value)
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'requiredstoppedsession' -Value $RequiredStopped
            if (-not $xeSessions) {
                $RunningSessions = $xeSessions.Where{ $_.Status -eq 'Running' }.Name
            }
            if (-not $Sessions) {
                $Sessions = $xeSessions.Name
            }
        }
        'XESessionExists' {
            if (-not $xeSessions) {
                $xeSessions = Get-DbaXESession -SqlInstance $Instance
            }
            $RequiredExists = (($__dbcconfig | Where-Object { $_.Name -eq 'policy.xevent.requiredexists' }).Value)
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'requiredexistssessions' -Value $RequiredExists
            if (-not $RunningSessions) {
                $RunningSessions = $xeSessions.Where{ $_.Status -eq 'Running' }.Name
            }
            if (-not $Sessions) {
                $Sessions = $xeSessions.Name
            }
        }
        'XESessionRunning' {
            if (-not $xeSessions) {
                $xeSessions = Get-DbaXESession -SqlInstance $Instance
            }
            $RequiredRunning = (($__dbcconfig | Where-Object { $_.Name -eq 'policy.xevent.requiredrunningsession' }).Value)
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'requiredrunningsession' -Value $RequiredRunning
            if (-not $RunningSessions) {
                $RunningSessions = $xeSessions.Where{ $_.Status -eq 'Running' }.Name
            }
            if (-not $Sessions) {
                $Sessions = $xeSessions.Name
            }
        }
        'XESessionRunningAllowed' {
            if (-not $xeSessions) {
                $xeSessions = Get-DbaXESession -SqlInstance $Instance
            }
            $RunningAllowed = (($__dbcconfig | Where-Object { $_.Name -eq 'policy.xevent.validrunningsession' }).Value)
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'validrunningsession' -Value $RunningAllowed
            if (-not $RunningSessions) {
                $RunningSessions = $xeSessions.Where{ $_.Status -eq 'Running' }.Name
            }
            if (-not $Sessions) {
                $Sessions = $xeSessions.Name
            }
        }
        'ErrorLog' {
            $logWindow = ($__dbcconfig | Where-Object { $_.Name -eq 'policy.errorlog.warningwindow' }).Value
            # so that it can be mocked
            function Get-ErrorLogEntry {
                # get the number of the first error log that was created after the log window config
                $OldestErrorLogNumber = ($InstanceSMO.EnumErrorLogs() | Where-Object { $psitem.CreateDate -gt (Get-Date).AddDays( - $LogWindow) } | Sort-Object ArchiveNo -Descending | Select-Object -First 1).ArchiveNo + 1
                # Get the Error Log entries for each one
                    (0..$OldestErrorLogNumber).ForEach{
                    $InstanceSMO.ReadErrorLog($psitem).Where{ $_.Text -match "Severity: 1[7-9]|Severity: 2[0-4]" }
                }
            }
            # It is not enough to check the CreateDate on the log, you must check the LogDate on every error record as well.
            $ErrorLogCount = (Get-ErrorLogEntry | Where-Object { $psitem.LogDate -gt (Get-Date).AddDays( - $LogWindow) }).Count
        }
        'TempDbConfiguration' {
            $TempDBTest = Test-DbaTempDbConfig -SqlInstance $Instance
        }
        'InstanceConnection' {
            #local is always NTLM except when its a container ;-)
            if ($Instance.NetBiosName -eq $ENV:COMPUTERNAME -and ($instance.Name -notlike '*,*')) {
                if (-not(($__dbcconfig | Where-Object { $_.Name -eq 'skip.connection.auth' }).Value)) {
                    $authscheme = $instance.Query("Select auth_scheme as AuthScheme FROM sys.dm_exec_connections WHERE session_id = @@SPID").AuthScheme
                } else {
                    $authscheme = 'skipped'
                }
            } else {
                $authscheme = 'skipped-local'
            }

            if (-not(($__dbcconfig | Where-Object { $_.Name -eq 'skip.connection.ping' }).Value)) {
                $pingu = New-Object System.Net.NetworkInformation.Ping
                $timeout = 1000 #milliseconds
                $ping = ($pingu.Send($instance.ComputerName, $timeout)).Status
            } else {
                $ping = 'skipped'
            }


            if (-not(($__dbcconfig | Where-Object { $_.Name -eq 'skip.connection.remote' }).Value)) {
                #simple remoting check
                try {
                    $null = Invoke-Command -ComputerName $instance.ComputerName -ScriptBlock { Get-ChildItem } -ErrorAction Stop
                    $remote = $true
                } catch {
                    $remote = $false
                }
            } else {
                $remote = 'skipped'
            }

            $InstanceConnection = @{
                Connect    = $true # because we wouldnt get here otherwise
                AuthScheme = $authscheme
                Ping       = $ping
                Remote     = $remote
            }
        }

        Default { }
    }

    #build the object

    $testInstanceObject = [PSCustomObject]@{
        ComputerName          = $Instance.ComputerName
        InstanceName          = $Instance.DbaInstanceName
        Name                  = $Instance.Name
        ConfigValues          = $ConfigValues
        VersionMajor          = $Instance.VersionMajor
        Configuration         = if ($configurations) { $Instance.Configuration } else { $null }
        Settings              = $Instance.Settings
        Logins                = $Instance.Logins
        Databases             = $Instance.Databases
        NumberOfLogFiles      = $Instance.NumberOfLogFiles
        MaxDopSettings        = $MaxDopSettings
        ExpectedTraceFlags    = $ExpectedTraceFlags
        NotExpectedTraceFlags = $NotExpectedTraceFlags
        XESessions            = [pscustomobject]@{
            RequiredStopped = $RequiredStopped.ForEach{
                [pscustomobject]@{
                    Name        = $Instance.Name
                    SessionName = $PSItem
                    Running     = $RunningSessions
                }
            }
            RequiredExists  = $RequiredExists.ForEach{
                [pscustomobject]@{
                    Name        = $Instance.Name
                    SessionName = $PSItem
                    Sessions    = $Sessions
                }
            }
            RequiredRunning = $RequiredRunning.ForEach{
                [pscustomobject]@{
                    Name        = $Instance.Name
                    SessionName = $PSItem
                    Sessions    = $Sessions
                    Running     = $RunningSessions
                }
            }
            RunningAllowed  = $RunningSessions.ForEach{
                [pscustomobject]@{
                    Name        = $Instance.Name
                    SessionName = $PSItem
                    Sessions    = $Sessions
                    Allowed     = $RunningAllowed
                }
            }
            Name            = $Instance.Name
            Sessions        = $Sessions
            Running         = $RunningSessions
        }
        ErrorLogEntries       = [pscustomobject]@{
            errorLogCount = $ErrorLogCount
            logWindow     = $logWindow
        }
        InstanceConnection    = $InstanceConnection
        # TempDbConfig          = [PSCustomObject]@{
        #     TF118EnabledCurrent     = $tempDBTest[0].CurrentSetting
        #     TF118EnabledRecommended = $tempDBTest[0].Recommended
        #     TempDBFilesCurrent      = $tempDBTest[1].CurrentSetting
        #      TempDBFilesRecommended  = $tempDBTest[1].Recommended
        # }
    }
    if ($ScanForStartupProceduresDisabled) {
        $StartUpSPs = $Instance.Databases['master'].StoredProcedures.Where{ $_. Name -ne 'sp_MSrepl_startup' -and $_.StartUp -eq $true }.count
        if ($StartUpSPs -eq 0) {
            $testInstanceObject.Configuration.ScanForStartupProcedures.ConfigValue = 0
        }
    }
    if ($WhoIsActiveInstalled) {
        $whoisdatabase = ($__dbcconfig | Where-Object { $_.Name -eq 'policy.whoisactive.database' }).Value
        $WhoIsActiveInstalled = $Instance.Databases[$whoisdatabase].StoredProcedures.Where{ $_.Name -eq 'sp_WhoIsActive' }.count
        $testInstanceObject.ConfigValues | Add-Member -MemberType NoteProperty -Name 'WhoIsActiveInstalled' -Value $whoIsActiveInstalled
    }
    return $testInstanceObject
}