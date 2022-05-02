function Get-AllAgentInfo {
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

        'DatabaseMailEnabled' {
            $configurations = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'databasemailenabled' -Value (Get-DbcConfigValue policy.security.databasemailenabled)
        }
        'AgentServiceAccount' {
            if (($Instance.VersionMajor -ge 14) -or $IsLinux -or $Instance.HostPlatform -eq 'Linux') {
                $Agent = @($Instance.Query("SELECT * FROM sys.dm_server_services") | Where-Object servicename -like '*Agent*').Foreach{
                    [PSCustomObject]@{
                        State = $PSItem.status_desc
                        StartMode = $PSItem.startup_type_desc
                    }
                }
            } else { # Windows
                $Agent = @(Get-DbaService -ComputerName $Instance.ComputerName -Type Agent)
            }
        }
        'DbaOperator' {

        }
        'FailsafeOperator' {

        }
        'DatabaseMailProfile' {

        }
        'AgentMailProfile' {

        }
        'FailedJob' {

        }
        'ValidJobOwner' {

        }
        'InValidJobOwner' {

        }
        'AgentAlert' {

        }
        'JobHistory' {

        }
        'LongRunningJob' {

        }
        'LastJobRunTime' {

        }
        Default { }
    }

    #build the object
    $testInstanceObject = [PSCustomObject]@{
        ComputerName        = $Instance.ComputerName
        InstanceName        = $Instance.DbaInstanceName
        Name                = $Instance.Name
        ConfigValues        = @($ConfigValues)
        HostPlatform        = $Instance.HostPlatform
        IsClustered         = $Instance.IsClustered
        DatabaseMailEnabled = $Instance.Configuration.DatabaseMailEnabled.ConfigValue
        Agent               = @($Agent)
    }
    return $testInstanceObject
}