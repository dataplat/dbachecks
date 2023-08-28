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

    # Failed Job Initial fields
    $FailedJobInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.Job])

    # Agent Alerts Initial fields
    $AgentAlertsInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.Alert])

    # Agent Job History Initial fields
    $AgentJobHistory = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.JobServer])

    # Set up blank ConfigValues object for any config we need to use in the checks
    $ConfigValues = [PSCustomObject]@{}

    # Using there so that if the instance is not contactable, no point carrying on with gathering more information
    switch ($tags) {

        'DatabaseMailEnabled' {
            $configurations = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'DatabaseMailEnabled' -Value (($__dbcconfig | Where-Object { $_.Name -eq 'policy.security.databasemailenabled' }).Value)
        }
        'AgentServiceAccount' {
            if (($Instance.VersionMajor -ge 14) -or $IsLinux -or $Instance.HostPlatform -eq 'Linux') {
                $Agent = @($Instance.Query("SELECT status_desc, startup_type_desc, servicename FROM sys.dm_server_services") | Where-Object servicename -Like '*Agent*').ForEach{
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

            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'DbaOperatorName' -Value (($__dbcconfig | Where-Object { $_.Name -eq 'agent.dbaoperatorname' }).Value)
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'DbaOperatorEmail' -Value (($__dbcconfig | Where-Object { $_.Name -eq 'agent.dbaoperatoremail' }).Value)

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

            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'FailsafeOperator' -Value (($__dbcconfig | Where-Object { $_.Name -eq 'agent.failsafeoperator' }).Value)

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

            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'DatabaseMailProfile' -Value (($__dbcconfig | Where-Object { $_.Name -eq 'agent.databasemailprofile' }).Value)

            $databaseMailProfile = $ConfigValues.DatabaseMailProfile.ForEach{
                [PSCustomObject]@{
                    InstanceName                = $Instance.Name
                    ExpectedDatabaseMailProfile = $ConfigValues.DatabaseMailProfile
                    ActualDatabaseMailProfile   = $Instance.Mail.Profiles.Name
                }
            }
        }
        'AgentMailProfile' {
            $AgentMailProfileInitFields.Add("DatabaseMailProfile") | Out-Null # so we can check failsafe operators
            $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.JobServer], $AgentMailProfileInitFields)
            $AgentMailProfileInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.JobServer])

            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'AgentMailProfile' -Value (($__dbcconfig | Where-Object { $_.Name -eq 'agent.databasemailprofile' }).Value)

            $agentMailProfile = $ConfigValues.AgentMailProfile.ForEach{

                [PSCustomObject]@{
                    InstanceName             = $Instance.Name
                    ExpectedAgentMailProfile = $ConfigValues.AgentMailProfile
                    ActualAgentMailProfile   = $Instance.JobServer.DatabaseMailProfile
                }
            }
        }
        'FailedJob' {
            $FailedJobInitFields.Add("Name") | Out-Null # so we can check Job Name
            $FailedJobInitFields.Add("IsEnabled") | Out-Null # so we can check Job status
            $FailedJobInitFields.Add("LastRunDate") | Out-Null # so we can check Job LastRunDate
            $FailedJobInitFields.Add("LastRunOutcome") | Out-Null # so we can check Job LastRunOutcome

            $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.Job], $FailedJobInitFields)
            $FailedJobInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.Job])

            $maxdays = ($__dbcconfig | Where-Object { $_.Name -eq 'agent.failedjob.since' }).Value
            $startdate = (Get-Date).AddDays( - $maxdays)

            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'FailedJob' -Value 'Succeeded'

            $JobsFailed = ($Instance.JobServer.Jobs | Where-Object { $_.IsEnabled -and ($_.LastRunDate -gt $startdate) }).ForEach{
                [PSCustomObject]@{
                    InstanceName    = $Instance.Name
                    JobName         = $PSItem.Name
                    ExpectedOutcome = $ConfigValues.FailedJob
                    LastRunOutcome  = $PSItem.LastRunOutcome
                }
            }
        }
        'ValidJobOwner' {
            $JobOwnerInitFields.Add("OwnerLoginName") | Out-Null # so we can check Job Owner
            $JobOwnerInitFields.Add("Name") | Out-Null # so we can check Job Name
            $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.Job], $JobOwnerInitFields)
            $JobOwnerInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.Job])

            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'TargetJobOwner' -Value (($__dbcconfig | Where-Object { $_.Name -eq 'agent.validjobowner.name' }).Value)

            $JobOwner = $Instance.JobServer.Jobs.ForEach{
                [PSCustomObject]@{
                    InstanceName         = $Instance.Name
                    JobName              = $PSItem.Name
                    ExpectedJobOwnerName = $ConfigValues.TargetJobOwner #$PSItem
                    ActualJobOwnerName   = $PSItem.OwnerLoginName
                }
            }
        }
        'InvalidJobOwner' {
            $InvalidJobOwnerInitFields.Add("OwnerLoginName") | Out-Null # so we can check Job Owner
            $InvalidJobOwnerInitFields.Add("Name") | Out-Null # so we can check Job Name
            $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.Job], $InvalidJobOwnerInitFields)
            $InvalidJobOwnerInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.Job])

            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'InvalidJobOwner' -Value (($__dbcconfig | Where-Object { $_.Name -eq 'agent.invalidjobowner.name' }).Value)

            $InvalidJobOwner = $Instance.JobServer.Jobs.ForEach{
                [PSCustomObject]@{
                    InstanceName         = $Instance.Name
                    JobName              = $PSItem.Name
                    ExpectedJobOwnerName = $ConfigValues.InvalidJobOwner
                    ActualJobOwnerName   = $PSItem.OwnerLoginName
                }
            }

        }
        'AgentAlert' {
            $AgentAlertsInitFields.Add("Severity") | Out-Null # so we can check Alert Severity
            $AgentAlertsInitFields.Add("IsEnabled") | Out-Null # so we can check Alert status
            $AgentAlertsInitFields.Add("JobName") | Out-Null # so we can check Alert job
            $AgentAlertsInitFields.Add("HasNotification") | Out-Null # so we can check Alert notification

            $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.Alert], $AgentAlertsInitFields)
            $AgentAlertsInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.Alert])

            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'AgentAlertSeverity' -Value (($__dbcconfig | Where-Object { $_.Name -eq 'agent.alert.Severity' }).Value)
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'AgentAlertMessageId' -Value (($__dbcconfig | Where-Object { $_.Name -eq 'agent.alert.messageid' }).Value)

            $Severities = $ConfigValues.AgentAlertSeverity.ForEach{
                $Severity = [int]($PSItem)
                $sev = $Instance.JobServer.Alerts.Where{ $_.Severity -eq $Severity }
                [PSCustomObject]@{
                    InstanceName       = $Instance.Name
                    AlertName          = $sev.Name
                    Severity           = $sev.Severity
                    IsEnabled          = $sev.IsEnabled
                    JobName            = $sev.JobName
                    HasNotification    = $sev.HasNotification
                    AgentAlertSeverity = $Severity
                }
            }

            $MessageIDs = $ConfigValues.AgentAlertMessageId.ForEach{
                $MessageID = [int]($PSItem)
                $msgID = $Instance.JobServer.Alerts.Where{ $_.MessageID -eq $MessageID }
                [PSCustomObject]@{
                    InstanceName    = $Instance.Name
                    AlertName       = $msgID.Name
                    MessageID       = $msgID.MessageID
                    IsEnabled       = $msgID.IsEnabled
                    JobName         = $msgID.JobName
                    HasNotification = $msgID.HasNotification
                    AgentMessageID  = $MessageID
                }
            }

            $AgentAlerts = [PSCustomObject]@{
                Severities = $Severities
                MessageIDs = $MessageIDs
            }
        }
        'JobHistory' {
            $AgentJobHistory.Add("MaximumHistoryRows") | Out-Null # so we can check Alert Severity
            $AgentJobHistory.Add("MaximumJobHistoryRows") | Out-Null # so we can check Alert status

            $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.JobServer], $AgentJobHistory)
            $AgentJobHistory = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.JobServer])

            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'AgentMaximumHistoryRows' -Value (($__dbcconfig | Where-Object { $_.Name -eq 'agent.history.maximumhistoryrows' }).Value)
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'AgentMaximumJobHistoryRows' -Value (($__dbcconfig | Where-Object { $_.Name -eq 'agent.history.maximumjobhistoryrows' }).Value)

            $JobHistory = [PSCustomObject]@{
                InstanceName                  = $Instance.Name
                CurrentMaximumHistoryRows     = $Instance.JobServer.MaximumHistoryRows
                ExpectedMaximumHistoryRows    = $ConfigValues.AgentMaximumHistoryRows
                CurrentMaximumJobHistoryRows  = $Instance.JobServer.MaximumJobHistoryRows
                ExpectedMaximumJobHistoryRows = $ConfigValues.AgentMaximumJobHistoryRows
            }
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

            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'LongRunningJob' -Value (($__dbcconfig | Where-Object { $_.Name -eq 'agent.longrunningjob.percentage' }).Value)

            $LongRunningJobs = $($runningjobs | Where-Object { $_.AvgSec -ne 0 }).ForEach{
                [PSCustomObject]@{
                    InstanceName                     = $Instance.Name
                    JobName                          = $PSItem.JobName
                    RunningSeconds                   = $PSItem.RunningSeconds
                    Average                          = $PSItem.AvgSec
                    Diff                             = $PSItem.Diff
                    ExpectedLongRunningJobPercentage = $ConfigValues.LongRunningJob
                    ActualLongRunningJobPercentage   = [math]::Round($PSItem.Diff / $PSItem.AvgSec * 100)
                }
            }
        }
        'LastJobRunTime' {
            $maxdays = ($__dbcconfig | Where-Object { $_.Name -eq 'agent.failedjob.since' }).Value
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
                    WHERE msdb.dbo.agent_datetime(jh.run_date, jh.run_time) > DATEADD(DAY,- {0},GETDATE())
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
                WHERE msdb.dbo.agent_datetime(run_date, run_time) > DATEADD(DAY,- {0},GETDATE())
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
                DROP Table #dbachecksAverageRunTime" -f $maxdays
            $lastagentjobruns = Invoke-DbaQuery -SqlInstance $Instance -Database msdb -Query $query

            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'LastJobRuns' -Value (($__dbcconfig | Where-Object { $_.Name -eq 'agent.lastjobruntime.percentage' }).Value)

            $LastJobRuns = $($lastagentjobruns | Where-Object { $_.AvgSec -ne 0 }).ForEach{
                [PSCustomObject]@{
                    InstanceName                 = $Instance.Name
                    JobName                      = $PSItem.JobName
                    Duration                     = $PSItem.Duration
                    Average                      = $PSItem.AvgSec
                    ExpectedRunningJobPercentage = $ConfigValues.LastJobRuns
                    ActualRunningJobPercentage   = [math]::Round($PSItem.Diff / $PSItem.AvgSec * 100)
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
        JobsFailed          = $JobsFailed
        LastJobRuns         = $LastJobRuns
        LongRunningJobs     = $LongRunningJobs
        AgentAlerts         = $AgentAlerts
        JobHistory          = @($JobHistory)
    }
    return $testInstanceObject
}