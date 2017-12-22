$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "SQL Engine Service" -Tags SqlEngineServiceAccount, ServiceAccount, $filename {
	(Get-SQLInstance).ForEach{
		$instance = $psitem
		Context "Testing SQL Engine Service on $psitem" {
			(Get-DbaSqlService -ComputerName $psitem -Type Engine).ForEach{
				It "SQL agent service account should be running on $instance" {
					$psitem.State | Should be "Running"
				}
				It "SQL agent service account should have a start mode of Automatic on $instance" {
					$psitem.StartMode | Should be "Automatic"
				}
			}
		}
	}
}

Describe "SQL Browser Service" -Tags SqlBrowserServiceAccount, ServiceAccount, $filename {
	(Get-SQLInstance).ForEach{
		$instance = $psitem
		Context "Testing SQL Browser Service on $instance" {
			(Get-DbaSqlService -ComputerName $instance).ForEach{
				It "SQL browser service should be Stopped unless multiple instances are installed on $instance" {
					if (($psitem.ServiceType -eq "Engine").count -eq 1) {
						$psitem.State | Should be "Stopped"
					}
					else {
						$psitem.State | Should be "Running"
					}
				}
				It "SQL browser service startmode should be Disabled on $instance unless multiple instances are installed" {
					if (($psitem.ServiceType -eq "Engine").count -eq 1) {
						$psitem.StartMode | Should be "Disabled"
					}
					else {
						$psitem.StartMode | Should be "Automatic"
					}
				}
			}
		}
	}
}

Describe "TempDB Configuration" -Tags TempDbConfiguration, $filename {
	(Get-SQLInstance).ForEach{
		$instance = $psitem
		Context "Testing TempDB Configuration on $psitem" {
			(Test-DBATempDbConfiguration -SqlServer $psitem).ForEach{
				It "$instance should have TF118 enabled" -Skip:$($Config.TempDb.Skip118) {
					$psitem[0].CurrentSetting | Should Be $psitem[0].Recommended
				}
				It "$instance should have $($psitem[1].Recommended) TempDB Files" -Skip:(Get-DbcConfigValue -Name skip.TempDb118) {
					$psitem[1].CurrentSetting | Should Be $psitem[1].Recommended
				}
				It "$instance should not have TempDB Files autogrowth set to percent" -Skip:(Get-DbcConfigValue -Name skip.TempDbFileGrowthPercent) {
					$psitem[2].CurrentSetting | Should Be $psitem[2].Recommended
				}
				It "$instance should not have TempDB Files on the C Drive" -Skip:(Get-DbcConfigValue -Name skip.TempDbFilesonC) {
					$psitem[3].CurrentSetting | Should Be $psitem[3].Recommended
				}
				It "$instance should not have TempDB Files with MaxSize Set" -Skip:(Get-DbcConfigValue -Name skip.TempDbFileMaxSize) {
					$psitem[4].CurrentSetting | Should Be $psitem[4].Recommended
				}
			}
		}
	}
}

Describe "Ad Hoc Workload Optimization" -Tags AdHocWorkload, $filename {
	(Get-SQLInstance).ForEach{
		$instance = $psitem
		Context "Testing Ad Hoc Workload Optimization on $instance" {
			It "Should be Optimised for Ad Hoc workloads" {
				(Test-DbaOptimizeForAdHoc -SqlInstance $instance).ForEach{
					$psitem.CurrentOptimizeAdHoc | Should be $psitem.RecommendedOptimizeAdHoc
				}
			}
		}
	}
}

Describe "Backup Path Access" -Tags BackupPathAccess, Storage, DISA, $filename {
	(Get-SqlInstance).ForEach{
		Context "Testing Backup Path Access on $psitem" {
			if (-not (Get-DbcConfigValue setup.backuppath)) {
				$backuppath = (Get-DbaDefaultPath -SqlInstance $psitem).Backup
			}
			else {
				$backuppath = Get-DbcConfigValue setup.backuppath
			}
			
			It "$psitem access to the backup path ($backuppath)" {
				Test-DbaSqlPath -SqlInstance $psitem -Path $backuppath | Should be $true
			}
			
		}
	}
}

Describe "Dedicated Administrator Connection" -Tags DAC, $filename {
	$dac = Get-DbcConfigValue policy.dacallowed
	(Get-SqlInstance).ForEach{
		Context "Testing Dedicated Administrator Connection on $psitem" {
			It "DAC is set to $dac on $psitem" {
				(Get-DbaSpConfigure -SqlInstance $psitem -ConfigName 'RemoteDACConnectionsEnabled').ConfiguredValue -eq 1 | Should Be $dac
			}
		}
	}
}

Describe "Network Latency" -Tags NetworkLatency, Connectivity, $filename {
	$max = Get-DbcConfigValue policy.networklatencymsmax
	(Get-SqlInstance).ForEach{
		$instance = $psitem
		Context "Testing Network Latency on $instance" {
			(Test-DbaNetworkLatency -SqlInstance $psitem).ForEach{
				It "network latency should be less than $max ms on $instance" {
					$psitem.Average.TotalMilliseconds | Should BeLessThan $max
				}
			}
		}
	}
}

Describe "Linked Servers" -Tags LinkedServerConnection, Connectivity, $filename {
	(Get-SqlInstance).ForEach{
		$instance = $psitem
		Context "Testing Linked Servers on $instance" {
			(Get-SqlInstance).ForEach{
				It "Linked Server $($psitem.LinkedServerName) Should Be Connectable" {
					$psitem.Connectivity | Should be $True
				}
			}
		}
	}
}

Describe "Max Memory" -Tags MaxMemory, $filename {
	(Get-SqlInstance).ForEach{
		$instance = $psitem
		Context "Testing Max Memory on $PSItem" {
			It "Max Memory setting should be correct" {
				(Test-DbaMaxMemory -SqlInstance $instance).ForEach{
					$psitem.SqlMaxMB | Should BeLessThan ($psitem.RecommendedMB + 379)
				}
			}
		}
	}
}