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

    #TODO : Clean this up
    Write-PSFMessage -Message "Instances = $($InstancesToTest.Name)" -Level Verbose

    Set-PSFConfig -Module dbachecks -Name global.notcontactable -Value $NotContactable

    # Get-DbcConfig is expensive so we call it once
    $__dbcconfig = Get-DbcConfig
}

Describe "Database Mail XPs" -Tag DatabaseMailEnabled, CIS, security, Agent -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.agent.databasemailenabled' }).Value
    Context "Testing Database Mail XPs on <_.Name>" {
        It "Testing Database Mail XPs is set to <_.ConfigValues.DatabaseMailEnabled> on <_.Name>" -Skip:$skip {
            $PSItem.DatabaseMailEnabled | Should -Be $PSItem.ConfigValues.DatabaseMailEnabled -Because 'The Database Mail XPs setting should be set correctly'
        }
    }
}

Describe "SQL Agent Account" -Tag AgentServiceAccount, ServiceAccount, Agent -ForEach $InstancesToTest {
    $skipServiceState = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.agent.servicestate' }).Value
    $skipServiceStartMode = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.agent.servicestartmode' }).Value

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

Describe "DBA Operator" -Tag DbaOperator, Operator, Agent -ForEach $InstancesToTest {
    $skipOperatorName = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.agent.dbaoperatorname' }).Value
    $skipOperatorEmail = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.agent.dbaoperatoremail' }).Value

    Context "Testing DBA Operators exists on <_.Name>" {
        It "The Operator <_.ExpectedOperatorName> exists on <_.Name>" -Skip:$skipOperatorName -ForEach ($PSItem.Operator | Where-Object ExpectedOperatorName -NE 'null') {
            $PSItem.ExpectedOperatorName | Should -BeIn $PSItem.ActualOperatorName -Because 'This Operator is expected to exist'
        }

        It "The Operator email <_.ExpectedOperatorEmail> is correct on <_.Name>" -Skip:$skipOperatorEmail -ForEach ($PSItem.Operator | Where-Object ExpectedOperatorEmail -NE 'null') {
            $PSItem.ExpectedOperatorEmail | Should -BeIn $PSItem.ActualOperatorEmail -Because 'This operator email is expected to exist'
        }
    }
}

Describe "Failsafe operator" -Tag FailsafeOperator, Operator, Agent -ForEach $InstancesToTest {
    $skipFailsafeOperator = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.agent.failsafeoperator' }).Value

    Context "Testing failsafe operator exists on <_.Name>" {
        It "The failsafe operator <_.FailSafeOperator.ExpectedFailSafeOperator> exists on <_.Name>" -Skip:$skipFailsafeOperator {
            $PSItem.FailSafeOperator.ActualFailSafeOperator | Should -Be $PSItem.FailSafeOperator.ExpectedFailSafeOperator -Because 'The failsafe operator will ensure that any job failures will be notified to someone if not set explicitly'
        }
    }
}

Describe "Database Mail Profile" -Tag DatabaseMailProfile, Agent -ForEach $InstancesToTest {
    $skipDatabaseMailProfile = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.agent.databasemailprofile' }).Value

    Context "Testing Database Mail Profile exists on <_.Name>" {
        It "The Database Mail profile <_.DatabaseMailProfile.ExpectedDatabaseMailProfile> exists on <_.Name>" -Skip:$skipDatabaseMailProfile { #-ForEach ($PSItem.DatabaseMailProfile | Where-Object ExpectedDatabaseMailProfile -NE 'null') {
            $PSItem.DatabaseMailProfile.ActualDatabaseMailProfile | Should -BeIn $PSItem.DatabaseMailProfile.ExpectedDatabaseMailProfile -Because 'The database mail profile is required to send emails'
        }
    }
}

Describe "Agent Mail Profile" -Tag AgentMailProfile, Agent -ForEach $InstancesToTest {
    $skipAgentMailProfile = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.agent.mailprofile' }).Value

    Context "Testing SQL Agent Alert System database mail profile is set on <_.Name>" {
        It "The SQL Server Agent Alert System has the mail profile <_.AgentMailProfile.ExpectedAgentMailProfile> enabled as profile on <_.Name>." -Skip:$skipAgentMailProfile { #-ForEach ($PSItem.DatabaseMailProfile | Where-Object ExpectedDatabaseMailProfile -NE 'null') {
            $PSItem.AgentMailProfile.ActualAgentMailProfile | Should -Be $PSItem.AgentMailProfile.ExpectedAgentMailProfile -Because 'The SQL Agent Alert System needs an enabled database mail profile to send alert emails'
        }
    }
}

Describe "Valid Job Owner" -Tag ValidJobOwner, Agent -ForEach $InstancesToTest {
    $skipAgentJobTargetOwner = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.agent.jobowner' }).Value

    Context "Testing SQL Agent Job Owner on <_.Name>" {
        It "The Job <_.JobName> has the Job Owner <_.ActualJobOwnerName> that should exist in this list ($([String]::Join(', ', "<_.ExpectedJobOwnerName>"))) on <_.InstanceName>" -Skip:$skipAgentJobTargetOwner -ForEach ($PSItem.JobOwner) {
            $PSItem.ActualJobOwnerName | Should -BeIn $PSItem.ExpectedJobOwnerName -Because 'The account that is the job owner is not what was expected'
        }
    }
}


Describe "Invalid Job Owner" -Tag InvalidJobOwner, Agent -ForEach $InstancesToTest {
    $skipAgentJobTargetInvalidOwner = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.agent.invalidjobowner.name' }).Value

    Context "Testing Invalid SQL Agent Job Owner on <_.Name>" {
        It "The Job <_.JobName> has the Job Owner <_.ActualJobOwnerName> that shouldn't exist in this list ($([String]::Join(', ', "<_.InvalidJobOwnerName>"))) on <_.InstanceName>" -Skip:$skipAgentJobTargetInvalidOwner -ForEach ($PSItem.InvalidJobOwner) {
            $PSItem.ActualJobOwnerName | Should -Not -BeIn $PSItem.InvalidJobOwnerName -Because 'The account that is the job owner has been defined as not valid'
        }
    }
}


Describe "Last Agent Job Run" -Tag LastJobRunTime, Agent -ForEach $InstancesToTest {
    $skipAgentJobLastRun = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.agent.lastjobruntime' }).Value

    Context "Testing last job run time on <_.Name>" {
        It "Job <_.JobName> last run duration (<_.Duration> seconds) should not be greater than <_.ExpectedRunningJobPercentage>% extra of the average run time (<_.Average> seconds) on <_.InstanceName>" -Skip:$skipAgentJobLastRun -ForEach ($PSItem.LastJobRuns) {
            $PSItem.ActualRunningJobPercentage | Should -BeLessThan $PSItem.ExpectedRunningJobPercentage -Because "The last run of job $($PSItem.JobName) was $($PSItem.Duration) seconds. This is more than the $($PSItem.ExpectedRunningJobPercentage)% specified as the maximum variance"
        }
    }
}


Describe "Long Running Agent Jobs" -Tag LongRunningJob, Agent -ForEach $InstancesToTest {
    $skipAgentLongRunningJobs = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.agent.longrunningjobs' }).Value

    Context "Testing long running jobs on <_.Name>" {
        It "Running job <_.JobName> duration should not be more than <_.ExpectedLongRunningJobPercentage>% extra of the average run time (<_.Average> seconds) on <_.InstanceName>" -Skip:$skipAgentLongRunningJobs -ForEach ($PSItem.LongRunningJobs) {
            $PSItem.ActualLongRunningJobPercentage | Should -BeLessThan $PSItem.ExpectedLongRunningJobPercentage -Because "The current running job $($PSItem.JobName) has been running for $($PSItem.Diff) seconds longer than the average run time. This is more than the $($PSItem.ExpectedLongRunningJobPercentage)% specified as the maximum"
        }
    }
}


Describe "SQL Agent Failed Jobs" -Tag FailedJob, Agent -ForEach $InstancesToTest {
    $skipAgentFailedJobs = ($__dbcconfig | Where-Object { $_.Name -eq 'skip.agent.failedjobs' }).Value
    $excludecancelled = ($__dbcconfig | Where-Object { $_.Name -eq 'agent.failedjob.excludecancelled' }).Value

    Context "Checking for failed enabled jobs since $startdate on <_.Name>" {
        ($PSItem.JobsFailed).ForEach{
            Write-PSFMessage -Message "LastRunOutcome = $($PSItem)" -Level Verbose
            if ($PSItem.LastRunOutcome -eq "Unknown") {
                It "We chose to skip this as $($PSItem.JobName)'s last run outcome is unknown on $($PSItem.InstanceName)" -Skip {
                    $PSItem.LastRunOutcome | Should -Be $PSItem.ExpectedOutcome -Because 'All Agent Jobs should have succeed this one is unknown - you need to investigate the failed jobs'
                }
            }
            elseif (($PSItem.LastRunOutcome -eq "Cancelled") -and ($excludecancelled -eq $true)) {
                It "You chose to skip this as $($PSItem.JobName)'s last run outcome is cancelled on $($PSItem.InstanceName)" -Skip  {
                    $PSItem.LastRunOutcome | Should -Be $PSItem.ExpectedOutcome -Because 'All Agent Jobs should have succeed this one is Cancelled - you need to investigate the failed jobs'
                }
            }
            else {
                It "Job $($PSItem.JobName) last run outcome is $($PSItem.LastRunOutcome) on $($PSItem.InstanceName)" -Skip:$skipAgentFailedJobs {
                    $PSItem.LastRunOutcome | Should -Be $PSItem.ExpectedOutcome -Because "All Agent Jobs should have succeed - you need to investigate the failed jobs"
                }
            }
        }
    }
}







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





