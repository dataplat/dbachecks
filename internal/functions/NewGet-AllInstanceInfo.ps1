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
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'scanforstartupproceduresdisabled' -Value (Get-DbcConfigValue policy.security.scanforstartupproceduresdisabled)
        }
        'RemoteAccessDisabled' {
            $configurations = $true
        }
        'SQLMailXPsDisabled' {
            $configurations = $true
        }
        'DAC' {
            $configurations = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'dacallowed' -Value (Get-DbcConfigValue policy.dacallowed)
        }
        'OLEAutomation' {
            $configurations = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'OLEAutomation' -Value (Get-DbcConfigValue policy.oleautomation)
        }
        'AdHocWorkload' {
            $configurations = $true
        }
        'AdHocDistributedQueriesEnabled' {
            $configurations = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'AdHocDistributedQueriesEnabled' -Value (Get-DbcConfigValue policy.security.AdHocDistributedQueriesEnabled)
        }
        'DefaultBackupCompression' {
            $configurations = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'DefaultBackupCompression' -Value (Get-DbcConfigValue policy.backup.defaultbackupcompression)
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
        
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'errorLogCount' -Value (Get-DbcConfigValue policy.errorlog.logcount)

        }
        'MaxDopInstance' {
            #Test-DbaMaxDop needs these because it checks every database as well
            $DatabaseInitFields.Add("IsAccessible") | Out-Null # so we can check if its accessible
            $DatabaseInitFields.Add("IsSystemObject ") | Out-Null # so we can check if its accessible
            $DatabaseInitFields.Add("MaxDop ") | Out-Null # so we can check if its accessible
            $DatabaseInitFields.Add("Name ") | Out-Null # so we can check if its accessible
            $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database], $DatabaseInitFields)
            $DatabaseInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database]) #  I think we need to re-initialise here
            
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'UseRecommendedMaxDop' -Value (Get-DbcConfigValue policy.instancemaxdop.userecommended)
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'InstanceMaxDop' -Value (Get-DbcConfigValue policy.instancemaxdop.maxdop)
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'ExcludeInstanceMaxDop' -Value (Get-DbcConfigValue policy.instancemaxdop.excludeinstance)
            if ($Instance.Name -notin $ConfigValues.ExcludeInstanceMaxDop) {
                $MaxDopSettings = (Test-DbaMaxDop -SqlInstance $Instance)[0] # because we dont care about the database maxdops here - potentially we could store it and use it for DatabaseMaxDop ?
            }
        }
        'TwoDigitYearCutoff' {
            $configurations = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'TwoDigitYearCutoff' -Value (Get-DbcConfigValue policy.twodigityearcutoff)

        }
        'TraceFlagsExpected' {
            $TraceFlagsExpected = Get-DbcConfigValue policy.traceflags.expected
            $TraceFlagsActual = $Instance.EnumActiveGlobalTraceFlags()
            if (-not $ConfigValues.TraceFlagsExpected) {
                $ConfigValues | Add-Member -MemberType NoteProperty -Name 'TraceFlagsExpected' -Value $TraceFlagsExpected
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
            $TraceFlagsNotExpected = Get-DbcConfigValue policy.traceflags.notexpected
            $TraceFlagsExpected = Get-DbcConfigValue policy.traceflags.expected
            if ($null -eq $TraceFlagsExpected) { $TraceFlagsExpected = 'none expected' }
            $TraceFlagsActual = $Instance.EnumActiveGlobalTraceFlags()
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'TraceFlagsNotExpected' -Value $TraceFlagsNotExpected
            if (-not $ConfigValues.TraceFlagsExpected) {
                $ConfigValues | Add-Member -MemberType NoteProperty -Name 'TraceFlagsExpected' -Value $TraceFlagsExpected
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
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'CLREnabled' -Value (Get-DbcConfigValue policy.security.clrenabled)
        }
        'WhoIsActiveInstalled' {
            $configurations = $true
            $WhoIsActiveInstalled = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'whoisactivedatabase' -Value (Get-DbcConfigValue policy.whoisactive.database)
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
    }
    if ($ScanForStartupProceduresDisabled) {
        $StartUpSPs = $Instance.Databases['master'].StoredProcedures.Where{ $_. Name -ne 'sp_MSrepl_startup' -and $_.StartUp -eq $true }.count
        if ($StartUpSPs -eq 0) {
            $testInstanceObject.Configuration.ScanForStartupProcedures.ConfigValue = 0
        } 
    }
    if ($WhoIsActiveInstalled) {
        $whoisdatabase = Get-DbcConfigValue policy.whoisactive.database
        $WhoIsActiveInstalled = $Instance.Databases[$whoisdatabase].StoredProcedures.Where{ $_.Name -eq 'sp_WhoIsActive' }.count
        $testInstanceObject.ConfigValues | Add-Member -MemberType NoteProperty -Name 'WhoIsActiveInstalled' -Value $whoIsActiveInstalled
    }
    return $testInstanceObject
}