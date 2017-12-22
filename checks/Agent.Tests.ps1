$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "SQL Agent Service" -Tags AgentServiceAccount, ServiceAccount, $filename {
	(Get-SQLInstance).ForEach{
		Context "Testing SQL Agent Service service is running on $psitem" {
			$results = Get-DbaSqlService -ComputerName $psitem -Type Agent
			It "SQL agent service should be running on $psitem" {
				$results.State | Should be "Running"
			}
			It "SQL agent service should have a start mode of Automatic on $psitem" {
				$results.StartMode | Should be "Automatic"
			}
		}
	}
}

Describe "DBA Operators" -Tags DbaOperator, Operator, $filename {
	(Get-SQLInstance).ForEach{
		Context "Testing DBA Operators exists on $psitem" {
			$operatorname = Get-DbcConfigValue  agent.dbaoperatorname
			$operatoremail = Get-DbcConfigValue  agent.dbaoperatoremail
			$results = Get-DbaAgentOperator -SqlInstance $psitem | Where-Object { $_.Name -eq $operatorname }
			It "Should have an operator called $operatorname on $psitem" {
				$results.Name | Should be $operatorname
			}
			It "$operatorname should have an email address of $operatoremail on $psitem" {
				$results.EmailAddress | Should be $operatoremail
			}
		}
	}
}

Describe "Failsafe Operators" -Tags FailsafeOperator, Operator, $filename {
	(Get-SQLInstance).ForEach{
		Context "Testing failsafe operator is configured on $psitem" {
			$failsafeoperator = Get-DbcConfigValue  agent.failsafeoperator
			$fsosrv = Connect-DbaSqlServer -SqlInstance $psitem
			$result = $fsosrv.JobServer.AlertSystem.FailSafeOperator
			It "$psitem should have a failsafe operator of $failsafeoperator" {
				$result | Should be $failsafeoperator
			}
		}
	}
}