function Get-AllAgentInfo {
    # Using the unique tags gather the information required
    Param($Instance, $Tags)

    #ToDo: Clean unused SMO classes
    #clear out the default initialised fields
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Server], $false)
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database], $false)
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Login], $false)
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.Job], $false)
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.Operator], $false)
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.AlertSystem], $false)
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

    # Job Server Initial fields
    $OperatorInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.Operator])

    # Job Server Alert System Initial fields
    $FailsafeInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.AlertSystem])

    # JobServer Initial fields
    $AgentMailProfileInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.JobServer])


    $DatabaseMailProfileInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Mail.MailProfile])

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
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'DatabaseMailEnabled' -Value (Get-DbcConfigValue policy.security.databasemailenabled)
        }
        'AgentServiceAccount' {
            if (($Instance.VersionMajor -ge 14) -or $IsLinux -or $Instance.HostPlatform -eq 'Linux') {
                $Agent = @($Instance.Query("SELECT status_desc, startup_type_desc FROM sys.dm_server_services") | Where-Object servicename -Like '*Agent*').ForEach{
                    [PSCustomObject]@{
                        State     = $PSItem.status_desc
                        StartMode = $PSItem.startup_type_desc
                    }
                }
            } else {
                # Windows
                $Agent = @(Get-DbaService -ComputerName $Instance.ComputerName -Type Agent)
            }
        }
        'DbaOperator' {
            $OperatorInitFields.Add("Name") | Out-Null # so we can check operators
            $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.Operator], $OperatorInitFields)
            $OperatorInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.Operator])

            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'DbaOperatorName' -Value (Get-DbcConfigValue agent.dbaoperatorname)
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'DbaOperatorEmail' -Value (Get-DbcConfigValue agent.dbaoperatoremail)

            $Operator = $ConfigValues.DbaOperatorName.ForEach{
                [PSCustomObject]@{
                    InstanceName          = $Instance.Name
                    ExpectedOperatorName  = $PSItem
                    ActualOperatorName    = $Instance.JobServer.Operators.Name
                    ExpectedOperatorEmail = 'null'
                    ActualOperatorEmail   = 'null'
                }
            }

            $Operator += $ConfigValues.DbaOperatorEmail.ForEach{
                [PSCustomObject]@{
                    InstanceName          = $Instance.Name
                    ExpectedOperatorName  = 'null'
                    ActualOperatorName    = 'null'
                    ExpectedOperatorEmail = $PSItem
                    ActualOperatorEmail   = $Instance.JobServer.Operators.EmailAddress
                }
            }
        }
        'FailsafeOperator' {
            $FailsafeInitFields.Add("FailSafeOperator") | Out-Null # so we can check failsafe operators
            $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.AlertSystem], $FailsafeInitFields)
            $FailsafeInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.AlertSystem])

            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'FailsafeOperator' -Value (Get-DbcConfigValue agent.failsafeoperator)

            $failsafeOperator = $ConfigValues.FailsafeOperator.ForEach{
                [PSCustomObject]@{
                    InstanceName             = $Instance.Name
                    ExpectedFailSafeOperator = $PSItem
                    ActualFailSafeOperator   = $Instance.JobServer.AlertSystem.FailSafeOperator
                }
            }
        }
        'DatabaseMailProfile' {
            $DatabaseMailProfileInitFields.Add("Name") | Out-Null # so we can check failsafe operators
            $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Mail.MailProfile], $DatabaseMailProfileInitFields)
            $DatabaseMailProfileInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Mail.MailProfile])

            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'DatabaseMailProfile' -Value (Get-DbcConfigValue agent.databasemailprofile)

            $databaseMailProfile = $ConfigValues.DatabaseMailProfile.ForEach{
                [PSCustomObject]@{
                    InstanceName                = $Instance.Name
                    ExpectedDatabaseMailProfile = $ConfigValues.DatabaseMailProfile
                    ActualDatabaseMailProfile   = $Instance.Mail.Profiles.Name
                }
            }

            ##TODO: Clean up
            #$databaseMailProfile += [PSCustomObject]@{
            #    InstanceName                = $Instance.Name
            #    ExpectedDatabaseMailProfile = 'null'
            #    ActualDatabaseMailProfile   = 'null'
            #}
#
            #Write-PSFMessage -Message "InstanceName : $($databaseMailProfile.InstanceName)" -Level Verbose
            #Write-PSFMessage -Message "ExpectedDatabaseMailProfile : $($databaseMailProfile.ExpectedDatabaseMailProfile)" -Level Verbose
            #Write-PSFMessage -Message "ActualDatabaseMailProfile : $($databaseMailProfile.ActualDatabaseMailProfile)" -Level Verbose
            #Write-PSFMessage -Message "ActualDatabaseMailProfile instance : $($Instance.Mail.Profiles.Name)" -Level Verbose

        }
        'AgentMailProfile' {
            $AgentMailProfileInitFields.Add("DatabaseMailProfile") | Out-Null # so we can check failsafe operators
            $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.JobServer], $AgentMailProfileInitFields)
            $AgentMailProfileInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.JobServer])

            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'AgentMailProfile' -Value (Get-DbcConfigValue agent.databasemailprofile)

            $agentMailProfile = $ConfigValues.AgentMailProfile.ForEach{
                [PSCustomObject]@{
                    InstanceName             = $Instance.Name
                    ExpectedAgentMailProfile = $ConfigValues.AgentMailProfile
                    ActualAgentMailProfile   = $Instance.JobServer.DatabaseMailProfile
                }
            }

            #TODO: Clean up
            #$databaseMailProfile = $ConfigValues.DatabaseMailProfile.ForEach{
            #    [PSCustomObject]@{
            #        InstanceName                = $Instance.Name
            #        ExpectedDatabaseMailProfile = 'null'
            #        ActualDatabaseMailProfile   = 'null'
            #    }
            #}
#
            #Write-PSFMessage -Message "InstanceName : $($databaseMailProfile.InstanceName)" -Level Verbose
            #Write-PSFMessage -Message "ExpectedDatabaseMailProfile : $($databaseMailProfile.ExpectedDatabaseMailProfile)" -Level Verbose
            #Write-PSFMessage -Message "ActualDatabaseMailProfile : $($databaseMailProfile.ActualDatabaseMailProfile)" -Level Verbose
            #Write-PSFMessage -Message "ActualDatabaseMailProfile instance : $($Instance.JobServer.DatabaseMailProfile)" -Level Verbose
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
        Operator            = @($Operator)
        FailSafeOperator    = @($failsafeOperator)
        DatabaseMailProfile = @($databaseMailProfile)
        AgentMailProfile    = @($agentMailProfile)
    }
    return $testInstanceObject
}