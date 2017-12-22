$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "SQL Engine Service Account" -Tag ServiceAccount, SQLEngine, $filename {
    (Get-SQLInstance).ForEach{
        Context "Testing $psitem" {
        $results = Get-DbaSqlService -ComputerName $psitem -Type Engine
        	It "SQL agent service account should be running on $psitem" {
				$results.State | Should be "Running"
			}
			It "SQL agent service account should have a start mode of Automatic on $psitem" {
				$results.StartMode | Should be "Automatic"
			}
		}
	}
}

Describe "SQL Browser Service Account" -Tag ServiceAccount, SQLEngine, $filename {
    (Get-SQLInstance).ForEach{
        Context "Testing $psitem" {
        $results = Get-DbaSqlService -ComputerName $psitem
        	It "SQL browser service should be Stopped on $psitem unless multiple instances are installed" {
				if (($r.ServiceType -eq "Engine").count -eq 1) 
                {
                    $results.State | Should be "Stopped"
                } else {
                    $results.State | Should be "Running"
                }
			}
			It "SQL browser service startmode should be Disabled on $psitem unless multiple instances are installed" {
				if (($r.ServiceType -eq "Engine").count -eq 1) 
                {
				    $results.StartMode | Should be "Disabled"
                } else {
                    $results.StartMode | Should be "Automatic"
                }
			}
		}
	}
}

Describe "TempDB Configuration" -Tag TempDB, $filename {
    (Get-SQLInstance).ForEach{
        Context "Testing $psitem" {
            $tempdbtests = Test-DBATempDbConfiguration -SqlServer $psitem
            It "$psitem should have TF118 enabled" -Skip:$($Config.TempDb.Skip118) {
                $tempdbtests[0].CurrentSetting | Should Be $tempdbtests[0].Recommended
            }
            It "$psitem should have $($tempdbtests[1].Recommended) TempDB Files" -Skip:(Get-DbcConfigValue -Name skip.TempDb118) {
                $tempdbtests[1].CurrentSetting | Should Be $tempdbtests[1].Recommended
            }
            It "$psitem should not have TempDB Files autogrowth set to percent" -Skip:(Get-DbcConfigValue -Name skip.TempDbFileGrowthPercent) {
                $tempdbtests[2].CurrentSetting | Should Be $tempdbtests[2].Recommended
            }
            It "$psitem should not have TempDB Files on the C Drive" -Skip:(Get-DbcConfigValue -Name skip.TempDbFilesonC) {
                $tempdbtests[3].CurrentSetting | Should Be $tempdbtests[3].Recommended
            }
            It "$psitem should not have TempDB Files with MaxSize Set" -Skip:(Get-DbcConfigValue -Name skip.TempDbFileMaxSize) {
                $tempdbtests[4].CurrentSetting | Should Be $tempdbtests[4].Recommended
            }
        }
    }
}

Describe "AdHoc Workload Optimization" -Tag AdHoc, $filename{
    (Get-SQLInstance).ForEach{
        Context "Testing $psitem" {
            It "Should be Optimised for AdHocworkloads" {
                $Results = Test-DbaOptimizeForAdHoc -SqlInstance $psitem
                $Results.CurrentOptimizeAdHoc | Should be $Results.RecommendedOptimizeAdHoc
            }
        }
    }
}

Describe "Backup Path Access" -Tag Storage, DISA, Backup, BackupPathAccess, $filename {
	(Get-SqlInstance).ForEach{
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

Describe "DAC" -Tag DAC, $filename {
    $dac = Get-DbcConfigValue policy.dacallowed
    (Get-SqlInstance).ForEach{
        Context "Testing $psitem" {
			It "$psitem Should have DAC enabled $dac" {
                (Get-DbaSpConfigure -SqlInstance $psitem -ConfigName 'RemoteDACConnectionsEnabled').ConfiguredValue -eq 1  | Should Be $dac
            }
        }
    }
}

Describe "Network Latency" -Tag Network, Latency, NetworkLatency, $filename {
	$max = Get-DbcConfigValue policy.networklatencymsmax
	(Get-SqlInstance).ForEach{
		$results = Test-DbaNetworkLatency -SqlInstance $psitem
		It "network latency for $psitem should be less than $max ms" {
			$results.Average.TotalMilliseconds | Should BeLessThan $max
		}
	}
}

Describe "Linked Servers" -Tag LinkedServer, $filename {
	(Get-SqlInstance).ForEach{
		Context "Testing $psitem" {
			$Results = Test-DbaLinkedServerConnection -SqlInstance $psitem
			$Results.ForEach{
				It "Linked Server $($psitem.LinkedServerName) Should Be Connectable" {
					$psitem.Connectivity | Should be $True
				}
			}
		}
	}
}

Describe "Max Memory" -Tag MaxMemory, Memory, $filename {
	(Get-SqlInstance).ForEach{
        Context "Testing $PSItem" {
            It "Max Memory setting should be correct" {
                $Results = Test-DbaMaxMemory -SqlInstance $PSItem
                $Results.SqlMaxMB | Should BeLessThan ($Results.RecommendedMB + 379)
            }
        }
    }
}