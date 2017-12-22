$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "SQL Agent Service" -Tags AgentServiceAccount, ServiceAccount, $filename {
	(Get-SqlInstance).ForEach{
		$instance = $psitem
		Context "Testing SQL Agent is running on $instance" {
			(Get-DbaSqlService -ComputerName $instance -Type Agent).ForEach{
				It "SQL Agent should be running on $instance" {
					$psitem.State | Should be "Running"
				}
				It "SQL Agent service should have a start mode of Automatic on $instance" {
					$psitem.StartMode | Should be "Automatic"
				}
			}
		}
	}
}

Describe "DBA Operators" -Tags DbaOperator, Operator, $filename {
	(Get-SqlInstance).ForEach{
		$instance = $psitem
		Context "Testing DBA Operators exists on $instance" {
			$operatorname = Get-DbcConfigValue  agent.dbaoperatorname
			$operatoremail = Get-DbcConfigValue  agent.dbaoperatoremail
			(Get-DbaAgentOperator -SqlInstance $instance | Where-Object { $_.Name -eq $operatorname }).ForEach{
				It "Should have an operator called $operatorname on $instance" {
					$psitem.Name | Should be $operatorname
				}
				It "$operatorname should have an email address of $operatoremail on $instance" {
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
			$server = Connect-DbaSqlServer -SqlInstance $psitem
			It "$psitem should have a failsafe operator of $failsafeoperator" {
				$server.JobServer.AlertSystem.FailSafeOperator | Should be $failsafeoperator
			}
		}
	}
}