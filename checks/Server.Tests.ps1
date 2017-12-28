$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "Server Power Plan Configuration" -Tags PowerPlan, $filename {
	(Get-ComputerName).ForEach{
		Context "Testing Server Power Plan Configuration on $psitem" {
			It "PowerPlan is High Performance" {
				(Test-DbaPowerPlan -ComputerName $psitem).IsBestPractice | Should Be $true
			}
		}
	}
}

Describe "Instance Connection" -Tags InstanceConnection, Connectivity, $filename {
	$skipremote = Get-DbcConfigValue skip.remotingcheck
	$authscheme = Get-DbcConfigValue policy.authscheme
	(Get-SqlInstance).ForEach{
		Context "Testing Instance Connection on $psitem" {
			$connection = Test-DbaConnection -SqlInstance $psitem
			It "connects successfully" {
				$connection.connectsuccess | Should Be $true
			}
			It "auth scheme should Be $authscheme" {
				$connection.AuthScheme | Should Be $authscheme
			}
			It "is pingable" {
				$connection.IsPingable | Should Be $true
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
			@(Test-DbaSpn -ComputerName $psitem).ForEach{
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
			@(Get-DbaDiskSpace -ComputerName $psitem).ForEach{
				It "$($psitem.Name) with $($psitem.PercentFree) percent free should be at least $free percent free" {
					$psitem.PercentFree -ge $free | Should Be $true
				}
			}
		}
	}
}

Describe "Ping Computer" -Tags PingComputer, $filename {
	$pingmsmax = Get-DbcConfigValue policy.pingmsmax
	$pingcount = Get-DbcConfigValue policy.pingcount
	(Get-ComputerName).ForEach{
		Context "Testing Disk Space on $psitem" {
			$results = Test-Connection -Count $pingcount -ComputerName $psitem -ErrorAction SilentlyContinue | Select-Object -ExpandProperty ResponseTime
			$avgResponseTime = (($results | Measure-Object -Average).Average) / $pingcount
			It "Average response time (ms) should Be less than $pingmsmax" {
				$results.Count -eq $pingcount | Should Be $true
				$avgResponseTime -lt $pingmsmax | Should Be $true
			}
		}
	}
}