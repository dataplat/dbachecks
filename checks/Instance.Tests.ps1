$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "SQL Engine Service" -Tags SqlEngineServiceAccount, ServiceAccount, $filename {
	(Get-SqlInstance).ForEach{
		Context "Testing SQL Engine Service on $psitem" {
			(Get-DbaSqlService -ComputerName $psitem -Type Engine).ForEach{
				It "SQL agent service account should be running" {
					$psitem.State | Should be "Running"
				}
				It "SQL agent service account should have a start mode of Automatic" {
					$psitem.StartMode | Should be "Automatic"
				}
			}
		}
	}
}

Describe "SQL Browser Service" -Tags SqlBrowserServiceAccount, ServiceAccount, $filename {
	(Get-ComputerName).ForEach{
		Context "Testing SQL Browser Service on $psitem" {
			(Get-DbaSqlService -ComputerName $psitem).ForEach{
				It "SQL browser service should be Stopped unless multiple instances are installed" {
					if (($psitem.ServiceType -eq "Engine").count -eq 1) {
						$psitem.State | Should be "Stopped"
					}
					else {
						$psitem.State | Should be "Running"
					}
				}
				It "SQL browser service startmode should be Disabled unless multiple instances are installed" {
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
	(Get-SqlInstance).ForEach{
		Context "Testing TempDB Configuration on $psitem" {
			(Test-DbaTempDbConfiguration -SqlServer $psitem).ForEach{
				It "should have TF118 enabled" -Skip:$($Config.TempDb.Skip118) {
					$psitem[0].CurrentSetting | Should Be $psitem[0].Recommended
				}
				It "should have $($psitem[1].Recommended) TempDB Files" -Skip:(Get-DbcConfigValue -Name skip.TempDb118) {
					$psitem[1].CurrentSetting | Should Be $psitem[1].Recommended
				}
				It "should not have TempDB Files autogrowth set to percent" -Skip:(Get-DbcConfigValue -Name skip.TempDbFileGrowthPercent) {
					$psitem[2].CurrentSetting | Should Be $psitem[2].Recommended
				}
				It "should not have TempDB Files on the C Drive" -Skip:(Get-DbcConfigValue -Name skip.TempDbFilesonC) {
					$psitem[3].CurrentSetting | Should Be $psitem[3].Recommended
				}
				It "should not have TempDB Files with MaxSize Set" -Skip:(Get-DbcConfigValue -Name skip.TempDbFileMaxSize) {
					$psitem[4].CurrentSetting | Should Be $psitem[4].Recommended
				}
			}
		}
	}
}

Describe "Ad Hoc Workload Optimization" -Tags AdHocWorkload, $filename {
	(Get-SqlInstance).ForEach{
		Context "Testing Ad Hoc Workload Optimization on $psitem" {
			It "Should be Optimised for Ad Hoc workloads" {
				(Test-DbaOptimizeForAdHoc -SqlInstance $psitem).ForEach{
					$psitem.CurrentOptimizeAdHoc | Should be $psitem.RecommendedOptimizeAdHoc
				}
			}
		}
	}
}

Describe "Backup Path Access" -Tags BackupPathAccess, Storage, DISA, $filename {
	(Get-SqlInstance).ForEach{
		Context "Testing Backup Path Access on $psitem" {
			if (-not (Get-DbcConfigValue policy.backuppath)) {
				$backuppath = (Get-DbaDefaultPath -SqlInstance $psitem).Backup
			}
			else {
				$backuppath = Get-DbcConfigValue policy.backuppath
			}
			
			It "can access backup path ($backuppath)" {
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
		Context "Testing Network Latency on $psitem" {
			(Test-DbaNetworkLatency -SqlInstance $psitem).ForEach{
				It "network latency should be less than $max ms" {
					$psitem.Average.TotalMilliseconds | Should BeLessThan $max
				}
			}
		}
	}
}

Describe "Linked Servers" -Tags LinkedServerConnection, Connectivity, $filename {
	(Get-SqlInstance).ForEach{
		Context "Testing Linked Servers on $psitem" {
			(Test-DbaLinkedServerConnection -SqlInstance $psitem).ForEach{
				It "Linked Server $($psitem.LinkedServerName) has connectivity" {
					$psitem.Connectivity | Should be $true
				}
			}
		}
	}
}

Describe "Max Memory" -Tags MaxMemory, $filename {
	(Get-SqlInstance).ForEach{
		Context "Testing Max Memory on $psitem" {
			It "Max Memory setting should be correct" {
				(Test-DbaMaxMemory -SqlInstance $psitem).ForEach{
					$psitem.SqlMaxMB | Should BeLessThan ($psitem.RecommendedMB + 379)
				}
			}
		}
	}
}

Describe "Orphaned Files" -Tags OrphanedFile, $filename {
	(Get-SqlInstance).ForEach{
		Context "Checking for orphaned database files on $psitem" {
			It "doesn't have orphan files" {
				(Find-DbaOrphanedFile -SqlInstance $psitem).Count | Should Be 0
			}
		}
	}
}

Describe "SQL + Windows names match" -Tags ServerNameMatch, $filename {
	(Get-SqlInstance).ForEach{
		Context "Testing $psitem's instance name matches Windows name" {
			It "doesn't require rename" {
				(Test-DbaServerName -SqlInstance $psitem).RenameRequired | Should Be $false
			}
		}
	}
}

Describe "SQL Memory Dumps" -Tags MemoryDump, $filename {
	$maxdumps = Get-DbcConfigValue -Name policy.maxdumpcount
	(Get-SqlInstance).ForEach{
		Context "Checking that dumps on $psitem do not exceed $maxdumps" {
			It "dump count does not exceed $maxdumps" {
				(Get-DbaDump -SqlInstance $psitem).Count -le $maxdumps | Should Be $true
			}
		}
	}
}