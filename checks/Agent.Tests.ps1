$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "Operators" -Tag Operators, $filename {
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

