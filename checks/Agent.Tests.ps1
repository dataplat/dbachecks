$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
. $PSScriptRoot/../internal/assertions/Agent.Assertions.ps1
[string[]]$NotContactable = (Get-PSFConfig -Module dbachecks -Name global.notcontactable).Value

Set-PSFConfig -Module dbachecks -Name global.notcontactable -Value $NotContactable

@(Get-Instance).ForEach{
    if ($NotContactable -notcontains $psitem) {
        $Instance = $psitem
        try {
            $InstanceSMO = Connect-DbaInstance	-SqlInstance $Instance -ErrorAction SilentlyContinue -ErrorVariable errorvar
        }
        catch {
            $NotContactable += $Instance
        }
        if ($NotContactable -notcontains $psitem) {
            if ($null -eq $InstanceSMO.version) {
                $NotContactable += $Instance
            }
            elseif (($InstanceSMO).Edition -like "Express Edition*") { }
            else {
                Describe "Database Mail XPs" -Tags DatabaseMailEnabled, CIS, security, $filename {
                    $DatabaseMailEnabled = Get-DbcConfigValue policy.security.DatabaseMailEnabled
                    if ($NotContactable -contains $psitem) {
                        Context "Testing Database Mail XPs on $psitem" {
                            It "Can't Connect to $Psitem" {
                                $false	| Should -BeTrue -Because "The instance should be available to be connected to!"
                            }
                        }
                    }
                    else {
                        Context "Testing Testing Database Mail XPs on $psitem" {
                            It "Testing Database Mail XPs is set to $DatabaseMailEnabled on $psitem" {
                                Assert-DatabaseMailEnabled -SQLInstance $Psitem -DatabaseMailEnabled $DatabaseMailEnabled
                            }
                        }
                    }
                }

                Describe "SQL Agent Account" -Tags AgentServiceAccount, ServiceAccount, $filename {
                    if ($NotContactable -contains $psitem) {
                        Context "Testing SQL Agent is running on $psitem" {
                            It "Can't Connect to $Psitem" {
                                $false | Should -BeTrue -Because "The instance should be available to be connected to!"
                            }
                        }
                    }
                    else {
                        # cant check agent on container - hmm does this actually work with instance need to check
                        if (-not $IsLinux -and ($InstanceSMO.HostPlatform -ne 'Linux')) {

                            Context "Testing SQL Agent is running on $psitem" {
                                @(Get-DbaService -ComputerName $psitem -Type Agent).ForEach{
                                    It "SQL Agent should be running for $($psitem.InstanceName) on $($psitem.ComputerName)" {
                                        $psitem.State | Should -Be "Running" -Because 'The agent service is required to run SQL Agent jobs'
                                    }
                                    if ($InstanceSMO.IsClustered) {
                                        It "SQL Agent service should have a start mode of Manual for FailOver Clustered Instance $($psitem.InstanceName) on $($psitem.ComputerName)" {
                                            $psitem.StartMode | Should -Be "Manual" -Because 'Clustered Instances required that the Agent service is set to manual'
                                        }
                                    }
                                    else {
                                        It "SQL Agent service should have a start mode of Automatic for standalone instance $($psitem.InstanceName) on $($psitem.ComputerName)" {
                                            $psitem.StartMode | Should -Be "Automatic" -Because 'Otherwise the Agent Jobs wont run if the server is restarted'
                                        }
                                    }
                                }
                            }
                        }
                        else {
                            Context "Testing SQL Agent is running on $psitem" {
                                It "Running on Linux or connecting to container so can't check Services on $Psitem" -skip {
                                }
                            }
                        }
                    }
                }

                Describe "DBA Operators" -Tags DbaOperator, Operator, $filename {
                    if ($NotContactable -contains $psitem) {
                        Context "Testing DBA Operators exists on $psitem" {
                            It "Can't Connect to $Psitem" {
                                $false | Should -BeTrue -Because "The instance should be available to be connected to!"
                            }
                        }
                    }
                    else {
                        Context "Testing DBA Operators exists on $psitem" {
                            $operatorname = Get-DbcConfigValue agent.dbaoperatorname
                            $operatoremail = Get-DbcConfigValue agent.dbaoperatoremail
                            $results = Get-DbaAgentOperator -SqlInstance $psitem -Operator $operatorname
                            @($operatorname).ForEach{
                                It "The Operator exists on $psitem" {
                                    $psitem | Should -BeIn $Results.Name -Because 'This Operator is expected to exist'
                                }
                            }
                            @($operatoremail).ForEach{
                                if ($operatoremail) {
                                    It "The Operator email $operatoremail is correct on $psitem" {
                                        $psitem | Should -BeIn $results.EmailAddress -Because 'This operator email is expected to exist'
                                    }
                                }
                            }
                        }
                    }
                }

                Describe "Failsafe Operator" -Tags FailsafeOperator, Operator, $filename {
                    if ($NotContactable -contains $psitem) {
                        Context "Testing failsafe operator exists on $psitem" {
                            It "Can't Connect to $Psitem" {
                                $false | Should -BeTrue -Because "The instance should be available to be connected to!"
                            }
                        }
                    }
                    else {
                        Context "Testing failsafe operator exists on $psitem" {
                            $failsafeoperator = Get-DbcConfigValue agent.failsafeoperator
                            It "The Failsafe Operator exists on $psitem" {
                                (Connect-DbaInstance -SqlInstance $psitem).JobServer.AlertSystem.FailSafeOperator | Should -Be $failsafeoperator -Because 'The failsafe operator will ensure that any job failures will be notified to someone if not set explicitly'
                            }
                        }
                    }
                }

                Describe "Database Mail Profile" -Tags DatabaseMailProfile, $filename {
                    if ($NotContactable -contains $psitem) {
                        Context "Testing database mail profile is set on $psitem" {
                            It "Can't Connect to $Psitem" {
                                $false | Should -BeTrue -Because "The instance should be available to be connected to!"
                            }
                        }
                    }
                    else {
                        Context "Testing database mail profile is set on $psitem" {
                            $databasemailprofile = Get-DbcConfigValue  agent.databasemailprofile
                            It "The Database Mail profile $databasemailprofile exists on $psitem" {
                                ((Get-DbaDbMailProfile -SqlInstance $InstanceSMO).Name -contains $databasemailprofile) | Should -Be $true -Because 'The database mail profile is required to send emails'
                            }
                        }
                    }
                }

                Describe "Agent Mail Profile" -Tags AgentMailProfile, $filename {
                    if ($NotContactable -contains $psitem) {
                        Context "Testing SQL Agent Alert System database mail profile is set on $psitem" {
                            It "Can't Connect to $Psitem" {
                                $false | Should -BeTrue -Because "The instance should be available to be connected to!"
                            }
                        }
                    }
                    else {
                        Context "Testing SQL Agent Alert System database mail profile is set on $psitem" {
                            $agentmailprofile = Get-DbcConfigValue  agent.databasemailprofile
                            It "The SQL Server Agent Alert System should have an enabled database mail profile on $psitem" {
                                (Get-DbaAgentServer -SqlInstance $InstanceSMO).DatabaseMailProfile | Should -Be $agentmailprofile -Because 'The SQL Agent Alert System needs an enabled database mail profile to send alert emails'
                            }
                        }
                    }
                }

                Describe "Failed Jobs" -Tags FailedJob, $filename {

                    if ($NotContactable -contains $psitem) {
                        Context "Checking for failed enabled jobs on $psitem" {
                            It "Can't Connect to $Psitem" {
                                $false | Should -BeTrue -Because "The instance should be available to be connected to!"
                            }
                        }
                    }
                    else {
                        $maxdays = Get-DbcConfigValue agent.failedjob.since
                        $startdate = (Get-Date).AddDays( - $maxdays)
                        Context "Checking for failed enabled jobs since $startdate on $psitem" {
                            $excludecancelled = Get-DbcConfigValue agent.failedjob.excludecancelled
                            @(Get-DbaAgentJob -SqlInstance $psitem | Where-Object { $Psitem.IsEnabled -and ($psitem.LastRunDate -gt $startdate) }).ForEach{
                                if ($psitem.LastRunOutcome -eq "Unknown") {
                                    It -Skip "We chose to skip this as $psitem's last run outcome is unknown on $($psitem.SqlInstance)" {
                                        $psitem.LastRunOutcome | Should -Be "Succeeded" -Because 'All Agent Jobs should have succeed this one is unknown - you need to investigate the failed jobs'
                                    }
                                }
                                elseif (($psitem.LastRunOutcome -eq "Cancelled") -and ($excludecancelled -eq $true)) {
                                    It -Skip "We chose to skip this as $psitem's last run outcome is cancelled on $($psitem.SqlInstance)" {
                                        $psitem.LastRunOutcome | Should -Be "Succeeded" -Because 'All Agent Jobs should have succeed this one is unknown - you need to investigate the failed jobs'
                                    }
                                }
                                else {
                                    It "$psitem's last run outcome is $($psitem.LastRunOutcome) on $($psitem.SqlInstance)" {
                                        $psitem.LastRunOutcome | Should -Be "Succeeded" -Because 'All Agent Jobs should have succeed - you need to investigate the failed jobs'
                                    }
                                }
                            }
                        }
                    }
                }

                Describe "Valid Job Owner" -Tags ValidJobOwner, $filename {
                    [string[]]$targetowner = Get-DbcConfigValue agent.validjobowner.name

                    if ($NotContactable -contains $psitem) {
                        Context "Testing job owners on $psitem" {
                            It "Can't Connect to $Psitem" {
                                $false | Should -BeTrue -Because "The instance should be available to be connected to!"
                            }
                        }
                    }
                    else {
                        Context "Testing job owners on $psitem" {
                            @(Get-DbaAgentJob -SqlInstance $psitem -EnableException:$false).ForEach{
                                It "Job $($psitem.Name)  - owner $($psitem.OwnerLoginName) should be in this list ( $( [String]::Join(", ", $targetowner) ) ) on $($psitem.SqlInstance)" {
                                    $psitem.OwnerLoginName | Should -BeIn $TargetOwner -Because "The account that is the job owner is not what was expected"
                                }
                            }
                        }
                    }
                }

                Describe "Agent Alerts" -Tags AgentAlert, $filename {
                    $severity = Get-DbcConfigValue agent.alert.Severity
                    $messageid = Get-DbcConfigValue agent.alert.messageid
                    $AgentAlertJob = Get-DbcConfigValue agent.alert.Job
                    $AgentAlertNotification = Get-DbcConfigValue agent.alert.Notification
                    $skip = Get-DbcConfigValue skip.agent.alert
                    if ($NotContactable -contains $psitem) {
                        Context "Testing Agent Alerts Severity exists on $psitem" {
                            It "Can't Connect to $Psitem" {
                                $false | Should -BeTrue -Because "The instance should be available to be connected to!"
                            }
                        }
                        Context "Testing Agent Alerts MessageID exists on $psitem" {
                            It "Can't Connect to $Psitem" {
                                $false | Should -BeTrue -Because "The instance should be available to be connected to!"
                            }
                        }
                    }
                    else {
                        $alerts = Get-DbaAgentAlert -SqlInstance $psitem
                        Context "Testing Agent Alerts Severity exists on $psitem" {
                            ForEach ($sev in $severity) {
                                It "Severity $sev Alert should exist on $psitem" -Skip:$skip {
                                    ($alerts.Where{ $psitem.Severity -eq $sev }) | Should -be $true -Because "Recommended Agent Alerts to exists http://blog.extreme-advice.com/2013/01/29/list-of-errors-and-severity-level-in-sql-server-with-catalog-view-sysmessages/"
                                }
                                It "Severity $sev Alert should be enabled on $psitem" -Skip:$skip {
                                    ($alerts.Where{ $psitem.Severity -eq $sev }).IsEnabled | Should -be $true -Because "Configured alerts should be enabled"
                                }
                                if ($AgentAlertJob) {
                                    It "A job name for Severity $sev Alert on $psitem" -Skip:$skip {
                                        ($alerts.Where{ $psitem.Severity -eq $sev }).jobname -ne $null | Should -be $true -Because "Should notify by SQL Agent Job"
                                    }
                                }
                                if ($AgentAlertNotification) {
                                    It "Severity $sev Alert should have a notification on $psitem" -Skip:$skip {
                                        ($alerts.Where{ $psitem.Severity -eq $sev }).HasNotification -in 1, 2, 3, 4, 5, 6, 7 | Should -be $true -Because "Should notify by Agent notifications"
                                    }
                                }
                            }
                        }
                        Context "Testing Agent Alerts MessageID exists on $psitem" {
                            ForEach ($mid in $messageid) {
                                It "Message_ID $mid Alert should exist on $psitem" -Skip:$skip {
                                    ($alerts.Where{ $psitem.messageid -eq $mid }) | Should -be $true -Because "Recommended Agent Alerts to exists http://blog.extreme-advice.com/2013/01/29/list-of-errors-and-severity-level-in-sql-server-with-catalog-view-sysmessages/"
                                }
                                It "Message_ID $mid Alert should be enabled on $psitem" -Skip:$skip {
                                    ($alerts.Where{ $psitem.messageid -eq $mid }) | Should -be $true -Because "Configured alerts should be enabled"
                                }
                                if ($AgentAlertJob) {
                                    It "A Job name for Message_ID $mid Alert should be on $psitem" -Skip:$skip {
                                        ($alerts.Where{ $psitem.messageid -eq $mid }).jobname -ne $null | Should -be $true -Because "Should notify by SQL Agent Job"
                                    }
                                }
                                if ($AgentAlertNotification) {
                                    It "Message_ID $mid Alert should have a notification on $psitem" -Skip:$skip {
                                        ($alerts.Where{ $psitem.messageid -eq $mid }).HasNotification -in 1, 2, 3, 4, 5, 6, 7 | Should -be $true -Because "Should notify by Agent notifications"
                                    }
                                }
                            }
                        }
                    }
                }

                Describe "Job History Configuration" -Tags JobHistory, $filename {
                    if ($NotContactable -contains $psitem) {
                        Context "Testing job history configuration on $psitem" {
                            It "Can't Connect to $Psitem" {
                                $false | Should -BeTrue -Because "The instance should be available to be connected to!"
                            }
                        }
                    }
                    else {
                        Context "Testing job history configuration on $psitem" {
                            [int]$minimumJobHistoryRows = Get-DbcConfigValue agent.history.maximumhistoryrows
                            [int]$minimumJobHistoryRowsPerJob = Get-DbcConfigValue agent.history.maximumjobhistoryrows

                            $AgentServer = Get-DbaAgentServer -SqlInstance $psitem -EnableException:$false

                            if ($minimumJobHistoryRows -eq -1) {
                                It "The maximum job history configuration should be set to disabled on $psitem" {
                                    Assert-JobHistoryRowsDisabled -AgentServer $AgentServer -minimumJobHistoryRows $minimumJobHistoryRows
                                }
                            }
                            else {
                                It "The maximum job history number of rows configuration should be greater or equal to $minimumJobHistoryRows on $psitem" {
                                    Assert-JobHistoryRows -AgentServer $AgentServer -minimumJobHistoryRows $minimumJobHistoryRows
                                }
                                It "The maximum job history rows per job configuration should be greater or equal to $minimumJobHistoryRowsPerJob on $psitem" {
                                    Assert-JobHistoryRowsPerJob -AgentServer $AgentServer -minimumJobHistoryRowsPerJob $minimumJobHistoryRowsPerJob
                                }
                            }
                        }
                    }
                }
                Describe "Long Running Agent Jobs" -Tags LongRunningJob, $filename {
                    $skip = Get-DbcConfigValue skip.agent.longrunningjobs
                    $runningjobpercentage = Get-DbcConfigValue agent.longrunningjob.percentage
                    if (-not $skip) {
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
                        $runningjobs = Invoke-DbaQuery -SqlInstance $PSItem -Database msdb -Query $query
                    }
                    if ($NotContactable -contains $psitem) {
                        Context "Testing long running jobs on $psitem" {
                            It "Can't Connect to $Psitem" {
                                $false | Should -BeTrue -Because "The instance should be available to be connected to!"
                            }
                        }
                    }
                    else {
                        Context "Testing long running jobs on $psitem" {
                            if ($runningjobs) {
                                foreach ($runningjob in $runningjobs | Where-Object { $_.AvgSec -ne 0 }) {
                                    It "Running job $($runningjob.JobName) duration should not be more than $runningjobpercentage % extra of the average run time on $psitem" -Skip:$skip {
                                        Assert-LongRunningJobs -runningjob $runningjob -runningjobpercentage $runningjobpercentage
                                    }
                                }
                            }
                            else {
                                It "There are no running jobs currently on $psitem" -Skip:$skip {
                                    $True | SHould -BeTrue
                                }
                            }
                        }
                    }
                }
                Describe "Last Agent Job Run" -Tags LastJobRunTime, $filename {
                    $skip = Get-DbcConfigValue skip.agent.lastjobruntime
                    $runningjobpercentage = Get-DbcConfigValue agent.lastjobruntime.percentage
                    $maxdays = Get-DbcConfigValue agent.failedjob.since
                    if (-not $skip) {
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
                        $lastagentjobruns = Invoke-DbaQuery -SqlInstance $PSItem -Database msdb -Query $query
                        Context "Testing last job run time on $psitem" {
                            foreach ($lastagentjobrun in $lastagentjobruns | Where-Object { $_.AvgSec -ne 0 }) {
                                It "Job $($lastagentjobrun.JobName) last run duration should be not be greater than $runningjobpercentage % extra of the average run time on $psitem" -Skip:$skip {
                                    Assert-LastJobRun -lastagentjobrun $lastagentjobrun -runningjobpercentage $runningjobpercentage
                                }
                            }
                        }
                    }
                    else {
                        Context "Testing last job run time on $psitem" {
                            It "Job average run time on $psitem" -Skip {
                                Assert-LastJobRun -lastagentjobrun $lastagentjobrun -runningjobpercentage $runningjobpercentage
                            }
                        }
                    }
                }
            }
        }
    }
}

# SIG # Begin signature block
# MIINEAYJKoZIhvcNAQcCoIINATCCDP0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUpTJODXCB9hZNNdKRvrY564R6
# fy6gggpSMIIFGjCCBAKgAwIBAgIQAsF1KHTVwoQxhSrYoGRpyjANBgkqhkiG9w0B
# AQsFADByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFz
# c3VyZWQgSUQgQ29kZSBTaWduaW5nIENBMB4XDTE3MDUwOTAwMDAwMFoXDTIwMDUx
# MzEyMDAwMFowVzELMAkGA1UEBhMCVVMxETAPBgNVBAgTCFZpcmdpbmlhMQ8wDQYD
# VQQHEwZWaWVubmExETAPBgNVBAoTCGRiYXRvb2xzMREwDwYDVQQDEwhkYmF0b29s
# czCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAI8ng7JxnekL0AO4qQgt
# Kr6p3q3SNOPh+SUZH+SyY8EA2I3wR7BMoT7rnZNolTwGjUXn7bRC6vISWg16N202
# 1RBWdTGW2rVPBVLF4HA46jle4hcpEVquXdj3yGYa99ko1w2FOWzLjKvtLqj4tzOh
# K7wa/Gbmv0Si/FU6oOmctzYMI0QXtEG7lR1HsJT5kywwmgcjyuiN28iBIhT6man0
# Ib6xKDv40PblKq5c9AFVldXUGVeBJbLhcEAA1nSPSLGdc7j4J2SulGISYY7ocuX3
# tkv01te72Mv2KkqqpfkLEAQjXgtM0hlgwuc8/A4if+I0YtboCMkVQuwBpbR9/6ys
# Z+sCAwEAAaOCAcUwggHBMB8GA1UdIwQYMBaAFFrEuXsqCqOl6nEDwGD5LfZldQ5Y
# MB0GA1UdDgQWBBRcxSkFqeA3vvHU0aq2mVpFRSOdmjAOBgNVHQ8BAf8EBAMCB4Aw
# EwYDVR0lBAwwCgYIKwYBBQUHAwMwdwYDVR0fBHAwbjA1oDOgMYYvaHR0cDovL2Ny
# bDMuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC1jcy1nMS5jcmwwNaAzoDGGL2h0
# dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3VyZWQtY3MtZzEuY3JsMEwG
# A1UdIARFMEMwNwYJYIZIAYb9bAMBMCowKAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3
# LmRpZ2ljZXJ0LmNvbS9DUFMwCAYGZ4EMAQQBMIGEBggrBgEFBQcBAQR4MHYwJAYI
# KwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBOBggrBgEFBQcwAoZC
# aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0U0hBMkFzc3VyZWRJ
# RENvZGVTaWduaW5nQ0EuY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQAD
# ggEBANuBGTbzCRhgG0Th09J0m/qDqohWMx6ZOFKhMoKl8f/l6IwyDrkG48JBkWOA
# QYXNAzvp3Ro7aGCNJKRAOcIjNKYef/PFRfFQvMe07nQIj78G8x0q44ZpOVCp9uVj
# sLmIvsmF1dcYhOWs9BOG/Zp9augJUtlYpo4JW+iuZHCqjhKzIc74rEEiZd0hSm8M
# asshvBUSB9e8do/7RhaKezvlciDaFBQvg5s0fICsEhULBRhoyVOiUKUcemprPiTD
# xh3buBLuN0bBayjWmOMlkG1Z6i8DUvWlPGz9jiBT3ONBqxXfghXLL6n8PhfppBhn
# daPQO8+SqF5rqrlyBPmRRaTz2GQwggUwMIIEGKADAgECAhAECRgbX9W7ZnVTQ7Vv
# lVAIMA0GCSqGSIb3DQEBCwUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdp
# Q2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0Rp
# Z2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0xMzEwMjIxMjAwMDBaFw0yODEw
# MjIxMjAwMDBaMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNI
# QTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUA
# A4IBDwAwggEKAoIBAQD407Mcfw4Rr2d3B9MLMUkZz9D7RZmxOttE9X/lqJ3bMtdx
# 6nadBS63j/qSQ8Cl+YnUNxnXtqrwnIal2CWsDnkoOn7p0WfTxvspJ8fTeyOU5JEj
# lpB3gvmhhCNmElQzUHSxKCa7JGnCwlLyFGeKiUXULaGj6YgsIJWuHEqHCN8M9eJN
# YBi+qsSyrnAxZjNxPqxwoqvOf+l8y5Kh5TsxHM/q8grkV7tKtel05iv+bMt+dDk2
# DZDv5LVOpKnqagqrhPOsZ061xPeM0SAlI+sIZD5SlsHyDxL0xY4PwaLoLFH3c7y9
# hbFig3NBggfkOItqcyDQD2RzPJ6fpjOp/RnfJZPRAgMBAAGjggHNMIIByTASBgNV
# HRMBAf8ECDAGAQH/AgEAMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEF
# BQcDAzB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRp
# Z2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQu
# Y29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDCBgQYDVR0fBHoweDA6oDig
# NoY0aHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9v
# dENBLmNybDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0
# QXNzdXJlZElEUm9vdENBLmNybDBPBgNVHSAESDBGMDgGCmCGSAGG/WwAAgQwKjAo
# BggrBgEFBQcCARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzAKBghghkgB
# hv1sAzAdBgNVHQ4EFgQUWsS5eyoKo6XqcQPAYPkt9mV1DlgwHwYDVR0jBBgwFoAU
# Reuir/SSy4IxLVGLp6chnfNtyA8wDQYJKoZIhvcNAQELBQADggEBAD7sDVoks/Mi
# 0RXILHwlKXaoHV0cLToaxO8wYdd+C2D9wz0PxK+L/e8q3yBVN7Dh9tGSdQ9RtG6l
# jlriXiSBThCk7j9xjmMOE0ut119EefM2FAaK95xGTlz/kLEbBw6RFfu6r7VRwo0k
# riTGxycqoSkoGjpxKAI8LpGjwCUR4pwUR6F6aGivm6dcIFzZcbEMj7uo+MUSaJ/P
# QMtARKUT8OZkDCUIQjKyNookAv4vcn4c10lFluhZHen6dGRrsutmQ9qzsIzV6Q3d
# 9gEgzpkxYz0IGhizgZtPxpMQBvwHgfqL2vmCSfdibqFT+hKUGIUukpHqaGxEMrJm
# oecYpJpkUe8xggIoMIICJAIBATCBhjByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMM
# RGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQD
# EyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQgQ29kZSBTaWduaW5nIENBAhACwXUo
# dNXChDGFKtigZGnKMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgACh
# AoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAM
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBR6292GaOkRQpYK7YAX6fyX7/wP
# RDANBgkqhkiG9w0BAQEFAASCAQAqjpHPYg2z23hNTVeTGYDZly37g28sRWCAUrEs
# 88d+5prPQzWXwVwdLuaHh8RT7UZFbQcW1WpCBLuZP5DBSS/FFU5JyktA9/QC628d
# f++FwmgDThKpeQN1b8inQtYJzX3A5Q9aLDP+xJJ93MGie/bCKb6QIquzjMcyHE/7
# zDFivcnkGwMmV2RjByoLnS3tdtnaKFqE3heslw2+UPu+OI1ZTTPnTB1hf5mnqj4t
# vILaQ+6UqijaJVM69wEOpqW7vindmodJBdYYycy2xXTBTFuvfeKa+6yilWYXVfjh
# 4KGe5zdHp/6hQdIvDZxk7KW3DgNX1otTk+81Mh+B2bzAUeyM
# SIG # End signature block
