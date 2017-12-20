$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Describe 'Testing Server PowerPlan Configuration' -Tag PowerPlan, Server, $filename {
    (Get-ComputerName).ForEach{
        Context "Testing $_" {
            It "Server PowerPlan should be High Performance" {
                (Test-DbaPowerPlan -ComputerName $_).IsBestPractice | Should be $true
            }
        }
    }
}

$skipremote = Get-DbcConfigValue skip.remotingcheck
$authscheme = Get-DbcConfigValue policy.authscheme

Describe "Testing Instance Connectionn" -Tag Instance, Connection {
    (Get-ComputerName).ForEach{
        Context "$psitem Connection Tests" {
            BeforeAll {
                $Connection = Test-DbaConnection -SqlInstance $psitem 
            }
            It "$psitem Connects successfully" {
                $Connection.connectsuccess | Should BE $true
            }
            It "$psitem Auth Scheme should be $authscheme" {
                $connection.AuthScheme | Should Be $authscheme
            }
            It "$psitem Is pingable" {
                $Connection.IsPingable | Should be $true
            }
            It -Skip:$skipremote "$psitem Is PSRemotebale" {
                $Connection.PSRemotingAccessible | Should Be $True
            }
        }
    }
}

Describe 'Testing SPNs' -Tags SPN, $filename {
	(Get-ComputerName).ForEach{
		$results = Test-DbaSpn -ComputerName $psitem
		foreach ($result in $results) {
			It "$psitem should have SPN for $($result.RequiredSPN) for $($result.InstanceServiceAccount)" {
				$result.Error | Should Be 'None'
			}
		}
	}
}