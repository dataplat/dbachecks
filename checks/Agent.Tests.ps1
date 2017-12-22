$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "DBA Operators" -Tag Operators, $filename {
    (Get-SQLInstance).ForEach{
        Context "Testing $psitem" {
        $operatorname = Get-DbcConfigValue  agent.dbaoperatorname		
        $operatoremail = Get-DbcConfigValue  agent.dbaoperatoremail
        $results = Get-DbaAgentOperator -SqlInstance $psitem | Where {$_.Name -eq $operatorname}
			It "Should have an operator called $operatorname on $psitem" {
				$results.Name | Should be $operatorname
			}
			It "$operatorname should have an email address of $operatoremail on $psitem" {
				$results.EmailAddress | Should be $operatoremail
			}
		}
	}
}

Describe "Failsafe Operator" -Tag Operators, $filename {
    (Get-SQLInstance).ForEach{
        Context "Testing $psitem" {
        $failsafeoperator = Get-DbcConfigValue  agent.failsafeoperator
        $fsosrv = Connect-DbaSqlServer -SqlInstance $psitem 
        $result = $fsosrv.JobServer.AlertSystem.FailSafeOperator
			It "$psitem should have a failsafe operator of $failsafeoperator" {
				$result | Should be $failsafeoperator
			}
		}
	}
}