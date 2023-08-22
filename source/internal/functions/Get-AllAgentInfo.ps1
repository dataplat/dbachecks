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

    # Database Mail Profile Initial fields
    $DatabaseMailProfileInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Mail.MailProfile])

    # JobOwner Initial fields
    $JobOwnerInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.Job])

    # Invalid JobOwner Initial fields
    $InvalidJobOwnerInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.Job])

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
            $JobOwnerInitFields.Add("OwnerLoginName") | Out-Null # so we can check Job Owner
            $JobOwnerInitFields.Add("Name") | Out-Null # so we can check Job Name
            $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.Job], $JobOwnerInitFields)
            $JobOwnerInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.Job])

            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'TargetJobOwner' -Value (Get-DbcConfigValue agent.validjobowner.name)

            $JobOwner = $Instance.JobServer.Jobs.ForEach{
                [PSCustomObject]@{
                    InstanceName          = $Instance.Name
                    JobName               = $PSItem.Name
                    ExpectedJobOwnerName  = $ConfigValues.TargetJobOwner #$PSItem
                    ActualJobOwnerName    = $PSItem.OwnerLoginName
                }
            }
        }
        'InvalidJobOwner' {
            $InvalidJobOwnerInitFields.Add("OwnerLoginName") | Out-Null # so we can check Job Owner
            $InvalidJobOwnerInitFields.Add("Name") | Out-Null # so we can check Job Name
            $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.Job], $InvalidJobOwnerInitFields)
            $InvalidJobOwnerInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.Job])

            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'InvalidJobOwner' -Value (Get-DbcConfigValue agent.invalidjobowner.name)

            $InvalidJobOwner = $Instance.JobServer.Jobs.ForEach{
                [PSCustomObject]@{
                    InstanceName          = $Instance.Name
                    JobName               = $PSItem.Name
                    ExpectedJobOwnerName  = $ConfigValues.InvalidJobOwner
                    ActualJobOwnerName    = $PSItem.OwnerLoginName
                }
            }

        }
        'AgentAlert' {

        }
        'JobHistory' {

        }
        'LongRunningJob' {
            $query = "SELECT
                JobName,
                AvgSec,
                start_execution_date as StartDate,
                RunningSeconds,
                RunningSeconds - AvgSec AS Diff
                FROM
                (
                SELECT
                j.name AS JobName,
                start_execution_date,
                AVG(DATEDIFF(SECOND, 0, STUFF(STUFF(RIGHT('000000'
                + CONVERT(VARCHAR(6),jh.run_duration),6),5,0,':'),3,0,':'))) AS AvgSec,
                ja.start_execution_date as startdate,
                DATEDIFF(second, ja.start_execution_date, GetDate()) AS RunningSeconds
                FROM msdb.dbo.sysjobactivity ja
                JOIN msdb.dbo.sysjobs j
                ON ja.job_id = j.job_id
                JOIN msdb.dbo.sysjobhistory jh
                ON jh.job_id = j.job_id
                WHERE start_execution_date is not null
                AND stop_execution_date is null
                AND run_duration < 235959
                AND run_duration >= 0
                AND ja.start_execution_date > DATEADD(day,-1,GETDATE())
                GROUP BY j.name,j.job_id,start_execution_date,stop_execution_date,ja.job_id
                ) AS t
                ORDER BY JobName;"
            $runningjobs = Invoke-DbaQuery -SqlInstance $Instance -Database msdb -Query $query

            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'LongRunningJob' -Value (Get-DbcConfigValue agent.longrunningjob.percentage)

            $LongRunningJobs = $($runningjobs | Where-Object { $_.AvgSec -ne 0 }).ForEach{
                [PSCustomObject]@{
                    InstanceName                        = $Instance.Name
                    JobName                             = $PSItem.JobName
                    RunningSeconds                      = $PSItem.RunningSeconds
                    Average                             = $PSItem.AvgSec
                    Diff                                = $PSItem.Diff
                    ExpectedLongRunningJobPercentage    = $ConfigValues.LongRunningJob
                    ActualLongRunningJobPercentage      = [math]::Round($PSItem.Diff / $PSItem.AvgSec * 100)
                }
            }
        }
        'LastJobRunTime' {
            $maxdays = Get-DbcConfigValue agent.failedjob.since
            $query = "IF OBJECT_ID('tempdb..#dbachecksLastRunTime') IS NOT NULL DROP Table #dbachecksLastRunTime
                SELECT * INTO #dbachecksLastRunTime
                FROM
                (
                SELECT
                j.job_id,
                j.name AS JobName,
                DATEDIFF(SECOND, 0, STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(6),jh.run_duration),6),5,0,':'),3,0,':')) AS Duration
                FROM msdb.dbo.sysjobs j
                INNER JOIN
                    (
                        SELECT job_id, instance_id = MAX(instance_id)
                            FROM msdb.dbo.sysjobhistory
                            GROUP BY job_id
                    ) AS h
                    ON j.job_id = h.job_id
                INNER JOIN
                    msdb.dbo.sysjobhistory AS jh
                    ON jh.job_id = h.job_id
                    AND jh.instance_id = h.instance_id
                    WHERE msdb.dbo.agent_datetime(jh.run_date, jh.run_time) > DATEADD(DAY,- $maxdays,GETDATE())
                    AND jh.step_id = 0
                ) AS lrt
                            IF OBJECT_ID('tempdb..#dbachecksAverageRunTime') IS NOT NULL DROP Table #dbachecksAverageRunTime
                SELECT * INTO #dbachecksAverageRunTime
                FROM
                (
                SELECT
                job_id,
                AVG(DATEDIFF(SECOND, 0, STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(6),run_duration),6),5,0,':'),3,0,':'))) AS AvgSec
                FROM msdb.dbo.sysjobhistory hist
                WHERE msdb.dbo.agent_datetime(run_date, run_time) > DATEADD(DAY,- $maxdays,GETDATE())
                AND Step_id = 0
                AND run_duration >= 0
                GROUP BY job_id
                ) as art
                            SELECT
                JobName,
                Duration,
                AvgSec,
                Duration - AvgSec AS Diff
                FROM #dbachecksLastRunTime lastrun
                JOIN #dbachecksAverageRunTime avgrun
                ON lastrun.job_id = avgrun.job_id
                            DROP Table #dbachecksLastRunTime
                DROP Table #dbachecksAverageRunTime"
            $lastagentjobruns = Invoke-DbaQuery -SqlInstance $Instance -Database msdb -Query $query

            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'LastJobRuns' -Value (Get-DbcConfigValue agent.lastjobruntime.percentage)

            $LastJobRuns = $($lastagentjobruns | Where-Object { $_.AvgSec -ne 0 }).ForEach{
                [PSCustomObject]@{
                    InstanceName                    = $Instance.Name
                    JobName                         = $PSItem.JobName
                    Duration                        = $PSItem.Duration
                    Average                         = $PSItem.AvgSec
                    ExpectedRunningJobPercentage    = $ConfigValues.LastJobRuns
                    ActualRunningJobPercentage      = [math]::Round($PSItem.Diff / $PSItem.AvgSec * 100)
                }
            }
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
        JobOwner            = $JobOwner
        InvalidJobOwner     = $InvalidJobOwner
        LastJobRuns         = $LastJobRuns
        LongRunningJobs     = $LongRunningJobs
    }
    return $testInstanceObject
}