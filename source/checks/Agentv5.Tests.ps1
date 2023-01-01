# So the v5 files need to be handled differently.
# We will start with a BeforeDiscovery which will gather the Instance Information up front
# Gather the instances we know are not contactable

BeforeDiscovery {
    # Gather the instances we know are not contactable
    [string[]]$NotContactable = (Get-PSFConfig -Module dbachecks -Name global.notcontactable).Value
    # Get all the tags in use in this run
    $Tags = Get-CheckInformation -Check $Check -Group Agent -AllChecks $AllChecks -ExcludeCheck $ChecksToExclude

    $InstancesToTest = @(Get-Instance).ForEach{
        # just add it to the Not Contactable list
        if ($NotContactable -notcontains $psitem) {
            $Instance = $psitem
            try {
                $InstanceSMO = Connect-DbaInstance -SqlInstance $Instance -ErrorAction SilentlyContinue -ErrorVariable errorvar
            }
            catch {
                $NotContactable += $Instance
            }
            if ($NotContactable -notcontains $psitem) {
                if ($null -eq $InstanceSMO.version) {
                    $NotContactable += $Instance
                }
                # ToDo: Give cool message about Agent not existing on Express Edition?!
                elseif (($InstanceSMO).Edition -like "Express Edition*") {}
                else {
                    # Get the relevant information for the checks in one go to save repeated trips to the instance and set values for Not Contactable tests if required
                    Get-AllAgentInfo -Instance $InstanceSMO -Tags $Tags
                }
            }
        }
    }
    Write-PSFMessage -Message "Instances = $($InstancesToTest.Name)" -Level Verbose
    Set-PSFConfig -Module dbachecks -Name global.notcontactable -Value $NotContactable
}


Describe "Database Mail XPs" -Tag DatabaseMailEnabled, CIS, security -ForEach $InstancesToTest {
    $skip = Get-DbcConfigValue skip.agent.databasemailenabled
    Context "Testing Database Mail XPs on <_.Name>" {
        It "Testing Database Mail XPs is set to <_.DatabaseMailEnabled> on <_.Name>" -Skip:$skip {
            $PSItem.DatabaseMailEnabled | Should -Be $PSItem.ConfigValues.DatabaseMailEnabled -Because 'The Database Mail XPs setting should be set correctly'
        }
    }
}

Describe "SQL Agent Account" -Tag AgentServiceAccount, ServiceAccount -ForEach $InstancesToTest {
    $skipServiceState = Get-DbcConfigValue skip.agent.servicestate
    $skipServiceStartMode = Get-DbcConfigValue skip.agent.servicestartmode

    Context "Testing SQL Agent is running on <_.Name>" {
        It "SQL Agent should be running for <_.InstanceName> on <_.Name>" -Skip:$skipServiceState {
            $PSItem.Agent.State | Should -Be "Running" -Because 'The agent service is required to run SQL Agent jobs'
        }
    }
    if ($PSItem.IsClustered) {
        It "SQL Agent service should have a start mode of Manual for FailOver Clustered Instance <_.InstanceName> on <_.Name>" -Skip:$skipServiceStartMode {
            $PSItem.Agent.StartMode | Should -Be "Manual" -Because 'Clustered Instances required that the Agent service is set to manual'
        }
    }
    else {
        It "SQL Agent service should have a start mode of Automatic for standalone instance <_.InstanceName> on <_.Name>" -Skip:$skipServiceStartMode {
            $PSItem.Agent.StartMode | Should -Be "Automatic" -Because 'Otherwise the Agent Jobs wont run if the server is restarted'
        }
    }
}

Describe "DBA Operators" -Tag DbaOperator, Operator -ForEach $InstancesToTest {
    $skipOperatorName = Get-DbcConfigValue skip.agent.operatorname
    $skipOperatorEamil = Get-DbcConfigValue skip.agent.operatoremail

    Context "Testing DBA Operators exists on <_.Name>" {
        It "The Operator <_.ExpectedOperatorName> exists on <_.Name>" -Skip:$skipOperatorName -ForEach ($PSItem.Operator | Where-Object ExpectedOperatorName -ne 'null') {
            $PSItem.ExpectedOperatorName | Should -BeIn $PSItem.ActualOperatorName -Because 'This Operator is expected to exist'
        }

        It "The Operator email <_.ExpectedOperatorEmail> is correct on <_.Name>" -Skip:$skipOperatorEamil -ForEach ($PSItem.Operator | Where-Object ExpectedOperatorEmail -ne 'null') {
            $PSItem.ExpectedOperatorEmail | Should -BeIn $PSItem.ActualOperatorEmail -Because 'This operator email is expected to exist'
        }
    }
}

# Describe "Failsafe Operator" -Tags FailsafeOperator, Operator, $filename {
#     if ($NotContactable -contains $psitem) {
#         Context "Testing failsafe operator exists on $psitem" {
#             It "Can't Connect to $Psitem" {
#                 $false | Should -BeTrue -Because "The instance should be available to be connected to!"
#             }
#         }
#     }
#     else {
#         Context "Testing failsafe operator exists on $psitem" {
#             $failsafeoperator = Get-DbcConfigValue agent.failsafeoperator
#             It "The Failsafe Operator exists on $psitem" {
#                 (Connect-DbaInstance -SqlInstance $psitem).JobServer.AlertSystem.FailSafeOperator | Should -Be $failsafeoperator -Because 'The failsafe operator will ensure that any job failures will be notified to someone if not set explicitly'
#             }
#         }
#     }
# }

# Describe "Database Mail Profile" -Tags DatabaseMailProfile, $filename {
#     if ($NotContactable -contains $psitem) {
#         Context "Testing database mail profile is set on $psitem" {
#             It "Can't Connect to $Psitem" {
#                 $false | Should -BeTrue -Because "The instance should be available to be connected to!"
#             }
#         }
#     }
#     else {
#         Context "Testing database mail profile is set on $psitem" {
#             $databasemailprofile = Get-DbcConfigValue  agent.databasemailprofile
#             It "The Database Mail profile $databasemailprofile exists on $psitem" {
#                 ((Get-DbaDbMailProfile -SqlInstance $InstanceSMO).Name -contains $databasemailprofile) | Should -Be $true -Because 'The database mail profile is required to send emails'
#             }
#         }
#     }
# }

# Describe "Agent Mail Profile" -Tags AgentMailProfile, $filename {
#     if ($NotContactable -contains $psitem) {
#         Context "Testing SQL Agent Alert System database mail profile is set on $psitem" {
#             It "Can't Connect to $Psitem" {
#                 $false | Should -BeTrue -Because "The instance should be available to be connected to!"
#             }
#         }
#     }
#     else {
#         Context "Testing SQL Agent Alert System database mail profile is set on $psitem" {
#             $agentmailprofile = Get-DbcConfigValue  agent.databasemailprofile
#             It "The SQL Server Agent Alert System should have an enabled database mail profile on $psitem" {
#                 (Get-DbaAgentServer -SqlInstance $InstanceSMO).DatabaseMailProfile | Should -Be $agentmailprofile -Because 'The SQL Agent Alert System needs an enabled database mail profile to send alert emails'
#             }
#         }
#     }
# }

# Describe "Failed Jobs" -Tags FailedJob, $filename {

#     if ($NotContactable -contains $psitem) {
#         Context "Checking for failed enabled jobs on $psitem" {
#             It "Can't Connect to $Psitem" {
#                 $false | Should -BeTrue -Because "The instance should be available to be connected to!"
#             }
#         }
#     }
#     else {
#         $maxdays = Get-DbcConfigValue agent.failedjob.since
#         $startdate = (Get-Date).AddDays( - $maxdays)
#         Context "Checking for failed enabled jobs since $startdate on $psitem" {
#             $excludecancelled = Get-DbcConfigValue agent.failedjob.excludecancelled
#             @(Get-DbaAgentJob -SqlInstance $psitem | Where-Object { $Psitem.IsEnabled -and ($psitem.LastRunDate -gt $startdate) }).ForEach{
#                 if ($psitem.LastRunOutcome -eq "Unknown") {
#                     It -Skip "We chose to skip this as $psitem's last run outcome is unknown on $($psitem.SqlInstance)" {
#                         $psitem.LastRunOutcome | Should -Be "Succeeded" -Because 'All Agent Jobs should have succeed this one is unknown - you need to investigate the failed jobs'
#                     }
#                 }
#                 elseif (($psitem.LastRunOutcome -eq "Cancelled") -and ($excludecancelled -eq $true)) {
#                     It -Skip "We chose to skip this as $psitem's last run outcome is cancelled on $($psitem.SqlInstance)" {
#                         $psitem.LastRunOutcome | Should -Be "Succeeded" -Because 'All Agent Jobs should have succeed this one is unknown - you need to investigate the failed jobs'
#                     }
#                 }
#                 else {
#                     It "$psitem's last run outcome is $($psitem.LastRunOutcome) on $($psitem.SqlInstance)" {
#                         $psitem.LastRunOutcome | Should -Be "Succeeded" -Because 'All Agent Jobs should have succeed - you need to investigate the failed jobs'
#                     }
#                 }
#             }
#         }
#     }
# }

# Describe "Valid Job Owner" -Tags ValidJobOwner, $filename {
#     [string[]]$targetowner = Get-DbcConfigValue agent.validjobowner.name

#     if ($NotContactable -contains $psitem) {
#         Context "Testing job owners on $psitem" {
#             It "Can't Connect to $Psitem" {
#                 $false | Should -BeTrue -Because "The instance should be available to be connected to!"
#             }
#         }
#     }
#     else {
#         Context "Testing job owners on $psitem" {
#             @(Get-DbaAgentJob -SqlInstance $psitem -EnableException:$false).ForEach{
#                 It "Job $($psitem.Name)  - owner $($psitem.OwnerLoginName) should be in this list ( $( [String]::Join(", ", $targetowner) ) ) on $($psitem.SqlInstance)" {
#                     $psitem.OwnerLoginName | Should -BeIn $TargetOwner -Because "The account that is the job owner is not what was expected"
#                 }
#             }
#         }
#     }
# }
# Describe "Invalid Job Owner" -Tags InValidJobOwner, $filename {
#     [string[]]$targetowner = Get-DbcConfigValue agent.invalidjobowner.name

#     if ($NotContactable -contains $psitem) {
#         Context "Testing job owners on $psitem" {
#             It "Can't Connect to $Psitem" {
#                 $false | Should -BeTrue -Because "The instance should be available to be connected to!"
#             }
#         }
#     }
#     else {
#         Context "Testing job owners on $psitem" {
#             @(Get-DbaAgentJob -SqlInstance $psitem -EnableException:$false).ForEach{
#                 It "Job $($psitem.Name)  - owner $($psitem.OwnerLoginName) should not be in this list ( $( [String]::Join(", ", $targetowner) ) ) on $($psitem.SqlInstance)" {
#                     $psitem.OwnerLoginName | Should -Not -BeIn $TargetOwner -Because "The account that is the job owner has been defined as not valid"
#                 }
#             }
#         }
#     }
# }

# Describe "Agent Alerts" -Tags AgentAlert, $filename {
#     $severity = Get-DbcConfigValue agent.alert.Severity
#     $messageid = Get-DbcConfigValue agent.alert.messageid
#     $AgentAlertJob = Get-DbcConfigValue agent.alert.Job
#     $AgentAlertNotification = Get-DbcConfigValue agent.alert.Notification
#     $skip = Get-DbcConfigValue skip.agent.alert
#     if ($NotContactable -contains $psitem) {
#         Context "Testing Agent Alerts Severity exists on $psitem" {
#             It "Can't Connect to $Psitem" {
#                 $false | Should -BeTrue -Because "The instance should be available to be connected to!"
#             }
#         }
#         Context "Testing Agent Alerts MessageID exists on $psitem" {
#             It "Can't Connect to $Psitem" {
#                 $false | Should -BeTrue -Because "The instance should be available to be connected to!"
#             }
#         }
#     }
#     else {
#         $alerts = Get-DbaAgentAlert -SqlInstance $psitem
#         Context "Testing Agent Alerts Severity exists on $psitem" {
#             ForEach ($sev in $severity) {
#                 It "Severity $sev Alert should exist on $psitem" -Skip:$skip {
#                     ($alerts.Where{ $psitem.Severity -eq $sev }) | Should -be $true -Because "Recommended Agent Alerts to exists http://blog.extreme-advice.com/2013/01/29/list-of-errors-and-severity-level-in-sql-server-with-catalog-view-sysmessages/"
#                 }
#                 It "Severity $sev Alert should be enabled on $psitem" -Skip:$skip {
#                     ($alerts.Where{ $psitem.Severity -eq $sev }).IsEnabled | Should -be $true -Because "Configured alerts should be enabled"
#                 }
#                 if ($AgentAlertJob) {
#                     It "A job name for Severity $sev Alert on $psitem" -Skip:$skip {
#                         ($alerts.Where{ $psitem.Severity -eq $sev }).jobname -ne $null | Should -be $true -Because "Should notify by SQL Agent Job"
#                     }
#                 }
#                 if ($AgentAlertNotification) {
#                     It "Severity $sev Alert should have a notification on $psitem" -Skip:$skip {
#                         ($alerts.Where{ $psitem.Severity -eq $sev }).HasNotification -in 1, 2, 3, 4, 5, 6, 7 | Should -be $true -Because "Should notify by Agent notifications"
#                     }
#                 }
#             }
#         }
#         Context "Testing Agent Alerts MessageID exists on $psitem" {
#             ForEach ($mid in $messageid) {
#                 It "Message_ID $mid Alert should exist on $psitem" -Skip:$skip {
#                     ($alerts.Where{ $psitem.messageid -eq $mid }) | Should -be $true -Because "Recommended Agent Alerts to exists http://blog.extreme-advice.com/2013/01/29/list-of-errors-and-severity-level-in-sql-server-with-catalog-view-sysmessages/"
#                 }
#                 It "Message_ID $mid Alert should be enabled on $psitem" -Skip:$skip {
#                     ($alerts.Where{ $psitem.messageid -eq $mid }) | Should -be $true -Because "Configured alerts should be enabled"
#                 }
#                 if ($AgentAlertJob) {
#                     It "A Job name for Message_ID $mid Alert should be on $psitem" -Skip:$skip {
#                         ($alerts.Where{ $psitem.messageid -eq $mid }).jobname -ne $null | Should -be $true -Because "Should notify by SQL Agent Job"
#                     }
#                 }
#                 if ($AgentAlertNotification) {
#                     It "Message_ID $mid Alert should have a notification on $psitem" -Skip:$skip {
#                         ($alerts.Where{ $psitem.messageid -eq $mid }).HasNotification -in 1, 2, 3, 4, 5, 6, 7 | Should -be $true -Because "Should notify by Agent notifications"
#                     }
#                 }
#             }
#         }
#     }
# }

# Describe "Job History Configuration" -Tags JobHistory, $filename {
#     if ($NotContactable -contains $psitem) {
#         Context "Testing job history configuration on $psitem" {
#             It "Can't Connect to $Psitem" {
#                 $false | Should -BeTrue -Because "The instance should be available to be connected to!"
#             }
#         }
#     }
#     else {
#         Context "Testing job history configuration on $psitem" {
#             [int]$minimumJobHistoryRows = Get-DbcConfigValue agent.history.maximumhistoryrows
#             [int]$minimumJobHistoryRowsPerJob = Get-DbcConfigValue agent.history.maximumjobhistoryrows

#             $AgentServer = Get-DbaAgentServer -SqlInstance $psitem -EnableException:$false

#             if ($minimumJobHistoryRows -eq -1) {
#                 It "The maximum job history configuration should be set to disabled on $psitem" {
#                     Assert-JobHistoryRowsDisabled -AgentServer $AgentServer -minimumJobHistoryRows $minimumJobHistoryRows
#                 }
#             }
#             else {
#                 It "The maximum job history number of rows configuration should be greater or equal to $minimumJobHistoryRows on $psitem" {
#                     Assert-JobHistoryRows -AgentServer $AgentServer -minimumJobHistoryRows $minimumJobHistoryRows
#                 }
#                 It "The maximum job history rows per job configuration should be greater or equal to $minimumJobHistoryRowsPerJob on $psitem" {
#                     Assert-JobHistoryRowsPerJob -AgentServer $AgentServer -minimumJobHistoryRowsPerJob $minimumJobHistoryRowsPerJob
#                 }
#             }
#         }
#     }
# }
# Describe "Long Running Agent Jobs" -Tags LongRunningJob, $filename {
#     $skip = Get-DbcConfigValue skip.agent.longrunningjobs
#     $runningjobpercentage = Get-DbcConfigValue agent.longrunningjob.percentage
#     if (-not $skip) {
#         $query = "SELECT
# JobName,
# AvgSec,
# start_execution_date as StartDate,
# RunningSeconds,
# RunningSeconds - AvgSec AS Diff
# FROM
# (
# SELECT
# j.name AS JobName,
# start_execution_date,
# AVG(DATEDIFF(SECOND, 0, STUFF(STUFF(RIGHT('000000'
# + CONVERT(VARCHAR(6),jh.run_duration),6),5,0,':'),3,0,':'))) AS AvgSec,
# ja.start_execution_date as startdate,
# DATEDIFF(second, ja.start_execution_date, GetDate()) AS RunningSeconds
# FROM msdb.dbo.sysjobactivity ja
# JOIN msdb.dbo.sysjobs j
# ON ja.job_id = j.job_id
# JOIN msdb.dbo.sysjobhistory jh
# ON jh.job_id = j.job_id
# WHERE start_execution_date is not null
# AND stop_execution_date is null
# AND run_duration < 235959
# AND run_duration >= 0
# AND ja.start_execution_date > DATEADD(day,-1,GETDATE())
# GROUP BY j.name,j.job_id,start_execution_date,stop_execution_date,ja.job_id
# ) AS t
# ORDER BY JobName;"
#         $runningjobs = Invoke-DbaQuery -SqlInstance $PSItem -Database msdb -Query $query
#     }
#     if ($NotContactable -contains $psitem) {
#         Context "Testing long running jobs on $psitem" {
#             It "Can't Connect to $Psitem" {
#                 $false | Should -BeTrue -Because "The instance should be available to be connected to!"
#             }
#         }
#     }
#     else {
#         Context "Testing long running jobs on $psitem" {
#             if ($runningjobs) {
#                 foreach ($runningjob in $runningjobs | Where-Object { $_.AvgSec -ne 0 }) {
#                     It "Running job $($runningjob.JobName) duration should not be more than $runningjobpercentage % extra of the average run time on $psitem" -Skip:$skip {
#                         Assert-LongRunningJobs -runningjob $runningjob -runningjobpercentage $runningjobpercentage
#                     }
#                 }
#             }
#             else {
#                 It "There are no running jobs currently on $psitem" -Skip:$skip {
#                     $True | SHould -BeTrue
#                 }
#             }
#         }
#     }
# }
# Describe "Last Agent Job Run" -Tags LastJobRunTime, $filename {
#     $skip = Get-DbcConfigValue skip.agent.lastjobruntime
#     $runningjobpercentage = Get-DbcConfigValue agent.lastjobruntime.percentage
#     $maxdays = Get-DbcConfigValue agent.failedjob.since
#     if (-not $skip) {
#         $query = "IF OBJECT_ID('tempdb..#dbachecksLastRunTime') IS NOT NULL DROP Table #dbachecksLastRunTime
#         SELECT * INTO #dbachecksLastRunTime
#         FROM
#         (
#         SELECT
#         j.job_id,
#         j.name AS JobName,
#         DATEDIFF(SECOND, 0, STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(6),jh.run_duration),6),5,0,':'),3,0,':')) AS Duration
#         FROM msdb.dbo.sysjobs j
#         INNER JOIN
#             (
#                 SELECT job_id, instance_id = MAX(instance_id)
#                     FROM msdb.dbo.sysjobhistory
#                     GROUP BY job_id
#             ) AS h
#             ON j.job_id = h.job_id
#         INNER JOIN
#             msdb.dbo.sysjobhistory AS jh
#             ON jh.job_id = h.job_id
#             AND jh.instance_id = h.instance_id
#             WHERE msdb.dbo.agent_datetime(jh.run_date, jh.run_time) > DATEADD(DAY,- $maxdays,GETDATE())
#             AND jh.step_id = 0
#         ) AS lrt

#         IF OBJECT_ID('tempdb..#dbachecksAverageRunTime') IS NOT NULL DROP Table #dbachecksAverageRunTime
#         SELECT * INTO #dbachecksAverageRunTime
#         FROM
#         (
#         SELECT
#         job_id,
#         AVG(DATEDIFF(SECOND, 0, STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(6),run_duration),6),5,0,':'),3,0,':'))) AS AvgSec
#         FROM msdb.dbo.sysjobhistory hist
#         WHERE msdb.dbo.agent_datetime(run_date, run_time) > DATEADD(DAY,- $maxdays,GETDATE())
#         AND Step_id = 0
#         AND run_duration >= 0
#         GROUP BY job_id
#         ) as art

#         SELECT
#         JobName,
#         Duration,
#         AvgSec,
#         Duration - AvgSec AS Diff
#         FROM #dbachecksLastRunTime lastrun
#         JOIN #dbachecksAverageRunTime avgrun
#         ON lastrun.job_id = avgrun.job_id

#         DROP Table #dbachecksLastRunTime
#         DROP Table #dbachecksAverageRunTime"
#         $lastagentjobruns = Invoke-DbaQuery -SqlInstance $PSItem -Database msdb -Query $query
#         Context "Testing last job run time on $psitem" {
#             foreach ($lastagentjobrun in $lastagentjobruns | Where-Object { $_.AvgSec -ne 0 }) {
#                 It "Job $($lastagentjobrun.JobName) last run duration should be not be greater than $runningjobpercentage % extra of the average run time on $psitem" -Skip:$skip {
#                     Assert-LastJobRun -lastagentjobrun $lastagentjobrun -runningjobpercentage $runningjobpercentage
#                 }
#             }
#         }
#     }
#     else {
#         Context "Testing last job run time on $psitem" {
#             It "Job average run time on $psitem" -Skip {
#                 Assert-LastJobRun -lastagentjobrun $lastagentjobrun -runningjobpercentage $runningjobpercentage
#             }
#         }
#     }
# }



