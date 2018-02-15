$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "SQL Agent Account" -Tags AgentServiceAccount, ServiceAccount, $filename {
    (Get-SqlInstance).ForEach{
        Context "Testing SQL Agent is running on $psitem" {
            @(Get-DbaSqlService -ComputerName $psitem -Type Agent).ForEach{
                It "SQL Agent Should -Be running on $psitem" {
                    $psitem.State | Should -Be "Running"
                }
                It "SQL Agent service should have a start mode of Automatic on $psitem" {
                    $psitem.StartMode | Should -Be "Automatic"
                }
            }
        }
    }
}

Describe "DBA Operators" -Tags DbaOperator, Operator, $filename {
    (Get-SqlInstance).ForEach{
        Context "Testing DBA Operators exists on $psitem" {
            $operatorname = Get-DbcConfigValue agent.dbaoperatorname
            $operatoremail = Get-DbcConfigValue agent.dbaoperatoremail
            $results = Get-DbaAgentOperator -SqlInstance $psitem -Operator $operatorname
            foreach ($result in $results) {
                It "operator name on $psitem exists" {
                    $result.Name -in $operatorname| Should -Be $true
                }
                if ($operatoremail) {
                    It "operator email on $psitem is correct" {
                        $result.EmailAddress -in $operatoremail | Should -Be $true
                    }
                }
            }
        }
    }
}

Describe "Failsafe Operator" -Tags FailsafeOperator, Operator, $filename {
    (Get-SqlInstance).ForEach{
        Context "Testing failsafe operator exists on $psitem" {
            $failsafeoperator = Get-DbcConfigValue agent.failsafeoperator
            It "failsafe operator on $psitem exists" {
                (Connect-DbaInstance -SqlInstance $psitem).JobServer.AlertSystem.FailSafeOperator | Should -Be $failsafeoperator
            }
        }
    }
}

Describe "Database Mail Profile" -Tags DatabaseMailProfile, $filename {
    (Get-SqlInstance).ForEach{
        Context "Testing database mail profile is set on $psitem" {
            $databasemailprofile = Get-DbcConfigValue  agent.databasemailprofile
            It "database mail profile on $psitem is $databasemailprofile" {
                (Connect-DbaInstance -SqlInstance $psitem).JobServer.AlertSystem.DatabaseMailProfile | Should -Be $databasemailprofile
            }
        }
    }
}

Describe "Failed Jobs" -Tags FailedJob, $filename {
    (Get-SqlInstance).ForEach{
        Context "Checking for failed enabled jobs on $psitem" {
            @(Get-DbaAgentJob -SqlInstance $psitem | Where-Object IsEnabled).ForEach{
                if ($psitem.LastRunOutcome -eq "Unknown") {
                    It -Skip "$psitem's last run outcome on $($psitem.SqlInstance) is unknown" {
                        $psitem.LastRunOutcome | Should -Be "Succeeded"
                    }
                }
                else {
                    It "$psitem's last run outcome on $($psitem.SqlInstance) is success" {
                        $psitem.LastRunOutcome | Should -Be "Succeeded"
                    }
                }
            }
        }
    }
}