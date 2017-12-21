$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "Server Power Plan Configuration" -Tag PowerPlan, $filename {
    (Get-ComputerName).ForEach{
        Context "Testing $_" {
            It "Server PowerPlan should be High Performance" {
                (Test-DbaPowerPlan -ComputerName $_).IsBestPractice | Should be $true
            }
        }
    }
}

Describe "Instance Connection" -Tag Instance, Connection, $filename {
	$skipremote = Get-DbcConfigValue skip.remotingcheck
	$authscheme = Get-DbcConfigValue policy.authscheme
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

Describe "SPNs" -Tag SPN, Kerberos, $filename {
	(Get-ComputerName).ForEach{
		$results = Test-DbaSpn -ComputerName $psitem
		foreach ($result in $results) {
			It "$psitem should have SPN for $($result.RequiredSPN) for $($result.InstanceServiceAccount)" {
				$result.Error | Should Be 'None'
			}
		}
	}
}

Describe "Disk Space" -Tag Storage, DISA, DiskSpace, $filename {
	$free = Get-DbcConfigValue policy.diskspacepercentfree
	(Get-ComputerName).ForEach{
		$results = Get-DbaDiskSpace -ComputerName $psitem
		foreach ($result in $results) {
			It "$($result.Name) on $psitem should be at least $free percent free" {
				$result.PercentFree -ge $free | Should be $true
			}
		}
	}
}