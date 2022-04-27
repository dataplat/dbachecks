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

    
    # Server Initial fields
    $ServerInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Server])
    $ServerInitFields.Add("VersionMajor") | Out-Null # so we can check versions
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Server], $ServerInitFields)

    # Stored Procedure Initial Fields
    $StoredProcedureInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.StoredProcedure])
    $StoredProcedureInitFields.Add("Startup") | Out-Null # So we can check SPs start up for the CIS checks

    # Information Initial Fields

    # Settings Initial Fields
    $SettingsInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Settings])

    # Login Initial Fields
    $LoginInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Login])

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
            $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.StoredProcedure], $StoredProcedureInitFields)
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
       
        Default { }
    }

    # set the default init fields for all the tags
    
    #build the object

    $testInstanceObject = [PSCustomObject]@{
        ComputerName  = $Instance.ComputerName
        InstanceName  = $Instance.DbaInstanceName
        Name          = $Instance.Name
        ConfigValues  = $ConfigValues
        VersionMajor  = $Instance.VersionMajor
        Configuration = if ($configurations) { $Instance.Configuration } else { $null }
        Settings      = $Instance.Settings
        Logins        = $Instance.Logins
    }
    if ($ScanForStartupProceduresDisabled) {
        $StartUpSPs = $Instance.Databases['master'].StoredProcedures.Where{ $_. Name -ne 'sp_MSrepl_startup' -and $_.StartUp -eq $true }.count
        if ($StartUpSPs -eq 0) {
            $testInstanceObject.Configuration.ScanForStartupProcedures.ConfigValue = 0
        } 
    }
    return $testInstanceObject
}