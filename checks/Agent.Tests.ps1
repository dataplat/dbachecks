$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "SQL Agent Service" -Tags AgentServiceAccount, ServiceAccount, $filename {
	(Get-SqlInstance).ForEach{
		Context "Testing SQL Agent is running on $psitem" {
			@(Get-DbaSqlService -ComputerName $psitem -Type Agent).ForEach{
				It "SQL Agent should be running" {
					$psitem.State | Should be "Running"
				}
				It "SQL Agent service should have a start mode of Automatic" {
					$psitem.StartMode | Should be "Automatic"
				}
			}
		}
	}
}

Describe "DBA Operators" -Tags DbaOperator, Operator, $filename {
	(Get-SqlInstance).ForEach{
		Context "Testing DBA Operators exists on $psitem" {
			$operatorname = Get-DbcConfigValue  agent.dbaoperatorname
			$operatoremail = Get-DbcConfigValue  agent.dbaoperatoremail
			(Get-DbaAgentOperator -SqlInstance $psitem | Where-Object { $_.Name -eq $operatorname }).ForEach{
				It "has an operator called $operatorname" {
					$psitem.Name | Should be $operatorname
				}
				It "$operatorname has an email address of $operatoremail" {
					$psitem.EmailAddress | Should be $operatoremail
				}
			}
		}
	}
}

Describe "Failsafe Operator" -Tags FailsafeOperator, Operator, $filename {
	(Get-SqlInstance).ForEach{
		Context "Testing failsafe operator exists on $psitem" {
			$failsafeoperator = Get-DbcConfigValue  agent.failsafeoperator
			It "failsafe operator is $failsafeoperator" {
				(Connect-DbaInstance -SqlInstance $psitem).JobServer.AlertSystem.FailSafeOperator | Should be $failsafeoperator
			}
		}
	}
}

Describe "Failed Jobs" -Tags FailedJob, $filename {
	(Get-SqlInstance).ForEach{
		Context "Checking for failed enabled jobs on $psitem" {
			(Get-DbaAgentJob -SqlInstance $psitem | Where-Object IsEnabled).ForEach{
				if ($psitem.LastRunOutcome -eq "Unknown") {
					It -Skip "$psitem's last run outcome is unknown" {
						$psitem.LastRunOutcome | Should Be "Succeeded"
					}
				}
				else {
					It "$psitem's last run outcome is success" {
						$psitem.LastRunOutcome | Should Be "Succeeded"
					}
				}
			}
		}
	}
}