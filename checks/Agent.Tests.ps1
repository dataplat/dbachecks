$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "SQL Agent Account" -Tags AgentServiceAccount, ServiceAccount, $filename {
    @(Get-Instance).ForEach{
        Context "Testing SQL Agent is running on $psitem" {
            @(Get-DbaSqlService -ComputerName $psitem -Type Agent).ForEach{
                It "SQL Agent Should Be running on $psitem" {
                    $psitem.State | Should -Be "Running" -Because 'The agent service is required to run SQL Agent jobs'
                }
                It "SQL Agent service should have a start mode of Automatic on $psitem" {
                    $psitem.StartMode | Should -Be "Automatic" -Because 'Otherwise the Agent Jobs wont run if the server is restarted'
                }
            }
        }
    }
}

Describe "DBA Operators" -Tags DbaOperator, Operator, $filename {
    @(Get-Instance).ForEach{
        Context "Testing DBA Operators exists on $psitem" {
            $operatorname = Get-DbcConfigValue agent.dbaoperatorname
            $operatoremail = Get-DbcConfigValue agent.dbaoperatoremail
            $results = Get-DbaAgentOperator -SqlInstance $psitem -Operator $operatorname
            @($operatorname).ForEach{
                It "operator name $psitem exists" {
                    $psitem | Should -BeIn $Results.Name -Because 'This Operator is expected to exist'
                }
            }
            @($operatoremail).ForEach{
                if ($operatoremail) {
                    It "operator email $operatoremail is correct" {
                        $psitem | Should -Bein $results.EmailAddress -Because 'This operator email is expected to exist'
                    }
                }
            }
        }
    }
}

Describe "Failsafe Operator" -Tags FailsafeOperator, Operator, $filename {
    @(Get-Instance).ForEach{
        Context "Testing failsafe operator exists on $psitem" {
            $failsafeoperator = Get-DbcConfigValue agent.failsafeoperator
            It "failsafe operator on $psitem exists" {
                (Connect-DbaInstance -SqlInstance $psitem).JobServer.AlertSystem.FailSafeOperator | Should -Be $failsafeoperator -Because 'The failsafe operator will ensure that any job failures will be notifed to someone if not set explicitly'
            }
        }
    }
}

Describe "Database Mail Profile" -Tags DatabaseMailProfile, $filename {
    @(Get-Instance).ForEach{
        Context "Testing database mail profile is set on $psitem" {
            $databasemailprofile = Get-DbcConfigValue  agent.databasemailprofile
            It "database mail profile on $psitem is $databasemailprofile" {
                (Connect-DbaInstance -SqlInstance $psitem).JobServer.DatabaseMailProfile | Should -Be $databasemailprofile -Because 'The database mail profile is required to send emails'
            }
        }
    }
}

Describe "Failed Jobs" -Tags FailedJob, $filename {
    @(Get-Instance).ForEach{
        Context "Checking for failed enabled jobs on $psitem" {
            @(Get-DbaAgentJob -SqlInstance $psitem | Where-Object IsEnabled).ForEach{
                if ($psitem.LastRunOutcome -eq "Unknown") {
                    It -Skip "$psitem's last run outcome on $($psitem.SqlInstance) is unknown" {
                        $psitem.LastRunOutcome | Should -Be "Succeeded" -Because 'All Agent Jobs should have succeed this one is unknown - you need to investigate the failed jobs'
                    }
                } else {
                    It "$psitem's last run outcome on $($psitem.SqlInstance) is $($psitem.LastRunOutcome)" {
                        $psitem.LastRunOutcome | Should -Be "Succeeded" -Because 'All Agent Jobs should have succeed - you need to investigate the failed jobs'
                    }
                }
            }
        }
    }
}

Describe "Valid Job Owner" -Tags ValidJobOwner, $filename {
    [string[]]$targetowner = Get-DbcConfigValue agent.validjobowner.name
    @(Get-Instance).ForEach{
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
    @(Get-Instance).ForEach{
        $alerts = Get-DbaAgentAlert -SqlInstance $psitem
        Context "Testing Agent Alerts Severity exists on $psitem" {   
            ForEach ($sev in $severity) {
                It "Should have Severity $sev Alert" {
                    ($alerts.Where{$psitem.Severity -eq $sev}) | Should -be $true -Because "Recommended Agent Alerts to exists http://blog.extreme-advice.com/2013/01/29/list-of-errors-and-severity-level-in-sql-server-with-catalog-view-sysmessages/"
                }
                It "Should have Severity $sev Alert enabled" {
                    ($alerts.Where{$psitem.Severity -eq $sev}) | Should -be $true -Because "Configured alerts should be enabled"
                }
                if ($AgentAlertJob) {
                    It "Should have Jobname for Severity $sev Alert" {
                        ($alerts.Where{$psitem.Severity -eq $sev}).jobname -ne $null | Should -be $true -Because "Should notify by SQL Agent Job"
                    }
                }
                if ($AgentAlertNotification) {
                    It "Should have notification for Severity $sev Alert" {
                        ($alerts.Where{$psitem.Severity -eq $sev}).HasNotification -eq 1 | Should -be $true -Because "Should notify by Agent notifications"
                    }
                }
            }
        }
        Context "Testing Agent Alerts MessageID exists on $psitem" {
            ForEach ($mid in $messageid) {
                It "Should have Message_ID $mid Alert" {
                    ($alerts.Where{$psitem.messageid -eq $mid}) | Should -be $true -Because "Recommended Agent Alerts to exists http://blog.extreme-advice.com/2013/01/29/list-of-errors-and-severity-level-in-sql-server-with-catalog-view-sysmessages/"
                }
                It "Should have Message_ID $mid Alert enabled" {
                    ($alerts.Where{$psitem.messageid -eq $mid}) | Should -be $true -Because "Configured alerts should be enabled"
                }
                if ($AgentAlertJob) {
                    It "Should have Job name for Message_ID $mid Alert" {
                        ($alerts.Where{$psitem.messageid -eq $mid}).jobname -ne $null | Should -be $true -Because "Should notify by SQL Agent Job"
                    }
                }
                if ($AgentAlertNotification) {
                    It "Should have notification for Message_ID $mid Alert" {
                        ($alerts.Where{$psitem.messageid -eq $mid}).HasNotification -eq 1 | Should -be $true -Because "Should notify by Agent notifications"
                    }
                }
            }
        }
    }
}