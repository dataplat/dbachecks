$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "Server Power Plan Configuration" -Tags PowerPlan, $filename {
	(Get-ComputerName).ForEach{
		Context "Testing Server Power Plan Configuration on $psitem" {
			It "PowerPlan is High Performance" {
				(Test-DbaPowerPlan -ComputerName $psitem).IsBestPractice | Should be $true
			}
		}
	}
}

Describe "Instance Connection" -Tags InstanceConnection, Connectivity, $filename {
	$skipremote = Get-DbcConfigValue skip.remotingcheck
	$authscheme = Get-DbcConfigValue policy.authscheme
	(Get-ComputerName).ForEach{
		Context "Testing Instance Connection on $psitem" {
			$connection = Test-DbaConnection -SqlInstance $psitem
			It "$psitem Connects successfully" {
				$connection.connectsuccess | Should BE $true
			}
			It "$psitem Auth Scheme should be $authscheme" {
				$connection.AuthScheme | Should Be $authscheme
			}
			It "$psitem Is pingable" {
				$connection.IsPingable | Should be $true
			}
			It -Skip:$skipremote "$psitem Is PSRemotebale" {
				$Connection.PSRemotingAccessible | Should Be $True
			}
		}
	}
}

Describe "SPNs" -Tags SPN, $filename {
	(Get-ComputerName).ForEach{
		Context "Testing SPNs on $psitem" {
			$computer = $psitem
			(Test-DbaSpn -ComputerName $psitem).ForEach{
				It "$computer should have SPN for $($psitem.RequiredSPN) for $($psitem.InstanceServiceAccount)" {
					$psitem.Error | Should Be 'None'
				}
			}
		}
	}
}

Describe "Disk Space" -Tags DiskCapacity, Storage, DISA, $filename {
	$free = Get-DbcConfigValue policy.diskspacepercentfree
	(Get-ComputerName).ForEach{
		Context "Testing Disk Space on $psitem" {
			$computer = $psitem
			(Get-DbaDiskSpace -ComputerName $psitem).ForEach{
				It "$($psitem.Name) on $computer should be at least $free percent free" {
					$psitem.PercentFree -ge $free | Should be $true
				}
			}
		}
	}
}